import SwiftUI

struct BoardItemView: View {
    @Binding var item: BoardItem
    var onDragStarted: () -> Void
    var onDragEnded: (CGPoint) -> Void
    var onDelete: () -> Void
    
    @State private var dragOffset: CGSize = .zero
    @State private var currentScale: CGFloat = 1.0
    @State private var currentRotation: Angle = .zero
    @State private var isDragging: Bool = false
    
    // Flick to delete state
    @State private var flickVelocity: CGSize = .zero
    @State private var flickRotation: Angle = .zero
    
    var body: some View {
        ZStack {
            if let imageUrl = item.imageUrl {
                if imageUrl.hasPrefix("http") {
                    AsyncImage(url: URL(string: imageUrl)) { image in
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                    } placeholder: {
                        ProgressView()
                            .frame(width: 200, height: 200)
                            .background(Color.gray.opacity(0.3))
                    }
                    .frame(width: 200, height: 200)
                    .cornerRadius(12)
                } else {
                    // Dream Kit Premium Asset (Mock representation)
                    ZStack {
                        Rectangle()
                            .fill(LinearGradient(gradient: Gradient(colors: [.gold.opacity(0.5), .black.opacity(0.3)]), startPoint: .topLeading, endPoint: .bottomTrailing))
                        
                        VStack {
                            Image(systemName: "sparkles")
                                .font(.title)
                                .foregroundColor(.gold)
                            Text(imageUrl)
                                .font(.custom("CormorantGaramond-Bold", size: 16))
                                .foregroundColor(.white)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal)
                        }
                    }
                    .frame(width: 200, height: 200)
                    .cornerRadius(12)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.gold.opacity(0.5), lineWidth: 1)
                    )
                }
            } else if let text = item.text {
                Text(text)
                    .font(.custom("CormorantGaramond-Medium", size: 24))
                    .padding()
                    .background(Color.white)
                    .cornerRadius(8)
                    .shadow(radius: 2)
            }
        }
        .scaleEffect(item.scale * currentScale * (isDragging ? 1.15 : 1.0))
        .rotationEffect(item.rotation + currentRotation + flickRotation)
        .offset(x: item.position.x + dragOffset.width, y: item.position.y + dragOffset.height)
        .shadow(color: Color.black.opacity(isDragging ? 0.4 : 0.1), radius: isDragging ? 20 : 5, x: 0, y: isDragging ? 15 : 2)
        .gesture(
            DragGesture()
                .onChanged { value in
                    if !isDragging {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                            isDragging = true
                        }
                        onDragStarted()
                        UIImpactFeedbackGenerator(style: .light).impactOccurred()
                    }
                    dragOffset = value.translation
                }
                .onEnded { value in
                    let finalPosition = CGPoint(
                        x: item.position.x + value.translation.width,
                        y: item.position.y + value.translation.height
                    )
                    
                    // Check for flick velocity to delete
                    let velocity = value.predictedEndTranslation
                    let magnitude = sqrt(pow(velocity.width, 2) + pow(velocity.height, 2))
                    
                    if magnitude > 1000 {
                        UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
                        withAnimation(.interpolatingSpring(stiffness: 50, damping: 10)) {
                            flickRotation = Angle(degrees: Double.random(in: 720...1440))
                            dragOffset = CGSize(width: velocity.width * 3, height: velocity.height * 3)
                        }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                            onDelete()
                        }
                    } else {
                        withAnimation(.spring(response: 0.4, dampingFraction: 0.65, blendDuration: 0)) {
                            item.position = finalPosition
                            dragOffset = .zero
                            isDragging = false
                        }
                        onDragEnded(finalPosition)
                        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                        SoundService.shared.play(name: "soft-settle", randomizePitch: true)
                    }
                }
        )
        .simultaneousGesture(
            MagnificationGesture()
                .onChanged { value in
                    currentScale = value
                }
                .onEnded { value in
                    item.scale *= value
                    currentScale = 1.0
                }
        )
        .simultaneousGesture(
            RotationGesture()
                .onChanged { value in
                    currentRotation = value
                }
                .onEnded { value in
                    item.rotation += value
                    currentRotation = .zero
                }
        )
    }
}

struct BoardView: View {
    @StateObject var viewModel = BoardViewModel.shared
    @State private var showingSettings = false
    @State private var showingPartyRoom = false
    @State private var showingShop = false
    @State private var showingScanner = false
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
                    onDragStarted: {
                        viewModel.bringToFront(id: item.id)
                        // Notify party of active building
                        SocketService.shared.sendBuildingState(partyId: "test-party-123", userId: UUID().uuidString, isBuilding: true)
                    },
                    onDragEnded: { _ in
                        // Notify party building stopped
                        SocketService.shared.sendBuildingState(partyId: "test-party-123", userId: UUID().uuidString, isBuilding: false)
                    },
                    onDelete: {
                        viewModel.removeItem(id: item.id)
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

extension Color {
    static let gold = Color(red: 0.91, green: 0.79, blue: 0.48)
}
