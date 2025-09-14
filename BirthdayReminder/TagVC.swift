import UIKit
import CoreData
import FirebaseFirestore

class TagVC: UIViewController, UITableViewDelegate, UITableViewDataSource, AddNewGroupVCDelegate {

    var managedContext: NSManagedObjectContext! // Keep for migration
    var groups: [FirestoreGroup] = []
    var allBirthdays: [FirestoreBirthday] = [] // Cache all birthdays for counting
    private let firestoreManager = FirestoreManager.shared
    private var groupsListener: ListenerRegistration?
    private var birthdaysListener: ListenerRegistration?

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
        setupFirestoreListener()
        setupBirthdaysListener()
    }

    deinit {
        groupsListener?.remove()
        birthdaysListener?.remove()
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
        addGroupVC.managedContext = managedContext // Keep for migration
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

    private func setupFirestoreListener() {
        groupsListener = firestoreManager.listenToGroups { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let groups):
                    self?.groups = groups
                    self?.tableView.reloadData()
                    self?.updateView()
                case .failure(let error):
                    print("Error fetching groups: \(error)")
                    self?.showErrorAlert("Failed to load groups: \(error.localizedDescription)")
                }
            }
        }
    }
    
    private func showErrorAlert(_ message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
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

    private func setupBirthdaysListener() {
        firestoreManager.fetchAllBirthdays { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let birthdays):
                    self?.allBirthdays = birthdays
                    self?.tableView.reloadData() // Refresh counts
                case .failure(let error):
                    print("Error fetching birthdays for counting: \(error)")
                }
            }
        }
    }
    
    private func countBirthdays(for group: FirestoreGroup) -> Int {
        return allBirthdays.filter { $0.groupId == group.id }.count
    }

    // AddNewGroupVCDelegate Method
    func didAddGroup() {
        // Firestore listener will automatically update the UI
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
        guard let groupId = group.id else { return }
        
        firestoreManager.deleteGroup(groupId) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success():
                    // Firestore listener will automatically update the UI
                    print("Group deleted successfully")
                case .failure(let error):
                    print("Error deleting group: \(error)")
                    self?.showErrorAlert("Failed to delete group: \(error.localizedDescription)")
                }
            }
        }
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let group = groups[indexPath.row]
        let birthdayVC = BirthdayVC()
        birthdayVC.firestoreGroup = group  // Pass Firestore group
        birthdayVC.managedContext = managedContext // Keep for migration
        navigationController?.pushViewController(birthdayVC, animated: true)
    }
}
