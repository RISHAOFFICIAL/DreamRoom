import SwiftUI

struct RecallView: View {
    @StateObject var viewModel: RecallViewModel
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        ZStack {
            Color.dreamBackground
                .edgesIgnoringSafeArea(.all)
            
            // Cinematic Content
            ZStack {
                if viewModel.currentStep == .intro {
                    IntroFrame(milestone: viewModel.milestone)
                        .transition(.asymmetric(insertion: .opacity, removal: .scale(scale: 1.1).combined(with: .opacity)))
                } else if case .item(let index) = viewModel.currentStep {
                    ItemFrame(item: viewModel.items[index], progress: viewModel.progress)
                        .id("item-\(viewModel.items[index].id)")
                        .transition(.asymmetric(insertion: .move(edge: .trailing), removal: .move(edge: .leading)))
                } else if viewModel.currentStep == .finalReveal {
                    FinalRevealFrame(items: viewModel.items, onHostParty: {
                        // Action for "Host a Dream Party"
                        presentationMode.wrappedValue.dismiss()
                    })
                    .transition(.opacity)
                }
            }
            .animation(.timingCurve(0.23, 1, 0.32, 1, duration: 1.0), value: viewModel.currentStep)
            
            // Progress Indicators
            VStack {
                HStack(spacing: 6) {
                    ForEach(0..<totalSteps, id: \.self) { index in
                        Capsule()
                            .fill(Color.white.opacity(index <= currentStepIndex ? (index == currentStepIndex ? 0.3 : 0.8) : 0.2))
                            .frame(height: 3)
                            .overlay(
                                GeometryReader { geo in
                                    if index == currentStepIndex {
                                        Capsule()
                                            .fill(Color.white)
                                            .frame(width: geo.size.width * CGFloat(viewModel.progress))
                                    }
                                },
                                alignment: .leading
                            )
                    }
                }
                .padding(.horizontal)
                .padding(.top, 20)
                
                Spacer()
            }
            
            // Navigation Zones
            HStack(spacing: 0) {
                Color.black.opacity(0.001)
                    .onTapGesture {
                        // Previous step logic could go here
                    }
                Color.black.opacity(0.001)
                    .onTapGesture {
                        viewModel.skip()
                    }
            }
            
            // Close Button
            VStack {
                HStack {
                    Spacer()
                    Button(action: { presentationMode.wrappedValue.dismiss() }) {
                        Image(systemName: "xmark")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.white)
                            .padding(10)
                            .background(Circle().fill(Color.black.opacity(0.3)))
                    }
                    .padding(.trailing, 20)
                    .padding(.top, 40)
                }
                Spacer()
            }
        }
        .onAppear {
            viewModel.start()
            SoundService.shared.play(name: viewModel.soundscapeName)
        }
    }
    
    private var totalSteps: Int {
        return 2 + viewModel.items.count // Intro + Items + Final
    }
    
    private var currentStepIndex: Int {
        switch viewModel.currentStep {
        case .intro: return 0
        case .item(let index): return index + 1
        case .finalReveal: return totalSteps - 1
        }
    }
}

struct IntroFrame: View {
    let milestone: RecallMilestone
    @State private var appear = false
    
    var body: some View {
        VStack(spacing: 20) {
            Text("VISION CALLING")
                .font(.system(size: 14, weight: .bold))
                .tracking(8)
                .foregroundColor(.gold)
                .opacity(appear ? 1 : 0)
                .offset(y: appear ? 0 : 20)
            
            Text(milestone.rawValue)
                .font(.custom(DreamTheme.italicFontName, size: 48))
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
                .opacity(appear ? 1 : 0)
                .offset(y: appear ? 0 : 30)
        }
        .onAppear {
            withAnimation(.easeOut(duration: 1.5)) {
                appear = true
            }
        }
    }
}

struct ItemFrame: View {
    let item: BoardItem
    let progress: Double
    
    // Ken Burns Animation State
    @State private var scale: CGFloat = 1.1
    @State private var offset: CGSize = .zero
    
