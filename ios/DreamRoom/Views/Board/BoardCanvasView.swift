import SwiftUI

struct BoardCanvasView: View {
    @ObservedObject var viewModel: BoardViewModel
    var isPartyMode: Bool = false
    var activePartyId: String = ""
    var isGoldenHour: Bool = false
    
    var body: some View {
        ZStack {
            // Background Canvas
            Color.clear // Transparent to let parent background show
                .contentShape(Rectangle())
                .onTapGesture {
                    withAnimation {
                        viewModel.isViewMode.toggle()
                    }
                }
            
            // Items
            ForEach($viewModel.items) { $item in
                BoardItemView(
                    item: $item,
                    isPartyMode: isPartyMode,
                    isGoldenHour: isGoldenHour,
                    onDragStarted: {
                        viewModel.bringToFront(id: item.id)
                        if !activePartyId.isEmpty {
                            SocketService.shared.sendBuildingState(partyId: activePartyId, userId: UUID().uuidString, isBuilding: true)
                        }
                    },
                    onDragEnded: { _ in
                        if !activePartyId.isEmpty {
                            SocketService.shared.sendBuildingState(partyId: activePartyId, userId: UUID().uuidString, isBuilding: false)
                        }
                    },
                    onDelete: {
                        viewModel.removeItem(id: item.id)
                    },
                    onFlickToFriend: { assetName in
                        DreamDropService.shared.broadcastAsset(name: assetName)
                    },
                    onWitness: {
                        if !activePartyId.isEmpty {
                            SocketService.shared.witnessItem(partyId: activePartyId, itemId: item.id)
                        }
                    }
                )
                .zIndex(item.zIndex)
            }
            
            // Arrival Overlay for Dream Drops
            if let arrivingAsset = DreamDropService.shared.receivedAsset {
                Color.black.opacity(0.001)
                    .onAppear {
                        handleArrival(asset: arrivingAsset)
                    }
            }
        }
    }
    
    private func handleArrival(asset: String) {
        SoundService.shared.play(name: "crystalline-chime")
        
        viewModel.addItem(imageUrl: asset.hasPrefix("http") ? asset : nil, text: asset.hasPrefix("http") ? nil : asset)
        
        if let index = viewModel.items.lastIndex(where: { $0.text == asset || $0.imageUrl == asset }) {
            viewModel.items[index].hasWitnessSeal = true
            viewModel.items[index].position = CGPoint(x: UIScreen.main.bounds.width / 2, y: -200)
            
            withAnimation(.interpolatingSpring(stiffness: 50, damping: 8).delay(0.1)) {
                viewModel.items[index].position = CGPoint(x: UIScreen.main.bounds.width / 2, y: 300)
            }
        }
        
        DreamDropService.shared.receivedAsset = nil
    }
}
