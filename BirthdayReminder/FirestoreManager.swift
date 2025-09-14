import Foundation
import FirebaseFirestore
import Firebase
import Combine

class FirestoreManager: ObservableObject {
    static let shared = FirestoreManager()
    
    private let db = Firestore.firestore()
    private var cancellables = Set<AnyCancellable>()
    
    private init() {}
    
    // MARK: - Current User ID
    private var currentUserId: String? {
        return Auth.auth().currentUser?.uid
    }
    
    // MARK: - Groups Operations
    func createGroup(_ group: FirestoreGroup, completion: @escaping (Result<String, Error>) -> Void) {
        guard let userId = currentUserId else {
            completion(.failure(FirestoreError.userNotAuthenticated))
            return
        }
        
        var newGroup = group
        newGroup.userId = userId
        
        do {
            let docRef = try db.collection("groups").addDocument(from: newGroup)
            completion(.success(docRef.documentID))
        } catch {
            completion(.failure(error))
        }
    }
    
    func fetchGroups(completion: @escaping (Result<[FirestoreGroup], Error>) -> Void) {
        guard let userId = currentUserId else {
            completion(.failure(FirestoreError.userNotAuthenticated))
            return
        }
        
        db.collection("groups")
            .whereField("userId", isEqualTo: userId)
            .order(by: "createdAt")
            .getDocuments { snapshot, error in
                if let error = error {
                    completion(.failure(error))
                    return
                }
                
                let groups = snapshot?.documents.compactMap { document in
                    try? document.data(as: FirestoreGroup.self)
                } ?? []
                
                completion(.success(groups))
            }
    }
    
    func deleteGroup(_ groupId: String, completion: @escaping (Result<Void, Error>) -> Void) {
        guard let userId = currentUserId else {
            completion(.failure(FirestoreError.userNotAuthenticated))
            return
        }
        
        // Delete all birthdays in the group first
        db.collection("birthdays")
            .whereField("groupId", isEqualTo: groupId)
            .whereField("userId", isEqualTo: userId)
            .getDocuments { [weak self] snapshot, error in
                if let error = error {
                    completion(.failure(error))
                    return
                }
                
                let batch = self?.db.batch()
                snapshot?.documents.forEach { document in
                    batch?.deleteDocument(document.reference)
                }
                
                // Delete the group
                let groupRef = self?.db.collection("groups").document(groupId)
                if let groupRef = groupRef {
                    batch?.deleteDocument(groupRef)
                }
                
                batch?.commit { error in
                    if let error = error {
                        completion(.failure(error))
                    } else {
                        completion(.success(()))
                    }
                }
            }
    }
    
    // MARK: - FirestoreBirthdays Operations
    func createBirthday(_ birthday: FirestoreBirthday, completion: @escaping (Result<String, Error>) -> Void) {
        guard let userId = currentUserId else {
            completion(.failure(FirestoreError.userNotAuthenticated))
            return
        }
        
        var newFirestoreBirthday = birthday
        newFirestoreBirthday.userId = userId
        
        do {
            let docRef = try db.collection("birthdays").addDocument(from: newFirestoreBirthday)
            completion(.success(docRef.documentID))
        } catch {
            completion(.failure(error))
        }
    }
    
    func fetchBirthdays(for groupId: String, completion: @escaping (Result<[FirestoreBirthday], Error>) -> Void) {
        guard let userId = currentUserId else {
            completion(.failure(FirestoreError.userNotAuthenticated))
            return
        }
        
        db.collection("birthdays")
            .whereField("groupId", isEqualTo: groupId)
            .whereField("userId", isEqualTo: userId)
            .order(by: "date")
            .getDocuments { snapshot, error in
                if let error = error {
                    completion(.failure(error))
                    return
                }
                
                let birthdays = snapshot?.documents.compactMap { document in
                    try? document.data(as: FirestoreBirthday.self)
                } ?? []
                
                completion(.success(birthdays))
            }
    }
    
    func fetchAllBirthdays(completion: @escaping (Result<[FirestoreBirthday], Error>) -> Void) {
        guard let userId = currentUserId else {
            completion(.failure(FirestoreError.userNotAuthenticated))
            return
        }
        
        db.collection("birthdays")
            .whereField("userId", isEqualTo: userId)
            .order(by: "date")
            .getDocuments { snapshot, error in
                if let error = error {
                    completion(.failure(error))
                    return
                }
                
                let birthdays = snapshot?.documents.compactMap { document in
                    try? document.data(as: FirestoreBirthday.self)
                } ?? []
                
                completion(.success(birthdays))
            }
    }
    
    func deleteBirthday(_ birthdayId: String, completion: @escaping (Result<Void, Error>) -> Void) {
        db.collection("birthdays").document(birthdayId).delete { error in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success(()))
            }
        }
    }
    
    // MARK: - Real-time Listeners
    func listenToGroups(completion: @escaping (Result<[FirestoreGroup], Error>) -> Void) -> ListenerRegistration? {
        guard let userId = currentUserId else {
            completion(.failure(FirestoreError.userNotAuthenticated))
            return nil
        }
        
        return db.collection("groups")
            .whereField("userId", isEqualTo: userId)
            .order(by: "createdAt")
            .addSnapshotListener { snapshot, error in
                if let error = error {
                    completion(.failure(error))
                    return
                }
                
                let groups = snapshot?.documents.compactMap { document in
                    try? document.data(as: FirestoreGroup.self)
                } ?? []
                
                completion(.success(groups))
            }
    }
    
    func listenToBirthdays(for groupId: String, completion: @escaping (Result<[FirestoreBirthday], Error>) -> Void) -> ListenerRegistration? {
        guard let userId = currentUserId else {
            completion(.failure(FirestoreError.userNotAuthenticated))
            return nil
        }
        
        return db.collection("birthdays")
            .whereField("groupId", isEqualTo: groupId)
            .whereField("userId", isEqualTo: userId)
            .order(by: "date")
            .addSnapshotListener { snapshot, error in
                if let error = error {
                    completion(.failure(error))
                    return
                }
                
                let birthdays = snapshot?.documents.compactMap { document in
                    try? document.data(as: FirestoreBirthday.self)
                } ?? []
                
                completion(.success(birthdays))
            }
    }
}

// MARK: - Custom Errors
enum FirestoreError: LocalizedError {
    case userNotAuthenticated
    
    var errorDescription: String? {
        switch self {
        case .userNotAuthenticated:
            return "User is not authenticated"
        }
    }
} 