import Foundation
import Combine

class ClippingService: ObservableObject {
    static let shared = ClippingService()
    
    @Published var clips: [Clip] = []
    
    private let storageKey = "dreamroom.clips"
    
    private init() {
        loadClips()
    }
    
    func addClip(imageUrl: URL, sourceUrl: URL? = nil) {
        let newClip = Clip(imageUrl: imageUrl, sourceUrl: sourceUrl)
        clips.insert(newClip, at: 0)
        saveClips()
        
        // Track analytics
        AnalyticsService.shared.track(.clippingCaptured(
            sourceUrl: sourceUrl?.absoluteString ?? "unknown",
            method: "in_app"
        ))
    }
    
    func removeClip(id: UUID) {
        clips.removeAll { $0.id == id }
        saveClips()
    }
    
    private func saveClips() {
        if let encoded = try? JSONEncoder().encode(clips) {
            UserDefaults.standard.set(encoded, forKey: storageKey)
        }
    }
    
    private func loadClips() {
        if let data = UserDefaults.standard.data(forKey: storageKey),
           let decoded = try? JSONDecoder().decode([Clip].self, from: data) {
            clips = decoded
        }
    }
}
