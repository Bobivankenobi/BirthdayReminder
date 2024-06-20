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
    
    private let noGroupsView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = UIImage(systemName: "gift.fill") // Use a suitable icon
        imageView.tintColor = .gray
        view.addSubview(imageView)
        
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "In order to create new birthday group tap the add icon"
        label.textAlignment = .center
        label.textColor = .gray
        label.numberOfLines = 0
        view.addSubview(label)
        
        NSLayoutConstraint.activate([
            imageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            imageView.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -20),
            imageView.heightAnchor.constraint(equalToConstant: 50),
            imageView.widthAnchor.constraint(equalToConstant: 50),
            
            label.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 20),
            label.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            label.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20)
        ])
        
        return view
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        navigationItem.title = "Tags"
        configureItems()
        setupTableView()
        fetchGroups()
        
        // Add observer for GroupDeleted notification
        NotificationCenter.default.addObserver(self, selector: #selector(groupDeleted(_:)), name: NSNotification.Name("GroupDeleted"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(birthdayAdded(_:)), name: NSNotification.Name("BirthdayAdded"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(birthdayDeleted(_:)), name: NSNotification.Name("BirthdayDeleted"), object: nil)
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

    private func setupNoGroupsView() {
        view.addSubview(noGroupsView)
        NSLayoutConstraint.activate([
            noGroupsView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            noGroupsView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            noGroupsView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            noGroupsView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20)
        ])
    }

    private func fetchGroups() {
        let fetchRequest: NSFetchRequest<Group> = Group.fetchRequest()
        do {
            groups = try managedContext.fetch(fetchRequest)
            tableView.reloadData()
            updateView()
        } catch let error as NSError {
            print("Could not fetch groups. \(error), \(error.userInfo)")
        }
    }

    private func updateView() {
        if groups.isEmpty {
            tableView.isHidden = true
            setupNoGroupsView()
            noGroupsView.isHidden = false
        } else {
            tableView.isHidden = false
            noGroupsView.isHidden = true
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
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "GroupCell", for: indexPath) as? GroupCell else {
            fatalError("The dequeued cell is not an instance of GroupCell.")
        }
        let group = groups[indexPath.row]
        let birthdayCount = countBirthdays(for: group)
        cell.configure(with: group, birthdayCount: birthdayCount) { [weak self] in
            self?.deleteGroup(at: indexPath)
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
            tableView.deleteRows(at: [indexPath], with: .automatic)
            updateView()

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

    @objc private func groupDeleted(_ notification: Notification) {
        fetchGroups()
    }

    @objc private func birthdayAdded(_ notification: Notification) {
        fetchGroups()
    }

    @objc private func birthdayDeleted(_ notification: Notification) {
        fetchGroups()
    }
}
