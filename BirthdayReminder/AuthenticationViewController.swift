import UIKit
import Firebase
import GoogleSignIn

class AuthenticationViewController: UIViewController {
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Birthday Reminder"
        label.font = UIFont.boldSystemFont(ofSize: 32)
        label.textAlignment = .center
        label.textColor = .systemBlue
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let subtitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Keep track of all your loved ones' birthdays"
        label.font = UIFont.systemFont(ofSize: 16)
        label.textAlignment = .center
        label.textColor = .systemGray
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let birthdayImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "gift.fill")
        imageView.tintColor = .systemPink
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let googleSignInButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Continue with Google", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .systemBlue
        button.layer.cornerRadius = 25
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let loadingIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.hidesWhenStopped = true
        indicator.translatesAutoresizingMaskIntoConstraints = false
        return indicator
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupConstraints()
        setupActions()
    }
    
    private func setupUI() {
        view.backgroundColor = .systemBackground
        
        view.addSubview(titleLabel)
        view.addSubview(subtitleLabel)
        view.addSubview(birthdayImageView)
        view.addSubview(googleSignInButton)
        view.addSubview(loadingIndicator)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            // Birthday Image
            birthdayImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            birthdayImageView.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -100),
            birthdayImageView.widthAnchor.constraint(equalToConstant: 80),
            birthdayImageView.heightAnchor.constraint(equalToConstant: 80),
            
            // Title Label
            titleLabel.topAnchor.constraint(equalTo: birthdayImageView.bottomAnchor, constant: 30),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 40),
            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -40),
            
            // Subtitle Label
            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 16),
            subtitleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 40),
            subtitleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -40),
            
            // Google Sign In Button
            googleSignInButton.topAnchor.constraint(equalTo: subtitleLabel.bottomAnchor, constant: 60),
            googleSignInButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 40),
            googleSignInButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -40),
            googleSignInButton.heightAnchor.constraint(equalToConstant: 50),
            
            // Loading Indicator
            loadingIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            loadingIndicator.topAnchor.constraint(equalTo: googleSignInButton.bottomAnchor, constant: 20)
        ])
    }
    
    private func setupActions() {
        googleSignInButton.addTarget(self, action: #selector(googleSignInTapped), for: .touchUpInside)
    }
    
    @objc private func googleSignInTapped() {
        startLoading()
        
        AuthenticationManager.shared.signInWithGoogle(presentingViewController: self) { [weak self] result in
            DispatchQueue.main.async {
                self?.stopLoading()
                
                switch result {
                case .success(let user):
                    print("Successfully signed in user: \(user.displayName ?? "Unknown")")
                    self?.navigateToMainApp()
                case .failure(let error):
                    self?.showError(error.localizedDescription)
                }
            }
        }
    }
    
    private func startLoading() {
        googleSignInButton.isEnabled = false
        googleSignInButton.alpha = 0.6
        loadingIndicator.startAnimating()
    }
    
    private func stopLoading() {
        googleSignInButton.isEnabled = true
        googleSignInButton.alpha = 1.0
        loadingIndicator.stopAnimating()
    }
    
    private func showError(_ message: String) {
        let alert = UIAlertController(title: "Authentication Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    private func navigateToMainApp() {
        // This will be handled by SceneDelegate listening to AuthenticationManager
    }
} 