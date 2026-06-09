import SwiftUI
struct BoardView: View {
    @StateObject var viewModel = BoardViewModel.shared
    @State private var showingSettings = false
    @State private var showingPartyRoom = false
    @State private var showingShop = false
    @State private var showingScanner = false
    @State private var showingRecall = false
    @State private var selectedRecallItem: BoardItem?
    @State private var activePartyId = "test-party-123"
    
    var body: some View {
        ZStack {
            // Background Canvas
            Color(.systemBackground)
                .edgesIgnoringSafeArea(.all)
                .onTapGesture {
                    withAnimation {
                        viewModel.isViewMode.toggle()
                    }
                }
            
            // Items
            ForEach($viewModel.items) { $item in
                BoardItemView(
                    item: $item,
                    isPartyMode: false,
                    isGoldenHour: false,
                    onDragStarted: {
                        viewModel.bringToFront(id: item.id)
                        // Notify party of active building
                        SocketService.shared.sendBuildingState(partyId: "test-party-123", isBuilding: true)
                    },
                    onDragEnded: { _ in
                        // Notify party building stopped
                        SocketService.shared.sendBuildingState(partyId: "test-party-123", isBuilding: false)
                    },
                    onDelete: {
                        viewModel.removeItem(id: item.id)
                    },
                    onFlickToFriend: { asset in
                        // Personal board doesn't flick to friend in this view
                    }
                )
                .zIndex(item.zIndex)
            }
            
            // UI Overlay
            if !viewModel.isViewMode {
                VStack {
                    HStack {
                        Button(action: {
                            showingSettings = true
                        }) {
                            Image(systemName: "gearshape")
                                .resizable()
                                .frame(width: 24, height: 24)
                                .foregroundColor(.secondary)
                        }
                        .padding()
                        
                        Button(action: {
                            showingShop = true
                        }) {
                            Image(systemName: "sparkles")
                                .resizable()
                                .frame(width: 24, height: 24)
                                .foregroundColor(.gold)
                        }
                        .padding()
                        
                        Button(action: {
                            showingPartyRoom = true
                        }) {
                            Image(systemName: "person.3.fill")
                                .resizable()
                                .frame(width: 32, height: 20)
                                .foregroundColor(.gold)
                        }
                        .padding()
                        
                        Button(action: {
                            showingScanner = true
                        }) {
                            Image(systemName: "qrcode.viewfinder")
                                .resizable()
                                .frame(width: 32, height: 32)
                                .foregroundColor(.gold)
                        }
                        .padding()
                        
                        Button(action: {
                            shareInvite()
                        }) {
                            Image(systemName: "square.and.arrow.up")
                                .resizable()
                                .frame(width: 20, height: 24)
                                .foregroundColor(.gold)
                        }
                        .padding()
                        
                        Button(action: {
                            WallpaperService.shared.exportBoardToWallpaper(items: viewModel.items, boardTitle: viewModel.boardTitle)
                        }) {
                            Image(systemName: "iphone")
                                .resizable()
                                .frame(width: 18, height: 26)
                                .foregroundColor(.gold)
                        }
                        .padding()
                        
                        Spacer()
                        
                        Button(action: {
                            viewModel.addItem(text: "New Dream")
                        }) {
                            Image(systemName: "plus.circle.fill")
                                .resizable()
                                .frame(width: 44, height: 44)
                                .foregroundColor(.gold) // We should define this color
                        }
                        .padding()
                    }
                    Spacer()
                    
                    Text("Double tap canvas to hide UI")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .padding()
                }
            }
        }
        .fullScreenCover(isPresented: $showingPartyRoom) {
            PartyRoomView(partyId: activePartyId)
        }
        .fullScreenCover(isPresented: $showingShop) {
            DreamShopView()
        }
        .fullScreenCover(isPresented: $showingRecall) {
            if let items = [selectedRecallItem].compactMap({ $0 }) {
                RecallView(viewModel: RecallViewModel(items: items, milestone: .nextDay))
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: .didReceiveDeepLink)) { notification in
            if let itemId = notification.userInfo?["itemId"] as? UUID {
                if let item = viewModel.items.first(where: { $0.id == itemId }) {
                    selectedRecallItem = item
                    showingRecall = true
                }
            }
        }
        .sheet(isPresented: $showingScanner) {
            QRCodeScannerView(onScan: { code in
                showingScanner = false
                handleScan(code: code)
            }, onDismiss: {
                showingScanner = false
            })
        }
        .sheet(isPresented: $showingSettings) {
            NavigationView {
                PrivacySettingsView(settings: $viewModel.settings)
                    .toolbar {
                        ToolbarItem(placement: .navigationBarTrailing) {
                            Button("Done") {
                                showingSettings = false
                            }
                        }
                    }
            }
        }
        .onAppear {
            // Add some initial items for demo
            if viewModel.items.isEmpty {
                viewModel.addItem(text: "Luxury Travel")
                viewModel.items[0].position = CGPoint(x: 100, y: 200)
                
                viewModel.addItem(text: "Penthouse View")
                viewModel.items[1].position = CGPoint(x: 250, y: 400)
                viewModel.items[1].rotation = Angle(degrees: 15)
            }
        }
    }
    
    private func shareInvite() {
        PartyService.shared.createInviteLink(partyId: activePartyId) { url in
            guard let url = url else { return }
            
            DispatchQueue.main.async {
                let activityVC = UIActivityViewController(activityItems: ["Join my DreamRoom party!", url], applicationActivities: nil)
                
                // For iPad
                if let topVC = UIApplication.shared.windows.first?.rootViewController {
                    activityVC.popoverPresentationController?.sourceView = topVC.view
                    topVC.present(activityVC, animated: true, completion: nil)
                }
                
                // Track analytics
                AnalyticsService.shared.track(.inviteShared(partyId: UUID(), platform: "system_share"))
            }
        }
    }
    
    private func handleScan(code: String) {
        if let url = URL(string: code),
           url.host == "dreamroom.app",
           url.pathComponents.contains("join"),
           let partyId = url.pathComponents.last {
            
            activePartyId = partyId
            showingPartyRoom = true
            
            // Track analytics
            AnalyticsService.shared.track(.partyJoined(partyId: UUID(), guestId: UUID(), method: "qr_scan"))
        } else {
            // Fallback for simple party IDs
            activePartyId = code
            showingPartyRoom = true
            
            // Track analytics
            AnalyticsService.shared.track(.partyJoined(partyId: UUID(), guestId: UUID(), method: "manual_entry"))
        }
    }
}
