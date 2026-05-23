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
                // Placeholder for actual image loading
                Image(systemName: "photo")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 200, height: 200)
                    .background(Color.gray.opacity(0.3))
                    .cornerRadius(12)
            } else if let text = item.text {
                Text(text)
                    .font(.custom("CormorantGaramond-Medium", size: 24))
                    .padding()
                    .background(Color.white)
                    .cornerRadius(8)
                    .shadow(radius: 2)
            }
        }
        .scaleEffect(item.scale * currentScale * (isDragging ? 1.05 : 1.0))
        .rotationEffect(item.rotation + currentRotation + flickRotation)
        .offset(x: item.position.x + dragOffset.width, y: item.position.y + dragOffset.height)
        .shadow(color: Color.black.opacity(isDragging ? 0.3 : 0.1), radius: isDragging ? 15 : 5, x: 0, y: isDragging ? 10 : 2)
        .gesture(
            DragGesture()
                .onChanged { value in
                    if !isDragging {
                        isDragging = true
                        onDragStarted()
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
                    if abs(velocity.width) > 500 || abs(velocity.height) > 500 {
                        withAnimation(.easeOut(duration: 0.5)) {
                            flickRotation = Angle(degrees: Double.random(in: 180...360))
                            dragOffset = CGSize(width: velocity.width * 2, height: velocity.height * 2)
                        }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                            onDelete()
                        }
                    } else {
                        withAnimation(.spring(response: 0.35, dampingFraction: 0.6)) {
                            item.position = finalPosition
                            dragOffset = .zero
                            isDragging = false
                        }
                        onDragEnded(finalPosition)
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
    @StateObject var viewModel = BoardViewModel()
    @State private var showingSettings = false
    @State private var showingPartyRoom = false
    
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
                            showingPartyRoom = true
                        }) {
                            Image(systemName: "person.3.fill")
                                .resizable()
                                .frame(width: 32, height: 20)
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
            PartyRoomView()
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
        PartyService.shared.createInviteLink(partyId: "test-party-123") { url in
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
}

extension Color {
    static let gold = Color(red: 0.83, green: 0.69, blue: 0.22)
}
/home/engine/.bashrc: line 1: syntax error near unexpected token `('
/home/engine/.bashrc: line 1: `. /etc/profile.d/workload-containment.shn# ~/.bashrc: executed by bash(1) for non-login shells.'
/home/engine/.bashrc: line 1: syntax error near unexpected token `('
/home/engine/.bashrc: line 1: `. /etc/profile.d/workload-containment.shn# ~/.bashrc: executed by bash(1) for non-login shells.'
/home/engine/.bashrc: line 1: syntax error near unexpected token `('
/home/engine/.bashrc: line 1: `. /etc/profile.d/workload-containment.shn# ~/.bashrc: executed by bash(1) for non-login shells.'
/home/engine/.bashrc: line 1: syntax error near unexpected token `('
/home/engine/.bashrc: line 1: `. /etc/profile.d/workload-containment.shn# ~/.bashrc: executed by bash(1) for non-login shells.'
/home/engine/.bashrc: line 1: syntax error near unexpected token `('
/home/engine/.bashrc: line 1: `. /etc/profile.d/workload-containment.shn# ~/.bashrc: executed by bash(1) for non-login shells.'
/home/engine/.bashrc: line 1: syntax error near unexpected token `('
/home/engine/.bashrc: line 1: `. /etc/profile.d/workload-containment.shn# ~/.bashrc: executed by bash(1) for non-login shells.'
/home/engine/.bashrc: line 1: syntax error near unexpected token `('
/home/engine/.bashrc: line 1: `. /etc/profile.d/workload-containment.shn# ~/.bashrc: executed by bash(1) for non-login shells.'
/home/engine/.bashrc: line 1: syntax error near unexpected token `('
/home/engine/.bashrc: line 1: `. /etc/profile.d/workload-containment.shn# ~/.bashrc: executed by bash(1) for non-login shells.'
/home/engine/.bashrc: line 1: syntax error near unexpected token `('
/home/engine/.bashrc: line 1: `. /etc/profile.d/workload-containment.shn# ~/.bashrc: executed by bash(1) for non-login shells.'
/home/engine/.bashrc: line 1: syntax error near unexpected token `('
/home/engine/.bashrc: line 1: `. /etc/profile.d/workload-containment.shn# ~/.bashrc: executed by bash(1) for non-login shells.'
/home/engine/.bashrc: line 1: syntax error near unexpected token `('
/home/engine/.bashrc: line 1: `. /etc/profile.d/workload-containment.shn# ~/.bashrc: executed by bash(1) for non-login shells.'
/home/engine/.bashrc: line 1: syntax error near unexpected token `('
/home/engine/.bashrc: line 1: `. /etc/profile.d/workload-containment.shn# ~/.bashrc: executed by bash(1) for non-login shells.'
/home/engine/.bashrc: line 1: syntax error near unexpected token `('
/home/engine/.bashrc: line 1: `. /etc/profile.d/workload-containment.shn# ~/.bashrc: executed by bash(1) for non-login shells.'
/home/engine/.bashrc: line 1: syntax error near unexpected token `('
/home/engine/.bashrc: line 1: `. /etc/profile.d/workload-containment.shn# ~/.bashrc: executed by bash(1) for non-login shells.'
/home/engine/.bashrc: line 1: syntax error near unexpected token `('
/home/engine/.bashrc: line 1: `. /etc/profile.d/workload-containment.shn# ~/.bashrc: executed by bash(1) for non-login shells.'
/home/engine/.bashrc: line 1: syntax error near unexpected token `('
/home/engine/.bashrc: line 1: `. /etc/profile.d/workload-containment.shn# ~/.bashrc: executed by bash(1) for non-login shells.'
/home/engine/.bashrc: line 1: syntax error near unexpected token `('
/home/engine/.bashrc: line 1: `. /etc/profile.d/workload-containment.shn# ~/.bashrc: executed by bash(1) for non-login shells.'
/home/engine/.bashrc: line 1: syntax error near unexpected token `('
/home/engine/.bashrc: line 1: `. /etc/profile.d/workload-containment.shn# ~/.bashrc: executed by bash(1) for non-login shells.'
/home/engine/.bashrc: line 1: syntax error near unexpected token `('
/home/engine/.bashrc: line 1: `. /etc/profile.d/workload-containment.shn# ~/.bashrc: executed by bash(1) for non-login shells.'
/home/engine/.bashrc: line 1: syntax error near unexpected token `('
/home/engine/.bashrc: line 1: `. /etc/profile.d/workload-containment.shn# ~/.bashrc: executed by bash(1) for non-login shells.'
/home/engine/.bashrc: line 1: syntax error near unexpected token `('
/home/engine/.bashrc: line 1: `. /etc/profile.d/workload-containment.shn# ~/.bashrc: executed by bash(1) for non-login shells.'
/home/engine/.bashrc: line 1: syntax error near unexpected token `('
/home/engine/.bashrc: line 1: `. /etc/profile.d/workload-containment.shn# ~/.bashrc: executed by bash(1) for non-login shells.'
/home/engine/.bashrc: line 1: syntax error near unexpected token `('
/home/engine/.bashrc: line 1: `. /etc/profile.d/workload-containment.shn# ~/.bashrc: executed by bash(1) for non-login shells.'
/home/engine/.bashrc: line 1: syntax error near unexpected token `('
/home/engine/.bashrc: line 1: `. /etc/profile.d/workload-containment.shn# ~/.bashrc: executed by bash(1) for non-login shells.'
/home/engine/.bashrc: line 1: syntax error near unexpected token `('
/home/engine/.bashrc: line 1: `. /etc/profile.d/workload-containment.shn# ~/.bashrc: executed by bash(1) for non-login shells.'
/home/engine/.bashrc: line 1: syntax error near unexpected token `('
/home/engine/.bashrc: line 1: `. /etc/profile.d/workload-containment.shn# ~/.bashrc: executed by bash(1) for non-login shells.'
/home/engine/.bashrc: line 1: syntax error near unexpected token `('
/home/engine/.bashrc: line 1: `. /etc/profile.d/workload-containment.shn# ~/.bashrc: executed by bash(1) for non-login shells.'
/home/engine/.bashrc: line 1: syntax error near unexpected token `('
/home/engine/.bashrc: line 1: `. /etc/profile.d/workload-containment.shn# ~/.bashrc: executed by bash(1) for non-login shells.'
/home/engine/.bashrc: line 1: syntax error near unexpected token `('
/home/engine/.bashrc: line 1: `. /etc/profile.d/workload-containment.shn# ~/.bashrc: executed by bash(1) for non-login shells.'
/home/engine/.bashrc: line 1: syntax error near unexpected token `('
/home/engine/.bashrc: line 1: `. /etc/profile.d/workload-containment.shn# ~/.bashrc: executed by bash(1) for non-login shells.'
