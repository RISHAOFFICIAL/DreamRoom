import SwiftUI

struct GoldenHourModifier: ViewModifier {
    var active: Bool
    @State private var shimmerOffset: CGFloat = -500
    
    func body(content: Content) {
        content
            .overlay(
                active ? 
                LinearGradient(
                    gradient: Gradient(colors: [.clear, .white.opacity(0.4), .clear]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .rotationEffect(.degrees(30))
                .offset(x: shimmerOffset)
                .mask(content)
                : nil
            )
            .foregroundColor(active ? .gold : .primary)
            .accentColor(active ? .gold : .blue)
            .shadow(color: active ? .gold.opacity(0.3) : .clear, radius: 10)
            .onAppear {
                if active {
                    withAnimation(Animation.linear(duration: 2.5).repeatForever(autoreverses: false)) {
                        shimmerOffset = 500
                    }
                }
            }
            .onChange(of: active) { newValue in
                if newValue {
                    withAnimation(Animation.linear(duration: 2.5).repeatForever(autoreverses: false)) {
                        shimmerOffset = 500
                    }
                } else {
                    shimmerOffset = -500
                }
            }
    }
}

extension View {
    func goldenHour(active: Bool) -> some View {
        self.modifier(GoldenHourModifier(active: active))
    }
}

struct PartyRoomView: View {
    @StateObject var viewModel: PartyViewModel
    @Environment(\.presentationMode) var presentationMode
    
    init(partyId: String = "test-party-123") {
        _viewModel = StateObject(wrappedValue: PartyViewModel(partyId: partyId))
    }
    
    var body: some View {
        ZStack {
            // Dark luxury background
            Color(red: 0.05, green: 0.05, blue: 0.08)
                .edgesIgnoringSafeArea(.all)
            
            VStack {
                // Header
                HStack {
                    Button(action: { presentationMode.wrappedValue.dismiss() }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.title)
                            .foregroundColor(.secondary)
                    }
                    Spacer()
                    Text("The Party Room")
                        .font(.custom("CormorantGaramond-Bold", size: 24))
                        .goldenHour(active: viewModel.isGoldenHour)
                    Spacer()
                    // Host controls
                    if viewModel.isHost || true { // For demo
                        HStack(spacing: 12) {
                            Button(action: {
                                withAnimation {
                                    viewModel.toggleGoldenHour()
                                }
                            }) {
                                Image(systemName: viewModel.isGoldenHour ? "sun.max.fill" : "sun.max")
                                    .foregroundColor(viewModel.isGoldenHour ? .gold : .secondary)
                                    .padding(8)
                                    .background(Circle().fill(viewModel.isGoldenHour ? Color.gold.opacity(0.2) : Color.clear))
                            }
                            
                            Button("Reveal") {
                                viewModel.startReveal()
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(Color.gold)
                            .foregroundColor(.black)
                            .cornerRadius(20)
                        }
                    }
                }
                .padding()
                
                Spacer()
                
                // Participants
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 20) {
                        ForEach(viewModel.participants) { participant in
                            VStack {
                                ZStack {
                                    Circle()
                                        .stroke(participant.isBuilding ? Color.gold : Color.secondary, lineWidth: 2)
                                        .frame(width: 64, height: 64)
                                    
                                    Image(systemName: "person.fill")
                                        .resizable()
                                        .padding(15)
                                        .frame(width: 60, height: 60)
                                        .background(Color.gray.opacity(0.3))
                                        .clipShape(Circle())
                                    
                                    if participant.isBuilding {
                                        Circle()
                                            .fill(Color.gold)
                                            .frame(width: 12, height: 12)
                                            .offset(x: 22, y: -22)
                                    }
                                }
                                Text(participant.name)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                    .padding()
                }
                
                if viewModel.status == .revealCountdown {
                    Text("\(viewModel.countdown)")
                        .font(.custom("CormorantGaramond-Bold", size: 120))
                        .foregroundColor(.gold)
                        .transition(.scale)
                }
                
                Spacer()
            }
            
            if viewModel.status == .revealing {
                RevealView(isPresented: .constant(true)) {
                    viewModel.status = .completed
                }
            }
        }
    }
}

struct RevealView: View {
    @Binding var isPresented: Bool
    var onComplete: () -> Void
    
    @State private var rotation: Double = 0
    @State private var scale: CGFloat = 0.8
    @State private var opacity: Double = 0
    
    var body: some View {
        ZStack {
            Color.black.edgesIgnoringSafeArea(.all)
            
            VStack {
                Text("Your Vision is Manifested")
                    .font(.custom("CormorantGaramond-Bold", size: 32))
                    .foregroundColor(.gold)
                    .padding()
                    .opacity(opacity)
                
                // Representing the board flip
                RoundedRectangle(cornerRadius: 20)
                    .fill(LinearGradient(gradient: Gradient(colors: [.gold, .white, .gold]), startPoint: .topLeading, endPoint: .bottomTrailing))
                    .frame(width: 300, height: 450)
                    .rotation3DEffect(.degrees(rotation), axis: (x: 0, y: 1, z: 0))
                    .scaleEffect(scale)
                
                Button("Exit Reveal") {
                    onComplete()
                }
                .foregroundColor(.gold)
                .padding()
                .opacity(opacity)
            }
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 2.0)) {
                rotation = 360 * 3
                scale = 1.0
                opacity = 1.0
            }
            
            // Sound
            SoundService.shared.play(name: "cinematic-reveal")
            
            // Haptic
            UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
        }
    }
}