    var body: some View {
        ZStack {
            // Background Image/Text with Ken Burns
            Group {
                if let imageUrl = item.imageUrl {
                    AsyncImage(url: URL(string: imageUrl)) { image in
                        image.resizable()
                            .aspectRatio(contentMode: .fill)
                    } placeholder: {
                        Color.gray.opacity(0.3)
                    }
                } else {
                    ZStack {
                        Color.gold.opacity(0.1)
                        Text(item.text ?? "")
                            .font(.custom(DreamTheme.mediumFontName, size: 32))
                            .foregroundColor(.gold)
                            .multilineTextAlignment(.center)
                            .padding(40)
                    }
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .scaleEffect(scale)
            .offset(offset)
            .clipped()
            
            // Dark vignette
            RadialGradient(
                gradient: Gradient(colors: [.clear, .black.opacity(0.8)]),
                center: .center,
                startRadius: 100,
                endRadius: 500
            )
            .edgesIgnoringSafeArea(.all)
            
            // Witness Seal if present
            if item.hasWitnessSeal {
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        Image(systemName: "checkmark.seal.fill")
                            .foregroundColor(.gold)
                            .font(.system(size: 40))
                            .shadow(color: .black, radius: 10)
                            .padding(40)
                    }
                }
            }
        }
        .onAppear {
            // Start Ken Burns
            withAnimation(.linear(duration: 5.0)) {
                scale = 1.3
                offset = CGSize(width: 20, height: 20)
            }
        }
    }
}

struct FinalRevealFrame: View {
    let items: [BoardItem]
    let onHostParty: () -> Void
    @State private var appear = false
    
    var body: some View {
        ZStack {
            // Full Board under Golden Hour filter
            VStack(spacing: 30) {
                Text("Your vision is taking shape.")
                    .font(.custom(DreamTheme.italicFontName, size: 32))
                    .foregroundColor(.white)
                    .padding(.top, 60)
                
                // Mini Board Preview
                ZStack {
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color.black.opacity(0.5))
                        .frame(width: 300, height: 400)
                        .overlay(
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(Color.gold, lineWidth: 1)
                        )
                    
                    // Simplified grid of items
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
                        ForEach(items.prefix(4)) { item in
                            if let imageUrl = item.imageUrl {
                                AsyncImage(url: URL(string: imageUrl)) { image in
                                    image.resizable()
                                        .aspectRatio(contentMode: .fill)
                                } placeholder: {
                                    Color.gray.opacity(0.3)
                                }
                                .frame(width: 130, height: 180)
                                .cornerRadius(10)
                            } else {
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(Color.gold.opacity(0.2))
                                    .frame(width: 130, height: 180)
                            }
                        }
                    }
                    .padding(20)
                    
                    // Golden Hour Glow
                    RadialGradient(
                        gradient: Gradient(colors: [Color.gold.opacity(0.3), .clear]),
                        center: .center,
                        startRadius: 0,
                        endRadius: 300
                    )
                }
                .scaleEffect(appear ? 1 : 0.9)
                .opacity(appear ? 1 : 0)
                
                Spacer()
                
                // CTAs
                VStack(spacing: 20) {
                    Button(action: onHostParty) {
                        Text("Host a Dream Party")
                            .font(.system(size: 14, weight: .bold))
                            .tracking(2)
                            .foregroundColor(.dreamBackground)
                            .frame(width: 260, height: 56)
                            .background(Color.gold)
                            .cornerRadius(28)
                            .shadow(color: Color.gold.opacity(0.3), radius: 20)
                    }
                    
                    Button(action: {}) {
                        Text("Share with Witnesses")
                            .font(.custom(DreamTheme.mediumFontName, size: 18))
                            .foregroundColor(.gold)
                    }
                }
                .padding(.bottom, 60)
                .opacity(appear ? 1 : 0)
                .offset(y: appear ? 0 : 30)
            }
        }
        .onAppear {
            withAnimation(.easeOut(duration: 1.2).delay(0.5)) {
                appear = true
            }
            SoundService.shared.play(name: "cinematic-swell")
        }
    }
}
