import UIKit

class GroupCell: UITableViewCell {
    var deleteButton: UIButton!
    var deleteAction: (() -> Void)?

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupDeleteButton()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupDeleteButton() {
        deleteButton = UIButton(type: .system)
        deleteButton.setImage(UIImage(systemName: "trash"), for: .normal)
        deleteButton.tintColor = .red
        deleteButton.translatesAutoresizingMaskIntoConstraints = false
        deleteButton.addTarget(self, action: #selector(deleteButtonTapped), for: .touchUpInside)
        contentView.addSubview(deleteButton)

        NSLayoutConstraint.activate([
            deleteButton.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            deleteButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20)
        ])
    }

    @objc private func deleteButtonTapped() {
        deleteAction?()
    }

    func configure(with group: FirestoreGroup, birthdayCount: Int, deleteAction: @escaping () -> Void) {
        textLabel?.text = "\(group.name) (\(birthdayCount))"
        imageView?.image = UIImage(systemName: group.icon)
        imageView?.tintColor = UIColor.fromHexString(group.color)
        self.deleteAction = deleteAction
    }
    
    
}

