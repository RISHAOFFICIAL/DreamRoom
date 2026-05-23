import SwiftUI

struct ArchiveFeedView: View {
    @StateObject private var clippingService = ClippingService.shared
    @State private var showingTearEffect = false
    @State private var tornImage: URL?
    
    // Mock feed data
    let mockImages = [
        URL(string: "https://images.unsplash.com/photo-1518005020251-eceaf52b507c")!,
        URL(string: "https://images.unsplash.com/photo-1522202176988-66273c2fd55f")!,
        URL(string: "https://images.unsplash.com/photo-1502672260266-1c1ef2d93688")!,
        URL(string: "https://images.unsplash.com/photo-1493666438817-866a91353ca9")!,
        URL(string: "https://images.unsplash.com/photo-1513161455079-7dc1de15ef3e")!,
        URL(string: "https://images.unsplash.com/photo-1449247709967-d4461a6a6103")!
    ]
    
    let columns = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    var body: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: 16) {
                ForEach(mockImages, id: \.self) { url in
                    FeedItemView(url: url) {
                        tearImage(url)
                    }
                }
            }
            .padding()
        }
        .navigationTitle("The Archive")
        .overlay {
            if showingTearEffect {
                TearAnimationView()
                    .transition(.opacity)
            }
        }
    }
    
    private func tearImage(_ url: URL) {
        tornImage = url
        withAnimation(.easeInOut(duration: 0.1)) {
            showingTearEffect = true
        }
        
        // Simulate sound
        print("[Sound] Playing: Paper Tear")
        
        // Add to clipping folder
        clippingService.addClip(imageUrl: url, sourceUrl: URL(string: "https://dreamroom.app/discover"))
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
            withAnimation {
                showingTearEffect = false
            }
        }
    }
}

struct FeedItemView: View {
    let url: URL
    let onTear: () -> Void
    
    @State private var isPressing = false
    
    var body: some View {
        AsyncImage(url: url) { image in
            image
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(minWidth: 0, maxWidth: .infinity)
                .frame(height: 200)
                .clipped()
                .cornerRadius(12)
                .scaleEffect(isPressing ? 0.95 : 1.0)
                .shadow(radius: isPressing ? 10 : 0)
                .animation(.spring(), value: isPressing)
        } placeholder: {
            Color.gray.opacity(0.2)
                .frame(height: 200)
                .cornerRadius(12)
        }
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
