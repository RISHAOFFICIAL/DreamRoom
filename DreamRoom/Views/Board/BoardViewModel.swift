import Foundation
import SwiftUI
import Combine

class BoardViewModel: ObservableObject {
    @Published var items: [BoardItem] = []
    @Published var isViewMode: Bool = false
    
    // Track z-index to bring active items to front
    private var maxZIndex: Double = 0
    
    func addItem(imageUrl: String? = nil, text: String? = nil) {
        let newItem = BoardItem(
            imageUrl: imageUrl,
            text: text,
            position: CGPoint(x: 200, y: 300) // Default center-ish
        )
        items.append(newItem)
        
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
