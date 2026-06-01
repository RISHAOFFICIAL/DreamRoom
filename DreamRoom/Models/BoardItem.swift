import Foundation
import SwiftUI

struct BoardItem: Identifiable, Codable, Equatable {
    let id: UUID
    var imageUrl: String?
    var text: String?
    
    var position: CGPoint
    var rotation: Angle
    var scale: CGFloat
    
    // For tactile interaction states
    var zIndex: Double = 0
    
    static func == (lhs: BoardItem, rhs: BoardItem) -> Bool {
        lhs.id == rhs.id &&
        lhs.imageUrl == rhs.imageUrl &&
        lhs.text == rhs.text &&
        lhs.position == rhs.position &&
        lhs.rotation == rhs.rotation &&
        lhs.scale == rhs.scale
    }
    
    init(id: UUID = UUID(), imageUrl: String? = nil, text: String? = nil, position: CGPoint = .zero, rotation: Angle = .zero, scale: CGFloat = 1.0) {
        self.id = id
        self.imageUrl = imageUrl
        self.text = text
        self.position = position
        self.rotation = rotation
        self.scale = scale
    }
    
    enum CodingKeys: String, CodingKey {
        case id, imageUrl, text, position, rotation, scale
    }
}

extension Angle: Codable {
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let degrees = try container.decode(Double.self)
        self.init(degrees: degrees)
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(degrees)
    }
}
