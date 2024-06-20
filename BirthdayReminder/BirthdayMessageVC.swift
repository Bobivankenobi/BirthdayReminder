import UIKit

class BirthdayMessageVC: UIViewController {

    var messageLabel: UILabel!
    var titleLabel: UILabel!
    var cakeImageView: UIImageView!
    var spinner: UIActivityIndicatorView!

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupTitleLabel()
        setupCakeImageView()
        setupMessageLabel()
        setupSpinner()
        fetchBirthdayMessage()
    }

    
    private func setupTitleLabel() {
        titleLabel = UILabel()
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.text = "Birthday Message"
        titleLabel.textAlignment = .center
        titleLabel.font = UIFont.boldSystemFont(ofSize: 24)
        titleLabel.textColor = .systemBlue
        view.addSubview(titleLabel)

        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }

    private func setupCakeImageView() {
        cakeImageView = UIImageView()
        cakeImageView.translatesAutoresizingMaskIntoConstraints = false
        cakeImageView.image = UIImage(systemName: "birthday.cake")
        cakeImageView.tintColor = .systemPink
        view.addSubview(cakeImageView)

        NSLayoutConstraint.activate([
            cakeImageView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 20),
            cakeImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            cakeImageView.widthAnchor.constraint(equalToConstant: 50),
            cakeImageView.heightAnchor.constraint(equalToConstant: 50)
        ])
    }

    private func setupMessageLabel() {
        messageLabel = UILabel()
        messageLabel.translatesAutoresizingMaskIntoConstraints = false
        messageLabel.numberOfLines = 0
        messageLabel.textAlignment = .center
        messageLabel.font = UIFont.boldSystemFont(ofSize: 18)
        messageLabel.textColor = .darkGray
        view.addSubview(messageLabel)

        NSLayoutConstraint.activate([
            messageLabel.topAnchor.constraint(equalTo: cakeImageView.bottomAnchor, constant: 20),
            messageLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            messageLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20)
        ])
    }

    private func setupSpinner() {
        spinner = UIActivityIndicatorView(style: .large)
        spinner.translatesAutoresizingMaskIntoConstraints = false
        spinner.startAnimating()
        view.addSubview(spinner)

        NSLayoutConstraint.activate([
            spinner.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            spinner.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }

    private func fetchBirthdayMessage() {
        let url = URL(string: "https://ajith-messages.p.rapidapi.com/getMsgs?category=birthday")!
        var request = URLRequest(url: url)
        request.addValue("ajith-messages.p.rapidapi.com", forHTTPHeaderField: "x-rapidapi-host")
        request.addValue("8a8d6c543fmshe5f5909c85bf67fp1cd0b9jsn3d900afd46b5", forHTTPHeaderField: "x-rapidapi-key")

        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                self.spinner.stopAnimating()
            }

            if let error = error {
                print("Error fetching message: \(error)")
                return
            }

            guard let data = data else {
                print("No data returned")
                return
            }

            do {
                if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                   let message = json["Message"] as? String {
                    DispatchQueue.main.async {
                        self.messageLabel.text = message
                    }
                }
            } catch {
                print("Error parsing JSON: \(error)")
            }
        }

        task.resume()
    }
}
