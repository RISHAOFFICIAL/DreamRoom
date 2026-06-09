import WidgetKit
import SwiftUI

struct VisionWidgetView: View {
    var entry: VisionEntry
    @Environment(\.widgetFamily) var family

    var body: some View {
        ZStack {
            if family == .accessoryRectangular {
                Color.dreamBackground.opacity(0.6)
                    .edgesIgnoringSafeArea(.all)
            } else {
                Color.dreamBackground
                    .edgesIgnoringSafeArea(.all)
            }
            
            switch family {
            case .accessoryCircular:
                CircularVisionWidgetView(entry: entry)
            case .accessoryRectangular:
                RectangularVisionWidgetView(entry: entry)
            case .systemSmall:
                SmallVisionWidgetView(entry: entry)
            default:
                EmptyView()
            }
        }
    }
}

struct CircularVisionWidgetView: View {
    let entry: VisionEntry
    
    var body: some View {
        ZStack {
            // Manifestation Progress Ring
            Circle()
                .stroke(Color.gold.opacity(0.2), lineWidth: 3)
            
            Circle()
                .trim(from: 0, to: entry.progress)
                .stroke(Color.gold, style: StrokeStyle(lineWidth: 3, lineCap: .round))
                .rotationEffect(.degrees(-90))
            
            VStack(spacing: 0) {
                if entry.witnessCount > 0 {
                    // Witness Count Icon
                    ZStack {
                        Circle()
                            .fill(Color.sapphire)
                            .frame(width: 14, height: 14)
                        
                        Text("\(entry.witnessCount)")
                            .font(.system(size: 8, weight: .bold))
                            .foregroundColor(.gold)
                    }
                    .offset(y: -10)
                }
                
                if let item = entry.item, let text = item.text {
                    Text(text.prefix(1))
                        .font(.custom(DreamTheme.fontName, size: 20))
                        .foregroundColor(.white)
                }
            }
        }
    }
}

struct RectangularVisionWidgetView: View {
    let entry: VisionEntry
    
    var body: some View {
        HStack(spacing: 8) {
            // Small Progress Ring on the left
            ZStack {
                Circle()
                    .stroke(Color.gold.opacity(0.2), lineWidth: 2)
                Circle()
                    .trim(from: 0, to: entry.progress)
                    .stroke(Color.gold, style: StrokeStyle(lineWidth: 2, lineCap: .round))
                    .rotationEffect(.degrees(-90))
            }
            .frame(width: 24, height: 24)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(entry.boardTitle)
                    .font(.custom(DreamTheme.italicFontName, size: 14))
                    .foregroundColor(.gold)
                
                HStack(spacing: 4) {
                    // Recent Items Thumbnails
                    ForEach(0..<3) { _ in
                        Circle()
                            .fill(Color.sapphire.opacity(0.2))
                            .frame(width: 20, height: 20)
                            .overlay(
                                Circle()
                                    .stroke(Color.gold.opacity(0.3), lineWidth: 0.5)
                            )
                    }
                    
                    Spacer()
                    
                    Text("\(entry.witnessCount)")
                        .font(.system(size: 8, weight: .bold))
                        .foregroundColor(.gold)
                        .padding(.horizontal, 4)
                        .background(Color.sapphire.opacity(0.3))
                        .clipShape(Capsule())
                }
                
                // Witness Feed (Simulated)
                Text("Blake sent you a Golden Spark")
                    .font(.system(size: 9))
                    .foregroundColor(.white.opacity(0.8))
                    .lineLimit(1)
            }
        }
        .padding(4)
    }
}

struct SmallVisionWidgetView: View {
    let entry: VisionEntry
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Text(entry.boardTitle)
                    .font(.custom(DreamTheme.italicFontName, size: 16))
                    .foregroundColor(.gold)
                Spacer()
                WitnessSealView()
                    .scaleEffect(0.2)
                    .frame(width: 40, height: 40)
            }
            
            Spacer()
            
            if let item = entry.item, let text = item.text {
                Text(text)
                    .font(.custom(DreamTheme.fontName, size: 18))
                    .foregroundColor(.white)
            }
            
            Spacer()
            
            // Progress Bar
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 2)
                        .fill(Color.gold.opacity(0.1))
                        .frame(height: 4)
                    
                    RoundedRectangle(cornerRadius: 2)
                        .fill(Color.gold)
                        .frame(width: geo.size.width * entry.progress, height: 4)
                }
            }
            .frame(height: 4)
        }
        .padding()
    }
}
