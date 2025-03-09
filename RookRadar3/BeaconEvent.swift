import Foundation
import SwiftData

@Model
class BeaconEvent {
    @Attribute(.primaryKey) var id: UUID = UUID() // Unique identifier
    var timestamp: Date
    var message: String

    init(timestamp: Date, message: String) {
        self.timestamp = timestamp
        self.message = message
    }
}