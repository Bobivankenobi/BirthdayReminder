import Foundation
import FirebaseFirestore

// MARK: - Firestore Group Model
struct FirestoreGroup: Codable, Identifiable {
    @DocumentID var id: String?
    var name: String
    var icon: String
    var color: String
    var userId: String // Firebase User ID
    var createdAt: Timestamp
    var updatedAt: Timestamp
    
    init(name: String, icon: String, color: String, userId: String) {
        self.name = name
        self.icon = icon
        self.color = color
        self.userId = userId
        self.createdAt = Timestamp()
        self.updatedAt = Timestamp()
    }
}

// MARK: - Firestore Birthday Model
struct FirestoreBirthday: Codable, Identifiable {
    @DocumentID var id: String?
    var name: String
    var date: Timestamp
    var comment: String
    var groupId: String
    var userId: String // Firebase User ID
    var createdAt: Timestamp
    var updatedAt: Timestamp
    
    init(name: String, date: Date, comment: String, groupId: String, userId: String) {
        self.name = name
        self.date = Timestamp(date: date)
        self.comment = comment
        self.groupId = groupId
        self.userId = userId
        self.createdAt = Timestamp()
        self.updatedAt = Timestamp()
    }
    
    // Computed property to get Date from Timestamp
    var dateValue: Date {
        return date.dateValue()
    }
} 