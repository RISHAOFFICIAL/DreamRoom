import SwiftUI
import Photos

class WallpaperService {
    static let shared = WallpaperService()
    
    @MainActor
    func exportBoardToWallpaper(items: [BoardItem], boardTitle: String = "My Vision") {
        let renderer = ImageRenderer(content: 
            ManifestationWallpaperView(items: items, title: boardTitle)
                .frame(width: 1290, height: 2796) // iPhone 15 Pro Max resolution
        )
        
        renderer.scale = 1.0 // Already using target resolution
        
        if let image = renderer.uiImage {
            UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
            // In a real app, we'd handle completion and permissions
        }
    }
}

struct ManifestationWallpaperView: View {
    let items: [BoardItem]
    let title: String
    
    var body: some View {
        ZStack {
            // Background
            Color.dreamBackground
                .edgesIgnoringSafeArea(.all)
            
            // Texture Overlay (Linen/Silk feel)
            LinenTextureView()
                .opacity(0.15)
            
            // Gold Glow
            RadialGradient(
                gradient: Gradient(colors: [Color.gold.opacity(0.1), .clear]),
                center: .center,
                startRadius: 100,
                endRadius: 1000
            )
            
            // Clock Protection (Top Vignette)
            LinearGradient(
                gradient: Gradient(colors: [Color.black.opacity(0.8), .clear]),
                startPoint: .top,
                endPoint: .init(x: 0.5, y: 0.3)
            )
            .edgesIgnoringSafeArea(.all)
            
            // Manifestation Motif
            VStack {
                Spacer()
                
                ZStack {
                    // Focal Spark (Central Frame)
                    FocalSparkView(item: items.first)
                    
                    // Aspiration Flow (Secondary items)
                    ForEach(items.dropFirst().prefix(6)) { item in
                        AspirationFlowItemView(item: item)
                    }
                }
                .offset(y: 100) // Center it lower to avoid clock
                
                Spacer()
                
                // Branding
                Text("DREAMROOM")
                    .font(.custom(DreamTheme.boldFontName, size: 48))
                    .foregroundColor(.gold)
                    .tracking(10)
                    .padding(.bottom, 100)
            }
            
            // Witness Seal (Lower Right)
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    WitnessSealView()
                        .opacity(0.6) // More subtle for wallpaper
                        .scaleEffect(0.8)
                        .padding(80)
                }
            }
        }
    }
}

struct FocalSparkView: View {
    let item: BoardItem?
    
    var body: some View {
        ZStack {
            // Organic Frame Layers
            Group {
                // Outer subtle organic ring
                OrganicFrameShape()
                    .stroke(Color.gold.opacity(0.3), lineWidth: 1)
                    .frame(width: 950, height: 950)
                    .rotationEffect(.degrees(15))
                
                // Signature Gold Leaf Stroke (Simulated with offset paths)
                OrganicFrameShape()
                    .stroke(Color.gold, lineWidth: 2)
                    .frame(width: 900, height: 900)
                
                // Inner Glow Frame
                OrganicFrameShape()
                    .fill(Color.sapphire.opacity(0.05))
                    .frame(width: 800, height: 800)
                    .overlay(
                        OrganicFrameShape()
                            .stroke(Color.gold.opacity(0.8), lineWidth: 4)
                    )
            }
            
            // Content
            if let item = item {
                VStack(spacing: 20) {
                    if let text = item.text {
                        Text(text.uppercased())
                            .font(.custom(DreamTheme.boldFontName, size: 60))
                            .foregroundColor(.gold)
                            .tracking(8)
                            .multilineTextAlignment(.center)
                            .frame(width: 600)
                        
                        Text("MANIFESTED")
                            .font(.custom(DreamTheme.italicFontName, size: 24))
                            .foregroundColor(.sapphire)
                            .tracking(4)
                    } else {
                        Circle()
                            .fill(Color.sapphire.opacity(0.2))
                            .frame(width: 500, height: 500)
                    }
                }
            }
        }
    }
}

struct OrganicFrameShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let width = rect.width
        let height = rect.height
        
        path.move(to: CGPoint(x: width * 0.5, y: height * 0.05))
        
        // Quad curves for more organic feel than a circle
        path.addQuadCurve(to: CGPoint(x: width * 0.95, y: height * 0.5),
                          control: CGPoint(x: width * 1.05, y: height * 0.05))
        path.addQuadCurve(to: CGPoint(x: width * 0.5, y: height * 0.95),
                          control: CGPoint(x: width * 0.95, y: height * 1.05))
        path.addQuadCurve(to: CGPoint(x: width * 0.05, y: height * 0.5),
                          control: CGPoint(x: width * -0.05, y: height * 0.95))
        path.addQuadCurve(to: CGPoint(x: width * 0.5, y: height * 0.05),
                          control: CGPoint(x: width * 0.05, y: height * -0.05))
        
        return path
    }
}

struct AspirationFlowItemView: View {
    let item: BoardItem
    
    private var flowPosition: CGSize {
        let seed = Double(item.id.uuidString.prefix(4), radix: 16) ?? 0
        let angle = (seed * .pi * 2 / 65535)
        let distance = 600.0 + (seed.truncatingRemainder(dividingBy: 300))
        
        return CGSize(
            width: cos(angle) * distance,
            height: sin(angle) * distance
        )
    }
    
    var body: some View {
        VStack(spacing: 8) {
            if let text = item.text {
                Text(text)
                    .font(.custom(DreamTheme.italicFontName, size: 32))
                    .foregroundColor(.white.opacity(0.9))
                    .padding(.horizontal, 24)
                    .padding(.vertical, 12)
                    .background(
                        ZStack {
                            BlurView(style: .systemThinMaterialDark)
                            OrganicFrameShape()
                                .stroke(Color.gold.opacity(0.4), lineWidth: 0.5)
                        }
                    )
                    .clipShape(Capsule())
            }
        }
        .offset(flowPosition)
        .rotationEffect(.degrees(Double(item.id.uuidString.suffix(2), radix: 16) ?? 0 / 10))
    }
}

struct BlurView: UIViewRepresentable {
    var style: UIBlurEffect.Style
    func makeUIView(context: Context) -> UIVisualEffectView {
        UIVisualEffectView(effect: UIBlurEffect(style: style))
    }
    func updateUIView(_ uiView: UIVisualEffectView, context: Context) {}
}
