import UIKit
import CoreData
import UserNotifications
import FirebaseFirestore

class BirthdayVC: UIViewController, UITableViewDelegate, UITableViewDataSource, AddNewBirthdayVCDelegate {

    var managedContext: NSManagedObjectContext! // Keep for migration
    var group: Group! // Keep for Core Data compatibility
    var firestoreGroup: FirestoreGroup?
    var birthdays: [FirestoreBirthday] = []
    private let firestoreManager = FirestoreManager.shared
    private var birthdaysListener: ListenerRegistration?

    private let tableView: UITableView = {
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.register(BirthdayCell.self, forCellReuseIdentifier: "BirthdayCell")
        return tableView
    }()
    
    private let noBirthdaysView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = UIImage(systemName: "gift.fill") // Use a suitable icon
        imageView.tintColor = .gray
        view.addSubview(imageView)
        
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Tap the add icon to create a new birthday"
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
        
        // Set title from Firestore group if available, otherwise use Core Data group
        navigationItem.title = firestoreGroup?.name ?? group?.name ?? "Birthdays"
        
        configureItems()
        setupTableView()
        setupFirestoreListener()
    }

    deinit {
        birthdaysListener?.remove()
    }

    private func configureItems() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .add,
            target: self,
            action: #selector(addBirthday)
        )
    }

    @objc private func addBirthday() {
        let addBirthdayVC = AddNewBirthdayVC()
        addBirthdayVC.modalPresentationStyle = .pageSheet
        addBirthdayVC.managedContext = managedContext // Keep for migration
        addBirthdayVC.group = group // Keep for Core Data compatibility
        addBirthdayVC.firestoreGroup = firestoreGroup // Pass Firestore group
        addBirthdayVC.delegate = self

        if let sheet = addBirthdayVC.sheetPresentationController {
            sheet.detents = [.medium(), .large()]
            sheet.prefersGrabberVisible = true
            sheet.preferredCornerRadius = 16
        }

        present(addBirthdayVC, animated: true, completion: nil)
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

    private func setupNoBirthdaysView() {
        view.addSubview(noBirthdaysView)
        NSLayoutConstraint.activate([
            noBirthdaysView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            noBirthdaysView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            noBirthdaysView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            noBirthdaysView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20)
        ])
    }

    private func setupFirestoreListener() {
        guard let groupId = firestoreGroup?.id else {
            print("No Firestore group ID available")
            return
        }
        
        birthdaysListener = firestoreManager.listenToBirthdays(for: groupId) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let birthdays):
                    self?.birthdays = birthdays
                    self?.tableView.reloadData()
                    self?.updateView()
                    self?.scheduleBirthdayNotifications()
                case .failure(let error):
                    print("Error fetching birthdays: \(error)")
                    self?.showErrorAlert("Failed to load birthdays: \(error.localizedDescription)")
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
        if birthdays.isEmpty {
            tableView.isHidden = true
            setupNoBirthdaysView()
            noBirthdaysView.isHidden = false
        } else {
            tableView.isHidden = false
            noBirthdaysView.isHidden = true
        }
    }

    // AddNewBirthdayVCDelegate Method
    func didAddBirthday() {
        // Firestore listener will automatically update the UI
    }

    // TableView DataSource Methods
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return birthdays.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "BirthdayCell", for: indexPath) as! BirthdayCell
        let birthday = birthdays[indexPath.row]
        cell.configure(with: birthday) {
            self.deleteBirthday(at: indexPath)
        }
        return cell
    }

    private func deleteBirthday(at indexPath: IndexPath) {
        let birthday = birthdays[indexPath.row]
        guard let birthdayId = birthday.id else { return }
        
        firestoreManager.deleteBirthday(birthdayId) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success():
                    // Firestore listener will automatically update the UI
                    print("Birthday deleted successfully")
                case .failure(let error):
                    print("Error deleting birthday: \(error)")
                    self?.showErrorAlert("Failed to delete birthday: \(error.localizedDescription)")
                }
            }
        }
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let birthdayMessageVC = BirthdayMessageVC()
        navigationController?.pushViewController(birthdayMessageVC, animated: true)
    }

    // Schedule birthday notifications
    private func scheduleBirthdayNotifications() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()

        for birthday in birthdays {
            scheduleNotification(for: birthday)
        }
    }

    private func scheduleNotification(for birthday: FirestoreBirthday) {
        let content = UNMutableNotificationContent()
        content.title = "Birthday Reminder"
        content.body = "It's \(birthday.name) birthday today! Wish them all the best."
        content.sound = .default

        var dateComponents = Calendar.current.dateComponents([.month, .day], from: birthday.dateValue)
        dateComponents.hour = 9  // Notify at 9 AM

        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error scheduling notification: \(error)")
            }
        }
    }
}
