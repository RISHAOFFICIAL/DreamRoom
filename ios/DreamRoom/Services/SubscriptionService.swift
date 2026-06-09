import Foundation
import Combine

enum SubscriptionLevel: String, Codable {
    case free
    case builder
}

class SubscriptionService: ObservableObject {
    static let shared = SubscriptionService()
    
    @Published var currentLevel: SubscriptionLevel = .free
    @Published var isPurchasing = false
    
    private let storageKey = "dreamroom.subscriptionLevel"
    
    private init() {
        loadSubscription()
    }
    
    private func loadSubscription() {
        if let saved = UserDefaults.standard.string(forKey: storageKey),
           let level = SubscriptionLevel(rawValue: saved) {
            currentLevel = level
        }
    }
    
    func purchaseBuilderPlan() {
        isPurchasing = true
        
        // Simulate network delay for purchase
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            self.currentLevel = .builder
            UserDefaults.standard.set(SubscriptionLevel.builder.rawValue, forKey: self.storageKey)
            self.isPurchasing = false
            
            // Track analytics
            AnalyticsService.shared.track(.subscriptionStarted(level: "builder"))
        }
    }
    
    func cancelSubscription() {
        currentLevel = .free
        UserDefaults.standard.set(SubscriptionLevel.free.rawValue, forKey: storageKey)
    }
    
    var canHostUnlimitedGatherings: Bool {
        return currentLevel == .builder
    }
    
    var hasLuxuryAssetAccess: Bool {
        return currentLevel == .builder
    }
}
