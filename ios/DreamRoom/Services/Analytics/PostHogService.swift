import Foundation

/**
 * Note: This service is a wrapper around the PostHog SDK.
 * In a real environment, you would add PostHog-iOS via Swift Package Manager.
 */

// Mock PostHog for compilation if SDK is not present
#if canImport(PostHog)
import PostHog
#else
class PostHogSDK {
    static let shared = PostHogSDK()
    func setup(_ config: PostHogConfig) {}
    func capture(_ event: String, properties: [String: Any]? = nil) {
        print("[PostHog Mock] Capturing event: \(event) with properties: \(String(describing: properties))")
    }
    func identify(_ distinctId: String, userProperties: [String: Any]? = nil) {
        print("[PostHog Mock] Identifying user: \(distinctId)")
    }
}
struct PostHogConfig {
    init(apiKey: String, host: String) {}
}
#endif

class AnalyticsService {
    static let shared = AnalyticsService()
    
    private init() {
        // Initialize PostHog
        // In production, these would be in a Config.plist or Environment Variable
        let apiKey = "phc_mock_api_key"
        let host = "https://app.posthog.com"
        
        #if !canImport(PostHog)
        let config = PostHogConfig(apiKey: apiKey, host: host)
        PostHogSDK.shared.setup(config)
        #endif
    }
    
    func track(_ event: DreamRoomEvent) {
        #if canImport(PostHog)
        PostHogSDK.shared.capture(event.name, properties: event.properties)
        #else
        PostHogSDK.shared.capture(event.name, properties: event.properties)
        #endif
    }
    
    func identifyUser(id: String, properties: [String: Any]? = nil) {
        #if canImport(PostHog)
        PostHogSDK.shared.identify(id, userProperties: properties)
        #else
        PostHogSDK.shared.identify(id, userProperties: properties)
        #endif
    }
}

enum DreamRoomEvent {
    case partyCreated(hostId: String, isManualOverride: Bool)
    case partyJoined(partyId: String, guestId: String, method: String)
    case itemAdded(userId: String, type: String, source: String)
    case inviteShared(partyId: String, platform: String)
    case bigReveal(partyId: String, participantCount: Int)
    case clippingCaptured(sourceUrl: String, method: String)
    case kitPurchased(kitId: String, name: String)
    case subscriptionStarted(level: String)
    
    var name: String {
        switch self {
        case .partyCreated: return "party_created"
        case .partyJoined: return "party_joined"
        case .itemAdded: return "item_added_to_board"
        case .inviteShared: return "invite_shared"
        case .bigReveal: return "big_reveal_triggered"
        case .clippingCaptured: return "clipping_captured"
        case .kitPurchased: return "kit_purchased"
        case .subscriptionStarted: return "subscription_started"
        }
    }
    
    var properties: [String: Any] {
        switch self {
        case .partyCreated(let hostId, let manual):
            return ["host_id": hostId, "is_manual_override": manual]
        case .partyJoined(let partyId, let guestId, let method):
            return ["party_id": partyId, "guest_id": guestId, "join_method": method]
        case .itemAdded(let userId, let type, let source):
            return ["user_id": userId, "item_type": type, "source": source]
        case .inviteShared(let partyId, let platform):
            return ["party_id": partyId, "platform": platform]
        case .bigReveal(let partyId, let count):
            return ["party_id": partyId, "participant_count": count]
        case .clippingCaptured(let url, let method):
            return ["source_url": url, "method": method]
        case .kitPurchased(let kitId, let name):
            return ["kit_id": kitId, "kit_name": name]
        case .subscriptionStarted(let level):
            return ["level": level]
        }
    }
}
