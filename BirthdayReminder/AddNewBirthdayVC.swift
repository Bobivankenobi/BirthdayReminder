import UIKit
import CoreData
import FirebaseFirestore
import FirebaseAuth

protocol AddNewBirthdayVCDelegate: AnyObject {
    func didAddBirthday()
}

class AddNewBirthdayVC: UIViewController {

    weak var delegate: AddNewBirthdayVCDelegate?
    var managedContext: NSManagedObjectContext! // Keep for migration
    var group: Group? // Keep for Core Data compatibility
    var firestoreGroup: FirestoreGroup?
    private let firestoreManager = FirestoreManager.shared

    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Create New Birthday"
        label.font = UIFont.boldSystemFont(ofSize: 24)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let cakeImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "birthday.cake.fill")
        imageView.tintColor = .systemPink
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let nameTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Name"
        textField.borderStyle = .roundedRect
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()

    private let datePicker: UIDatePicker = {
        let datePicker = UIDatePicker()
        datePicker.datePickerMode = .date
        datePicker.translatesAutoresizingMaskIntoConstraints = false
        return datePicker
    }()

    private let commentTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Comment"
        textField.borderStyle = .roundedRect
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()

    private let createButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Create", for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(createBirthday), for: .touchUpInside)
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupView()
    }

    private func setupView() {
        view.layer.cornerRadius = 16
        view.clipsToBounds = true
        
        view.addSubview(titleLabel)
        view.addSubview(cakeImageView)
        view.addSubview(nameTextField)
        view.addSubview(datePicker)
        view.addSubview(commentTextField)
        view.addSubview(createButton)

        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            cakeImageView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 20),
            cakeImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            cakeImageView.widthAnchor.constraint(equalToConstant: 50),
            cakeImageView.heightAnchor.constraint(equalToConstant: 50),

            nameTextField.topAnchor.constraint(equalTo: cakeImageView.bottomAnchor, constant: 20),
            nameTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            nameTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),

            datePicker.topAnchor.constraint(equalTo: nameTextField.bottomAnchor, constant: 20),
            datePicker.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            datePicker.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),

            commentTextField.topAnchor.constraint(equalTo: datePicker.bottomAnchor, constant: 20),
            commentTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            commentTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),

            createButton.topAnchor.constraint(equalTo: commentTextField.bottomAnchor, constant: 40),
            createButton.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }

    @objc private func createBirthday() {
        let name = nameTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let date = datePicker.date
        let comment = commentTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        
        guard !name.isEmpty else {
            showErrorAlert("Please enter a birthday name")
            return
        }
        
        guard let userId = Auth.auth().currentUser?.uid else {
            showErrorAlert("User not authenticated")
            return
        }
        
        guard let groupId = firestoreGroup?.id else {
            showErrorAlert("No group selected")
            return
        }

        let birthday = FirestoreBirthday(name: name, date: date, comment: comment, groupId: groupId, userId: userId)

        firestoreManager.createBirthday(birthday) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(_):
                    print("Birthday saved successfully!")
                    self?.delegate?.didAddBirthday()
                    self?.dismiss(animated: true, completion: nil)
                case .failure(let error):
                    print("Could not save birthday. \(error)")
                    self?.showErrorAlert("Failed to create birthday: \(error.localizedDescription)")
                }
            }
        }
    }
    
    private func showErrorAlert(_ message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}
