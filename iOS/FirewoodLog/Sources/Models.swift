import Foundation

struct FirewoodLogItem: Identifiable, Codable, Equatable {
    var id: UUID = UUID()
    var stackLocation: String
    var cordAmount: String
    var deliveryDate: String
    var createdAt: Date = Date()
}
