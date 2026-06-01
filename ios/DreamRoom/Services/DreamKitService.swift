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
        // Mock data for available kits
        let kits = [
            DreamKit(
                name: "The Sanctuary Pack",
                description: "Calm, ethereal textures and soft minimalist elements for a peaceful vision.",
                price: "$2.99",
                coverImageName: "dream-01",
                assets: ["sanctuary_01", "sanctuary_02", "sanctuary_03"]
            ),
            DreamKit(
                name: "Urban Vision",
                description: "Bold typography, neon accents, and high-contrast architectural shots.",
                price: "$1.99",
                coverImageName: "dream-02",
                assets: ["urban_01", "urban_02", "urban_03"]
            ),
            DreamKit(
                name: "Manifest Gold",
                description: "Rich metallic textures and crystalline structures for high-value manifestations.",
                price: "$3.99",
                coverImageName: "dream-03",
                assets: ["gold_01", "gold_02", "gold_03"]
            )
        ]
        
        // Check local storage for purchased state
        let purchasedIds = getPurchasedKitIds()
        availableKits = kits.map { kit in
            var updatedKit = kit
            if purchasedIds.contains(kit.name) { // Using name as a simple key for mock
                updatedKit.isPurchased = true
            }
            return updatedKit
        }
    }
    
    func purchaseKit(kitId: UUID) {
        if let index = availableKits.firstIndex(where: { $0.id == kitId }) {
            // Simulate purchase logic
            availableKits[index].isPurchased = true
            savePurchase(kitName: availableKits[index].name)
            
            // Track analytics
            AnalyticsService.shared.track(.kitPurchased(kitId: kitId, name: availableKits[index].name))
        }
    }
    
    private func savePurchase(kitName: String) {
        var purchased = getPurchasedKitIds()
        purchased.insert(kitName)
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
