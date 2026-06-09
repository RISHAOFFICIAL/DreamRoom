import Foundation
import SwiftUI
import Combine

class BoardViewModel: ObservableObject {
    static let shared = BoardViewModel()
    
    @Published var items: [BoardItem] = []
    @Published var isViewMode: Bool = false
    @Published var boardTitle: String = "The Sanctuary"
    @Published var settings: BoardSettings = BoardSettings()
    @Published var activePartyId: String? = nil
    
    // Track z-index to bring active items to front
    private var maxZIndex: Double = 0
    
    func addItem(imageUrl: String? = nil, text: String? = nil) {
        // Gate kit assets
        if let url = imageUrl, !DreamKitService.shared.isAssetUnlocked(assetName: url) {
            print("[Entitlement] Asset \(url) is locked.")
            // In a real app, we might trigger a shop popup here
            return
        }

        let newItem = BoardItem(
            imageUrl: imageUrl,
            text: text,
            position: CGPoint(x: 200, y: 300) // Default center-ish
        )
        items.append(newItem)
        
        // If in a party, sync the new item
        if let partyId = activePartyId {
            SocketService.shared.addItem(partyId: partyId, item: newItem)
        }
        
        // Track analytics
        AnalyticsService.shared.track(.itemAdded(
            userId: UUID(), // In a real app, this would be the current user
            type: imageUrl != nil ? "image" : "text",
            source: "manual"
        ))
    }
    
    func updatePosition(id: UUID, position: CGPoint) {
        if let index = items.firstIndex(where: { $0.id == id }) {
            items[index].position = position
        }
    }
    
    func updateRotation(id: UUID, rotation: Angle) {
        if let index = items.firstIndex(where: { $0.id == id }) {
            items[index].rotation = rotation
        }
    }
    
    func updateScale(id: UUID, scale: CGFloat) {
        if let index = items.firstIndex(where: { $0.id == id }) {
            items[index].scale = scale
        }
    }
    
    func bringToFront(id: UUID) {
        if let index = items.firstIndex(where: { $0.id == id }) {
            maxZIndex += 1
            items[index].zIndex = maxZIndex
        }
    }
    
    func removeItem(id: UUID) {
        items.removeAll(where: { $0.id == id })
    }
}
