import UIKit
import FSCalendar
import CoreData

class CalendarVC: UIViewController, FSCalendarDelegate, FSCalendarDataSource, UITableViewDelegate, UITableViewDataSource, AddNewBirthdayVCDelegate {

    var calendar: FSCalendar!
    var tableView: UITableView!
    var birthdays: [Birthday] = []
    var selectedBirthdays: [Birthday] = []

    var managedContext: NSManagedObjectContext!

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        navigationItem.title = "Calendar"

        setupCalendar()
        setupTableView()
        fetchBirthdays()
        
        // Add observers for notifications
        NotificationCenter.default.addObserver(self, selector: #selector(fetchBirthdays), name: NSNotification.Name("BirthdayAdded"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(fetchBirthdays), name: NSNotification.Name("BirthdayDeleted"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(fetchBirthdays), name: NSNotification.Name("GroupDeleted"), object: nil)
    }

    deinit {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name("BirthdayAdded"), object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name("BirthdayDeleted"), object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name("GroupDeleted"), object: nil)
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

    @objc private func fetchBirthdays() {
        let fetchRequest: NSFetchRequest<Birthday> = Birthday.fetchRequest()
        do {
            birthdays = try managedContext.fetch(fetchRequest)
            print("Birthdays fetched: \(birthdays.count)")
            calendar.reloadData()
            tableView.reloadData() // Ensuring table view also updates
        } catch let error as NSError {
            print("Could not fetch birthdays. \(error), \(error.userInfo)")
        }
    }

    // FSCalendarDataSource
    func calendar(_ calendar: FSCalendar, numberOfEventsFor date: Date) -> Int {
        let count = birthdays.filter { Calendar.current.component(.day, from: $0.date!) == Calendar.current.component(.day, from: date) &&
            Calendar.current.component(.month, from: $0.date!) == Calendar.current.component(.month, from: date) }.count
        return count
    }

    // FSCalendarDelegate
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        selectedBirthdays = birthdays.filter { Calendar.current.component(.day, from: $0.date!) == Calendar.current.component(.day, from: date) &&
            Calendar.current.component(.month, from: $0.date!) == Calendar.current.component(.month, from: date) }
        tableView.reloadData()
    }

    // TableView DataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return selectedBirthdays.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "BirthdayCell", for: indexPath)
        let birthday = selectedBirthdays[indexPath.row]
        cell.textLabel?.text = "\(birthday.name ?? "No Name") - \(birthday.comment ?? "")"
        return cell
    }

    // FSCalendarDelegateAppearance
    func calendar(_ calendar: FSCalendar, appearance: FSCalendarAppearance, titleDefaultColorFor date: Date) -> UIColor? {
        let numberOfBirthdays = birthdays.filter { Calendar.current.component(.day, from: $0.date!) == Calendar.current.component(.day, from: date) &&
            Calendar.current.component(.month, from: $0.date!) == Calendar.current.component(.month, from: date) }.count
        if numberOfBirthdays > 0 {
            return .red
        }
        return nil
    }

    func calendar(_ calendar: FSCalendar, appearance: FSCalendarAppearance, eventDefaultColorsFor date: Date) -> [UIColor]? {
        let numberOfBirthdays = birthdays.filter { Calendar.current.component(.day, from: $0.date!) == Calendar.current.component(.day, from: date) &&
            Calendar.current.component(.month, from: $0.date!) == Calendar.current.component(.month, from: date) }.count
        if numberOfBirthdays > 0 {
            return [.blue]
        }
        return nil
    }

    func calendar(_ calendar: FSCalendar, appearance: FSCalendarAppearance, eventSelectionColorsFor date: Date) -> [UIColor]? {
        let numberOfBirthdays = birthdays.filter { Calendar.current.component(.day, from: $0.date!) == Calendar.current.component(.day, from: date) &&
            Calendar.current.component(.month, from: $0.date!) == Calendar.current.component(.month, from: date) }.count
        if numberOfBirthdays > 0 {
            return [.blue]
        }
        return nil
    }

    // AddNewBirthdayVCDelegate Method
    func didAddBirthday() {
        print("Delegate method didAddBirthday called 2")
        fetchBirthdays()
    }
}
