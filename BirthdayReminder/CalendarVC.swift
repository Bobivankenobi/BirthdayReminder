import UIKit
import FSCalendar
import CoreData
import FirebaseFirestore

class CalendarVC: UIViewController, FSCalendarDelegate, FSCalendarDataSource, UITableViewDelegate, UITableViewDataSource, AddNewBirthdayVCDelegate {

    var calendar: FSCalendar!
    var tableView: UITableView!
    var birthdays: [FirestoreBirthday] = []
    var selectedBirthdays: [FirestoreBirthday] = []

    var managedContext: NSManagedObjectContext! // Keep for migration
    private let firestoreManager = FirestoreManager.shared
    private var birthdaysListener: ListenerRegistration?

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        navigationItem.title = "Calendar"

        setupCalendar()
        setupTableView()
        setupFirestoreListener()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // Refresh data when calendar appears
        setupFirestoreListener()
    }

    deinit {
        birthdaysListener?.remove()
    }

    private func setupCalendar() {
        calendar = FSCalendar()
        calendar.translatesAutoresizingMaskIntoConstraints = false
        calendar.delegate = self
        calendar.dataSource = self
        view.addSubview(calendar)

        NSLayoutConstraint.activate([
            calendar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            calendar.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            calendar.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            calendar.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.5)
        ])
    }

    private func setupTableView() {
        tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "BirthdayCell")
        view.addSubview(tableView)

        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: calendar.bottomAnchor, constant: 20),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -20)
        ])
    }

    private func setupFirestoreListener() {
        // For now, just fetch all birthdays once
        // In a real implementation, you might want to set up listeners for each group
        firestoreManager.fetchAllBirthdays { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let birthdays):
                    self?.birthdays = birthdays
                    print("Birthdays fetched: \(birthdays.count)")
                    self?.calendar.reloadData()
                    self?.tableView.reloadData()
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

    // FSCalendarDataSource
    func calendar(_ calendar: FSCalendar, numberOfEventsFor date: Date) -> Int {
        let count = birthdays.filter { 
            Calendar.current.component(.day, from: $0.dateValue) == Calendar.current.component(.day, from: date) &&
            Calendar.current.component(.month, from: $0.dateValue) == Calendar.current.component(.month, from: date) 
        }.count
        return count
    }

    // FSCalendarDelegate
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        selectedBirthdays = birthdays.filter { 
            Calendar.current.component(.day, from: $0.dateValue) == Calendar.current.component(.day, from: date) &&
            Calendar.current.component(.month, from: $0.dateValue) == Calendar.current.component(.month, from: date) 
        }
        tableView.reloadData()
    }

    // TableView DataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return selectedBirthdays.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "BirthdayCell", for: indexPath)
        let birthday = selectedBirthdays[indexPath.row]
        let comment = birthday.comment.isEmpty ? "" : " - \(birthday.comment)"
        cell.textLabel?.text = "\(birthday.name)\(comment)"
        return cell
    }
    

    // FSCalendarDelegateAppearance
    func calendar(_ calendar: FSCalendar, appearance: FSCalendarAppearance, titleDefaultColorFor date: Date) -> UIColor? {
        let numberOfBirthdays = birthdays.filter { 
            Calendar.current.component(.day, from: $0.dateValue) == Calendar.current.component(.day, from: date) &&
            Calendar.current.component(.month, from: $0.dateValue) == Calendar.current.component(.month, from: date) 
        }.count
        if numberOfBirthdays > 0 {
            return .red
        }
        return nil
    }

    func calendar(_ calendar: FSCalendar, appearance: FSCalendarAppearance, eventDefaultColorsFor date: Date) -> [UIColor]? {
        let numberOfBirthdays = birthdays.filter { 
            Calendar.current.component(.day, from: $0.dateValue) == Calendar.current.component(.day, from: date) &&
            Calendar.current.component(.month, from: $0.dateValue) == Calendar.current.component(.month, from: date) 
        }.count
        if numberOfBirthdays > 0 {
            return [.blue]
        }
        return nil
    }

    func calendar(_ calendar: FSCalendar, appearance: FSCalendarAppearance, eventSelectionColorsFor date: Date) -> [UIColor]? {
        let numberOfBirthdays = birthdays.filter { 
            Calendar.current.component(.day, from: $0.dateValue) == Calendar.current.component(.day, from: date) &&
            Calendar.current.component(.month, from: $0.dateValue) == Calendar.current.component(.month, from: date) 
        }.count
        if numberOfBirthdays > 0 {
            return [.blue]
        }
        return nil
    }

    // AddNewBirthdayVCDelegate Method
    func didAddBirthday() {
        // Firestore listener will automatically update the UI
    }
}
