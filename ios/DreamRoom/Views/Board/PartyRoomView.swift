import SwiftUI

struct PartyRoomView: View {
    @StateObject var viewModel: PartyViewModel
    @StateObject var boardViewModel = BoardViewModel.shared
    @Environment(\.presentationMode) var presentationMode
    
    init(partyId: String = "test-party-123") {
        _viewModel = StateObject(wrappedValue: PartyViewModel(partyId: partyId))
    }
    
    var body: some View {
        ZStack {
            // Dark luxury background
            GoldenHourBackground(active: viewModel.isGoldenHour)
            
            VStack(spacing: 0) {
                // Header
                HStack {
                    Button(action: { presentationMode.wrappedValue.dismiss() }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.title)
                            .foregroundColor(.secondary)
                    }
                    Spacer()
                    Text("The Party Room")
                        .font(.custom(DreamTheme.boldFontName, size: 24))
                        .goldenHour(active: viewModel.isGoldenHour)
                    Spacer()
                    // Host controls
                    if viewModel.isHost || true {
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
                
                // Participants (The Target for Flick)
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 20) {
                        ForEach(viewModel.participants) { participant in
                            ParticipantAvatarView(participant: participant, isGoldenHour: viewModel.isGoldenHour)
                        }
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 10)
                }
                .background(Color.black.opacity(0.2))
                
                // Board Canvas
                ZStack {
                    BoardCanvasView(
                        viewModel: boardViewModel,
                        isPartyMode: true,
                        activePartyId: viewModel.partyId,
                        isGoldenHour: viewModel.isGoldenHour
                    )
                    
                    if viewModel.status == .revealCountdown {
                        Text("\(viewModel.countdown)")
                            .font(.custom(DreamTheme.boldFontName, size: 120))
                            .foregroundColor(.gold)
                            .transition(.scale)
                    }
                }
                .clipped()
            }
            
            // Spark Feed Overlay
            VStack {
                Spacer()
                HStack {
                    GoldenSparkFeedView(sparks: viewModel.sparks)
                    Spacer()
                }
            }
            .allowsHitTesting(false)
            
            if viewModel.status == .revealing {
                RevealSequenceView(
                    participantsCount: viewModel.participants.count,
                    userName: "Avery",
                    onComplete: {
                        viewModel.status = .completed
                    }
                )
            }
        }
    }
}

struct ParticipantAvatarView: View {
    let participant: Participant
    var isGoldenHour: Bool = false
    
    var body: some View {
        VStack {
            ZStack {
                Circle()
                    .stroke(participant.isBuilding ? Color.gold : (isGoldenHour ? Color.gold.opacity(0.3) : Color.sapphire.opacity(0.5)), lineWidth: 2)
                    .frame(width: 60, height: 60)
                
                Image(systemName: "person.fill")
                    .resizable()
                    .padding(12)
                    .frame(width: 56, height: 60)
                    .background(Color.gray.opacity(0.1))
                    .clipShape(Circle())
                    .shadow(color: isGoldenHour ? .gold.opacity(0.4) : .clear, radius: 5)
                
                if participant.isBuilding {
                    Circle()
                        .fill(Color.gold)
                        .frame(width: 10, height: 10)
                        .offset(x: 20, y: -20)
                        .shadow(color: .gold.opacity(0.8), radius: 4)
                }
            }
            Text(participant.name)
                .font(.custom(DreamTheme.fontName, size: 12))
                .goldenHour(active: isGoldenHour)
        }
    }
}
