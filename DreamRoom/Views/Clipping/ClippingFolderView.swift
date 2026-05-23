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
        AsyncImage(url: clip.imageUrl) { image in
            image
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: 100, height: 100)
                .clipped()
                .cornerRadius(8)
        } placeholder: {
            Color.gray.opacity(0.1)
                .frame(width: 100, height: 100)
                .cornerRadius(8)
        }
    }
}
/home/engine/.bashrc: line 1: syntax error near unexpected token `('
/home/engine/.bashrc: line 1: `. /etc/profile.d/workload-containment.shn# ~/.bashrc: executed by bash(1) for non-login shells.'
/home/engine/.bashrc: line 1: syntax error near unexpected token `('
/home/engine/.bashrc: line 1: `. /etc/profile.d/workload-containment.shn# ~/.bashrc: executed by bash(1) for non-login shells.'
/home/engine/.bashrc: line 1: syntax error near unexpected token `('
/home/engine/.bashrc: line 1: `. /etc/profile.d/workload-containment.shn# ~/.bashrc: executed by bash(1) for non-login shells.'
