import Foundation
import Combine

class DreamKitService: ObservableObject {
    static let shared = DreamKitService()
    
    @Published var availableKits: [DreamKit] = []
    
    private let storageKey = "dreamroom.purchasedKits"
    
    private init() {
        loadKits()
    }
    
    private func loadKits() {
        let metadataPath = "/home/team/shared/assets/dream-kits/metadata.json"
        
        var kits: [DreamKit] = []
        
        if let data = try? Data(contentsOf: URL(fileURLWithPath: metadataPath)),
           let jsonArray = try? JSONSerialization.jsonObject(with: data) as? [[String: Any]] {
            
            kits = jsonArray.compactMap { dict in
                guard let id = dict["id"] as? String,
                      let name = dict["name"] as? String,
                      let description = dict["description"] as? String,
                      let priceValue = dict["price"] as? Double,
                      let coverImage = dict["cover_image"] as? String,
                      let assets = dict["assets"] as? [String] else {
                    return nil
                }
                
                return DreamKit(
                    id: id,
                    name: name,
                    description: description,
                    price: "$\(priceValue)",
                    coverImageName: coverImage,
                    assets: assets
                )
            }
        } else {
            // Fallback to internal mock if file not found
            kits = [
                DreamKit(
                    id: "sanctuary-pack",
                    name: "The Sanctuary Pack",
                    description: "Calm, ethereal textures and soft minimalist elements for a peaceful vision.",
                    price: "$2.99",
                    coverImageName: "dream-01",
                    assets: ["sanctuary_01", "sanctuary_02", "sanctuary_03"]
                ),
                DreamKit(
                    id: "urban-vision",
                    name: "Urban Vision",
                    description: "Bold typography, neon accents, and high-contrast architectural shots.",
                    price: "$1.99",
                    coverImageName: "dream-02",
                    assets: ["urban_01", "urban_02", "urban_03"]
                ),
                DreamKit(
                    id: "manifest-gold",
                    name: "Manifest Gold",
                    description: "Rich metallic textures and crystalline structures for high-value manifestations.",
                    price: "$3.99",
                    coverImageName: "dream-03",
                    assets: ["gold_01", "gold_02", "gold_03"]
                )
            ]
        }
        
        // Check local storage for purchased state
        let purchasedIds = getPurchasedKitIds()
        availableKits = kits.map { kit in
            var updatedKit = kit
            if purchasedIds.contains(kit.id) { // Using id now
                updatedKit.isPurchased = true
            }
            return updatedKit
        }
    }
    
    func purchaseKit(kitId: String) {
        if let index = availableKits.firstIndex(where: { $0.id == kitId }) {
            // Simulate purchase logic
            availableKits[index].isPurchased = true
            savePurchase(kitId: availableKits[index].id)
            
            // Track analytics
            AnalyticsService.shared.track(.kitPurchased(kitId: kitId, name: availableKits[index].name))
        }
    }
    
    private func savePurchase(kitId: String) {
        var purchased = getPurchasedKitIds()
        purchased.insert(kitId)
        UserDefaults.standard.set(Array(purchased), forKey: storageKey)
    }
    
    private func getPurchasedKitIds() -> Set<String> {
        let array = UserDefaults.standard.stringArray(forKey: storageKey) ?? []
        return Set(array)
    }
    
    func getUnlockedAssets() -> [String] {
        return availableKits.filter { $0.isPurchased }.flatMap { $0.assets }
    }
}
