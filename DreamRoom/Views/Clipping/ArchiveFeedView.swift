import SwiftUI

struct ArchiveFeedView: View {
    @StateObject private var clippingService = ClippingService.shared
    @State private var showingTearEffect = false
    @State private var tornImage: URL?
    
    // Mock feed data
    let mockImages = (1...20).map { String(format: "dream-%02d", $0) }
    
    let columns = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                // Premium Assets Section
                let premiumAssets = DreamKitService.shared.getUnlockedAssets()
                if !premiumAssets.isEmpty {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Unlocked Dream Assets")
                            .font(.custom("CormorantGaramond-Bold", size: 22))
                            .padding(.horizontal)
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 12) {
                                ForEach(premiumAssets, id: \.self) { assetName in
                                    PremiumAssetView(name: assetName) {
                                        tearPremiumAsset(assetName)
                                    }
                                }
                            }
                            .padding(.horizontal)
                        }
                    }
                }
                
                VStack(alignment: .leading, spacing: 12) {
                    Text("The Archive")
                        .font(.custom("CormorantGaramond-Bold", size: 22))
                        .padding(.horizontal)
                    
                    LazyVGrid(columns: columns, spacing: 16) {
                        ForEach(mockImages, id: \.self) { name in
                            FeedItemView(name: name) {
                                tearImage(name)
                            }
                        }
                    }
                    .padding(.horizontal)
                }
            }
            .padding(.vertical)
        }
        .navigationTitle("Discovery")
        .overlay {
            if showingTearEffect {
                TearAnimationView()
                    .transition(.opacity)
            }
        }
    }
    
    private func tearImage(_ name: String) {
        withAnimation(.easeInOut(duration: 0.1)) {
            showingTearEffect = true
        }
        
        // Play sound
        SoundService.shared.play(name: "paper-tear", randomizePitch: true)
        
        // Add to clipping folder
        clippingService.addClip(imageUrl: name, sourceUrl: URL(string: "https://dreamroom.app/discover"))
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
            withAnimation {
                showingTearEffect = false
            }
        }
    }
    
    private func tearPremiumAsset(_ name: String) {
        withAnimation(.easeInOut(duration: 0.1)) {
            showingTearEffect = true
        }
        
        // Simulate sound
        print("[Sound] Playing: Paper Tear")
        
        // Add to clipping folder
        clippingService.addClip(imageUrl: name, sourceUrl: URL(string: "https://dreamroom.app/dream-kits"))
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
            withAnimation {
                showingTearEffect = false
            }
        }
    }
}

struct PremiumAssetView: View {
    let name: String
    let onTear: () -> Void
    
    @State private var isPressing = false
    
    var body: some View {
        ZStack {
            // Placeholder for local asset
            Rectangle()
                .fill(LinearGradient(gradient: Gradient(colors: [.gold.opacity(0.3), .gold.opacity(0.1)]), startPoint: .topLeading, endPoint: .bottomTrailing))
                .frame(width: 120, height: 120)
                .cornerRadius(12)
            
            Text(name)
                .font(.caption2)
                .foregroundColor(.gold)
        }
        .scaleEffect(isPressing ? 0.95 : 1.0)
        .animation(.spring(), value: isPressing)
        .onLongPressGesture(minimumDuration: 0.5, pressing: { pressing in
            isPressing = pressing
        }) {
            onTear()
            UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
        }
    }
}

struct FeedItemView: View {
    let name: String
    let onTear: () -> Void
    
    @State private var isPressing = false
    
    var body: some View {
        ZStack {
            // Check if it's a bundle asset or remote URL
            if name.hasPrefix("dream-") {
                // Local premium asset representation
                ZStack {
                    Rectangle()
                        .fill(Color(red: 0.05, green: 0.05, blue: 0.08))
                        .frame(height: 200)
                    
                    VStack {
                        Image(systemName: "photo.artframe")
                            .font(.largeTitle)
                            .foregroundColor(.gold.opacity(0.5))
                        Text(name)
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                }
                .cornerRadius(12)
            } else {
                AsyncImage(url: URL(string: name)) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(minWidth: 0, maxWidth: .infinity)
                        .frame(height: 200)
                        .clipped()
                        .cornerRadius(12)
                } placeholder: {
                    Color.gray.opacity(0.2)
                        .frame(height: 200)
                        .cornerRadius(12)
                }
            }
        }
        .scaleEffect(isPressing ? 0.95 : 1.0)
        .shadow(radius: isPressing ? 10 : 0)
        .animation(.spring(), value: isPressing)
        .onLongPressGesture(minimumDuration: 0.8, pressing: { pressing in
            isPressing = pressing
        }) {
            onTear()
            UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
        }
    }
}

struct TearAnimationView: View {
    var body: some View {
        ZStack {
            Color.black.opacity(0.1).edgesIgnoringSafeArea(.all)
            
            // Visual representation of a "tear"
            VStack(spacing: 0) {
                Rectangle()
                    .fill(Color.white)
                    .frame(width: 200, height: 100)
                    .offset(x: -10, y: -2)
                    .rotationEffect(.degrees(-5))
                
                Rectangle()
                    .fill(Color.white)
                    .frame(width: 200, height: 100)
                    .offset(x: 10, y: 2)
                    .rotationEffect(.degrees(5))
            }
            .mask(
                Image(systemName: "scissors") // Just a placeholder for the tear path
                    .resizable()
                    .aspectRatio(contentMode: .fit)
            )
            .shadow(radius: 20)
        }
    }
}
