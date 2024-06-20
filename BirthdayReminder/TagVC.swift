import UIKit
import CoreData

class TagVC: UIViewController, UITableViewDelegate, UITableViewDataSource, AddNewGroupVCDelegate {

    var managedContext: NSManagedObjectContext!
    var groups: [Group] = []

    private let tableView: UITableView = {
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.register(GroupCell.self, forCellReuseIdentifier: "GroupCell")
        return tableView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        navigationItem.title = "Tags"
        configureItems()
        setupTableView()
        fetchGroups()
        
        // Add observer for GroupDeleted and BirthdayAdded notification
        NotificationCenter.default.addObserver(self, selector: #selector(fetchGroups), name: NSNotification.Name("GroupDeleted"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(fetchGroups), name: NSNotification.Name("BirthdayAdded"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(fetchGroups), name: NSNotification.Name("BirthdayDeleted"), object: nil)
    }

    deinit {
        // Remove observer when the view controller is deallocated
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name("GroupDeleted"), object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name("BirthdayAdded"), object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name("BirthdayDeleted"), object: nil)
    }

    private func configureItems() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .add,
            target: self,
            action: #selector(addGroup)
        )
    }

    @objc private func addGroup() {
        let addGroupVC = AddNewGroupVC()
        addGroupVC.modalPresentationStyle = .pageSheet
        addGroupVC.managedContext = managedContext
        addGroupVC.delegate = self

        if let sheet = addGroupVC.sheetPresentationController {
            sheet.detents = [.medium(), .large()]
            sheet.prefersGrabberVisible = true
            sheet.preferredCornerRadius = 16
        }

        present(addGroupVC, animated: true, completion: nil)
    }

    private func setupTableView() {
        view.addSubview(tableView)
        tableView.delegate = self
        tableView.dataSource = self

        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }

    @objc private func fetchGroups() {
        let fetchRequest: NSFetchRequest<Group> = Group.fetchRequest()
        do {
            groups = try managedContext.fetch(fetchRequest)
            tableView.reloadData()
        } catch let error as NSError {
            print("Could not fetch groups. \(error), \(error.userInfo)")
        }
    }

    private func countBirthdays(for group: Group) -> Int {
        let fetchRequest: NSFetchRequest<Birthday> = Birthday.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "group == %@", group)
        do {
            let count = try managedContext.count(for: fetchRequest)
            return count
        } catch let error as NSError {
            print("Could not fetch birthdays count. \(error), \(error.userInfo)")
            return 0
        }
    }

    // AddNewGroupVCDelegate Method
    func didAddGroup() {
        fetchGroups()
    }

    // TableView DataSource Methods
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return groups.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "GroupCell", for: indexPath) as! GroupCell
        let group = groups[indexPath.row]
        let birthdayCount = countBirthdays(for: group)
        cell.configure(with: group, birthdayCount: birthdayCount) {
            self.deleteGroup(at: indexPath)
        }
        return cell
    }

    private func deleteGroup(at indexPath: IndexPath) {
        let group = groups[indexPath.row]

        // Delete associated birthdays
        let fetchRequest: NSFetchRequest<Birthday> = Birthday.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "group == %@", group)
        do {
            let birthdaysToDelete = try managedContext.fetch(fetchRequest)
            for birthday in birthdaysToDelete {
                managedContext.delete(birthday)
            }
        } catch let error as NSError {
            print("Could not fetch birthdays for deletion. \(error), \(error.userInfo)")
        }

        // Delete the group
        managedContext.delete(group)
        do {
            try managedContext.save()
            groups.remove(at: indexPath.row)
            tableView.reloadData()

            // Post notification to update the calendar
            NotificationCenter.default.post(name: NSNotification.Name("GroupDeleted"), object: nil)
        } catch let error as NSError {
            print("Could not delete group. \(error), \(error.userInfo)")
        }
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let group = groups[indexPath.row]
        let birthdayVC = BirthdayVC()
        birthdayVC.group = group
        birthdayVC.managedContext = managedContext
        navigationController?.pushViewController(birthdayVC, animated: true)
    }
}
