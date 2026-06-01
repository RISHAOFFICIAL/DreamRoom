import Foundation

struct DreamKit: Identifiable, Codable {
    let id: String
    let name: String
    let description: String
    let price: String
    let coverImageName: String
    let assets: [String] // Asset names or URLs
    var isPurchased: Bool
    
    init(id: String, name: String, description: String, price: String, coverImageName: String, assets: [String], isPurchased: Bool = false) {
        self.id = id
        self.name = name
        self.description = description
        self.price = price
        self.coverImageName = coverImageName
        self.assets = assets
        self.isPurchased = isPurchased
    }
}
