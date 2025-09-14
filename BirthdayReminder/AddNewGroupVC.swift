import UIKit
import CoreData

protocol AddNewGroupVCDelegate: AnyObject {
    func didAddGroup()
}

class AddNewGroupVC: UIViewController, IconPickerVCDelegate, ColorPickerVCDelegate {

    weak var delegate: AddNewGroupVCDelegate?
    var managedContext: NSManagedObjectContext!
    var selectedIcon: String = "figure.walk" // default icon
    var selectedColor: UIColor = .red // default color

    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Create New Birthday Group2xxx"
        label.font = UIFont.boldSystemFont(ofSize: 24)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let fireworksImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "sparkles")
        imageView.tintColor = .systemOrange
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

    private let iconLabel: UILabel = {
        let label = UILabel()
        label.text = "Icon"
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let tagColorLabel: UILabel = {
        let label = UILabel()
        label.text = "Tag color"
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let iconButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "figure.walk"), for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(pickIcon), for: .touchUpInside)
        return button
    }()

    private let tagColorButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "circle.fill"), for: .normal)
        button.tintColor = .red
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(pickColor), for: .touchUpInside)
        return button
    }()

    private let createButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Create", for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(createGroup), for: .touchUpInside)
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
        view.addSubview(fireworksImageView)
        view.addSubview(nameTextField)
        view.addSubview(iconLabel)
        view.addSubview(tagColorLabel)
        view.addSubview(iconButton)
        view.addSubview(tagColorButton)
        view.addSubview(createButton)

        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            fireworksImageView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 20),
            fireworksImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            fireworksImageView.widthAnchor.constraint(equalToConstant: 50),
            fireworksImageView.heightAnchor.constraint(equalToConstant: 50),

            nameTextField.topAnchor.constraint(equalTo: fireworksImageView.bottomAnchor, constant: 20),
            nameTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            nameTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            iconLabel.topAnchor.constraint(equalTo: nameTextField.bottomAnchor, constant: 20),
            iconLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            
            iconButton.centerYAnchor.constraint(equalTo: iconLabel.centerYAnchor),
            iconButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            tagColorLabel.topAnchor.constraint(equalTo: iconLabel.bottomAnchor, constant: 20),
            tagColorLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            
            tagColorButton.centerYAnchor.constraint(equalTo: tagColorLabel.centerYAnchor),
            tagColorButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            createButton.topAnchor.constraint(equalTo: tagColorLabel.bottomAnchor, constant: 40),
            createButton.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }

    @objc private func pickIcon() {
        let iconPickerVC = IconPickerVC()
        iconPickerVC.delegate = self
        iconPickerVC.modalPresentationStyle = .pageSheet
        if let sheet = iconPickerVC.sheetPresentationController {
            sheet.detents = [.medium(), .large()]
            sheet.prefersGrabberVisible = true
            sheet.preferredCornerRadius = 16
        }
        present(iconPickerVC, animated: true, completion: nil)
    }

    @objc private func pickColor() {
        let colorPickerVC = ColorPickerVC()
        colorPickerVC.delegate = self
        colorPickerVC.modalPresentationStyle = .pageSheet
        if let sheet = colorPickerVC.sheetPresentationController {
            sheet.detents = [.medium(), .large()]
            sheet.prefersGrabberVisible = true
            sheet.preferredCornerRadius = 16
        }
        present(colorPickerVC, animated: true, completion: nil)
    }

    @objc private func createGroup() {
        let name = nameTextField.text ?? "No Name"
        let icon = selectedIcon
        let color = selectedColor.toHexString()

        let group = Group(context: managedContext)
        group.name = name
        group.icon = icon
        group.color = color

        do {
            try managedContext.save()
            print("Group saved successfully!")
            delegate?.didAddGroup()
        } catch let error as NSError {
            print("Could not save group. \(error), \(error.userInfo)")
        }
        
        dismiss(animated: true, completion: nil)
    }

    // IconPickerVCDelegate Method
    func didSelectIcon(icon: String) {
        selectedIcon = icon
        iconButton.setImage(UIImage(systemName: icon), for: .normal)
    }

    // ColorPickerVCDelegate Method
    func didSelectColor(color: UIColor) {
        selectedColor = color
        tagColorButton.tintColor = color
    }
}

extension UIColor {
    func toHexString() -> String {
        var r: CGFloat = 0
        var g: CGFloat = 0
        var b: CGFloat = 0
        var a: CGFloat = 0

        getRed(&r, green: &g, blue: &b, alpha: &a)

        let rgb = (Int)(r * 255) << 16 | (Int)(g * 255) << 8 | (Int)(b * 255) << 0

        return String(format: "#%06x", rgb)
    }

    static func fromHexString(_ hex: String) -> UIColor? {
        var hexFormatted = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()

        if hexFormatted.hasPrefix("#") {
            hexFormatted.remove(at: hexFormatted.startIndex)
        }

        guard hexFormatted.count == 6 else {
            return nil
        }

        var rgbValue: UInt64 = 0
        Scanner(string: hexFormatted).scanHexInt64(&rgbValue)

        return UIColor(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: 1.0
        )
    }
}
