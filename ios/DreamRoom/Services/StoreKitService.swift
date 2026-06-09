import Foundation
import StoreKit

class StoreKitService: ObservableObject {
    static let shared = StoreKitService()
    
    @Published var purchasedProductIdentifiers = Set<String>()
    
    private let storageKey = "dreamroom.purchasedProducts"
    
    private init() {
        loadPurchasedProducts()
    }
    
    private func loadPurchasedProducts() {
        let saved = UserDefaults.standard.stringArray(forKey: storageKey) ?? []
        purchasedProductIdentifiers = Set(saved)
    }
    
    func purchase(productIdentifier: String, completion: @escaping (Bool) -> Void) {
        // Mock purchase process
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            self.purchasedProductIdentifiers.insert(productIdentifier)
            self.savePurchasedProducts()
            completion(true)
        }
    }
    
    func isPurchased(_ identifier: String) -> Bool {
        return purchasedProductIdentifiers.contains(identifier)
    }
    
    private func savePurchasedProducts() {
        UserDefaults.standard.set(Array(purchasedProductIdentifiers), forKey: storageKey)
    }
    
    func restorePurchases(completion: @escaping (Bool) -> Void) {
        // Mock restore
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            completion(true)
        }
    }
}
