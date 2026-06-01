import SwiftUI

struct ClippingFolderView: View {
    @StateObject private var clippingService = ClippingService.shared
    
    let columns = [
        GridItem(.adaptive(minimum: 100))
    ]
    
    var body: some View {
        NavigationView {
            ScrollView {
                if clippingService.clips.isEmpty {
                    VStack(spacing: 20) {
                        Image(systemName: "archivebox")
                            .font(.system(size: 60))
                            .foregroundColor(.secondary)
                        Text("Your Archive is empty")
                            .font(.headline)
                        NavigationLink(destination: ArchiveFeedView()) {
                            Text("Go to Discover")
                                .padding()
                                .background(Color.gold)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                        }
                    }
                    .padding(.top, 100)
                } else {
                    LazyVGrid(columns: columns, spacing: 12) {
                        ForEach(clippingService.clips) { clip in
                            VStack {
                                ClipThumbnailView(clip: clip)
                                    .onTapGesture {
                                        BoardViewModel.shared.addItem(imageUrl: clip.imageUrl)
                                        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                                        SoundService.shared.play(name: "soft-settle", randomizePitch: true)
                                    }
                                
                                if let source = clip.sourceUrl {
                                    Text(source.host ?? "Unknown")
                                        .font(.caption2)
                                        .foregroundColor(.secondary)
                                        .lineLimit(1)
                                }
                            }
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle("The Archive")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    NavigationLink(destination: ArchiveFeedView()) {
                        Image(systemName: "plus")
                    }
                }
            }
        }
    }
}

struct ClipThumbnailView: View {
    let clip: Clip
    
    var body: some View {
        Group {
            if clip.imageUrl.hasPrefix("http") {
                AsyncImage(url: URL(string: clip.imageUrl)) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } placeholder: {
                    ProgressView()
                }
            } else {
                // Dream Kit Asset
                ZStack {
                    Rectangle()
                        .fill(LinearGradient(gradient: Gradient(colors: [.gold.opacity(0.3), .gold.opacity(0.1)]), startPoint: .topLeading, endPoint: .bottomTrailing))
                    
                    Image(systemName: "sparkles")
                        .foregroundColor(.gold)
                }
            }
        }
        .frame(width: 100, height: 100)
        .clipped()
        .cornerRadius(8)
    }
}
