import UIKit
import CoreData
import UserNotifications

class BirthdayVC: UIViewController, UITableViewDelegate, UITableViewDataSource, AddNewBirthdayVCDelegate {

    var managedContext: NSManagedObjectContext!
    var group: Group!
    var birthdays: [Birthday] = []

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
        navigationItem.title = group.name
        configureItems()
        setupTableView()
        fetchBirthdays()
        
        // Add observer for BirthdayDeleted and BirthdayAdded notification
        NotificationCenter.default.addObserver(self, selector: #selector(fetchBirthdays), name: NSNotification.Name("BirthdayDeleted"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(fetchBirthdays), name: NSNotification.Name("BirthdayAdded"), object: nil)
    }

    deinit {
        // Remove observer when the view controller is deallocated
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name("BirthdayDeleted"), object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name("BirthdayAdded"), object: nil)
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
        addBirthdayVC.managedContext = managedContext
        addBirthdayVC.group = group
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

    @objc private func fetchBirthdays() {
        let fetchRequest: NSFetchRequest<Birthday> = Birthday.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "group == %@", group)
        do {
            birthdays = try managedContext.fetch(fetchRequest)
            tableView.reloadData()
            updateView()
            scheduleBirthdayNotifications()
        } catch let error as NSError {
            print("Could not fetch birthdays. \(error), \(error.userInfo)")
        }
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
        fetchBirthdays()
        NotificationCenter.default.post(name: NSNotification.Name("BirthdayAdded"), object: nil)
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
        let birthdayToDelete = birthdays[indexPath.row]
        managedContext.delete(birthdayToDelete)
        do {
            try managedContext.save()
            birthdays.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .automatic)
            updateView()
            scheduleBirthdayNotifications()
            NotificationCenter.default.post(name: NSNotification.Name("BirthdayDeleted"), object: nil)
        } catch let error as NSError {
            print("Could not delete birthday. \(error), \(error.userInfo)")
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

    private func scheduleNotification(for birthday: Birthday) {
        let content = UNMutableNotificationContent()
        content.title = "Birthday Reminder"
        content.body = "It's \(birthday.name ?? "someone's") birthday today! Wish them all the best."
        content.sound = .default

        var dateComponents = Calendar.current.dateComponents([.month, .day], from: birthday.date ?? Date())
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
