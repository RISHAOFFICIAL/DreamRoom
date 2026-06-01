import Foundation

struct Clip: Identifiable, Codable {
    let id: UUID
    let imageUrl: String // URL string or Asset name
    let sourceUrl: URL?
    let createdAt: Date
    
    init(id: UUID = UUID(), imageUrl: String, sourceUrl: URL? = nil, createdAt: Date = Date()) {
        self.id = id
        self.imageUrl = imageUrl
        self.sourceUrl = sourceUrl
        self.createdAt = createdAt
    }
}
