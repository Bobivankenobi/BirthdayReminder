import Foundation
import Firebase
import GoogleSignIn
import UIKit
import Combine

class AuthenticationManager: ObservableObject {
    static let shared = AuthenticationManager()
    
    @Published var isAuthenticated = false
    @Published var currentUser: User?
    
    private init() {
        // Check if user is already authenticated
        if let user = Auth.auth().currentUser {
            self.currentUser = user
            self.isAuthenticated = true
        }
        
        // Listen for authentication state changes
        Auth.auth().addStateDidChangeListener { [weak self] _, user in
            DispatchQueue.main.async {
                self?.currentUser = user
                self?.isAuthenticated = user != nil
            }
        }
    }
    
    func signInWithGoogle(presentingViewController: UIViewController, completion: @escaping (Result<User, Error>) -> Void) {
        guard let clientID = FirebaseApp.app()?.options.clientID else {
            completion(.failure(AuthError.missingClientID))
            return
        }
        
        // Configure Google Sign-In
        let config = GIDConfiguration(clientID: clientID)
        GIDSignIn.sharedInstance.configuration = config
        
        // Start the sign in flow
        GIDSignIn.sharedInstance.signIn(withPresenting: presentingViewController) { [weak self] result, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let user = result?.user,
                  let idToken = user.idToken?.tokenString else {
                completion(.failure(AuthError.invalidToken))
                return
            }
            
            let credential = GoogleAuthProvider.credential(withIDToken: idToken,
                                                         accessToken: user.accessToken.tokenString)
            
            // Sign in to Firebase with Google credential
            Auth.auth().signIn(with: credential) { authResult, error in
                if let error = error {
                    completion(.failure(error))
                    return
                }
                
                if let firebaseUser = authResult?.user {
                    DispatchQueue.main.async {
                        self?.currentUser = firebaseUser
                        self?.isAuthenticated = true
                    }
                    completion(.success(firebaseUser))
                } else {
                    completion(.failure(AuthError.signInFailed))
                }
            }
        }
    }
    
    func signOut() {
        do {
            try Auth.auth().signOut()
            GIDSignIn.sharedInstance.signOut()
            DispatchQueue.main.async {
                self.currentUser = nil
                self.isAuthenticated = false
            }
        } catch {
            print("Error signing out: \(error.localizedDescription)")
        }
    }
}

enum AuthError: LocalizedError {
    case missingClientID
    case invalidToken
    case signInFailed
    
    var errorDescription: String? {
        switch self {
        case .missingClientID:
            return "Missing Google Client ID"
        case .invalidToken:
            return "Invalid authentication token"
        case .signInFailed:
            return "Sign in failed"
        }
    }
} 