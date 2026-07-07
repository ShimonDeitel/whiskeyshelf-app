import Foundation

struct BottleItem: Identifiable, Codable, Equatable {
    var id: UUID = UUID()
    var name: String
    var distillery: String
    var fillLevel: String
    var notes: String = ""
    var dateAdded: Date = Date()
}
