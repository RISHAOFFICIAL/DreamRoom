import SwiftUI
struct BoardItemView: View {
    @Binding var item: BoardItem
    var isPartyMode: Bool = false
    var isGoldenHour: Bool = false
    var onDragStarted: () -> Void
    var onDragEnded: (CGPoint) -> Void
    var onDelete: () -> Void
    var onFlickToFriend: (String) -> Void
    var onWitness: (() -> Void)? = nil
    
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
                if imageUrl.hasPrefix("http") {
                    AsyncImage(url: URL(string: imageUrl)) { image in
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                    } placeholder: {
                        ProgressView()
                            .frame(width: 200, height: 200)
                            .background(Color.gray.opacity(0.3))
                    }
                    .frame(width: 200, height: 200)
                    .cornerRadius(12)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(isGoldenHour ? Color.gold : Color.clear, lineWidth: 1)
                    )
                    .shadow(color: isGoldenHour ? Color.gold.opacity(0.5) : Color.clear, radius: 10)
                } else {
                    // Dream Kit Premium Asset (Mock representation)
                    ZStack {
                        Rectangle()
                            .fill(LinearGradient(gradient: Gradient(colors: [.gold.opacity(0.5), .black.opacity(0.3)]), startPoint: .topLeading, endPoint: .bottomTrailing))
                        
                        VStack {
                            Image(systemName: "sparkles")
                                .font(.title)
                                .foregroundColor(.gold)
                            Text(imageUrl)
                                .font(.custom(DreamTheme.boldFontName, size: 16))
                                .foregroundColor(.white)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal)
                        }
                    }
                    .frame(width: 200, height: 200)
                    .cornerRadius(12)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.gold.opacity(isGoldenHour ? 1.0 : 0.5), lineWidth: isGoldenHour ? 2 : 1)
                    )
                    .shadow(color: isGoldenHour ? Color.gold.opacity(0.6) : Color.clear, radius: 15)
                }
            } else if let text = item.text {
                Text(text)
                    .font(.custom(DreamTheme.fontName, size: 24))
                    .padding()
                    .background(Color.white)
                    .cornerRadius(8)
                    .shadow(radius: 2)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(isGoldenHour ? Color.gold : Color.clear, lineWidth: 1)
                    )
                    .shadow(color: isGoldenHour ? Color.gold.opacity(0.5) : Color.clear, radius: 10)
            }
            
            if item.hasWitnessSeal {
                WitnessSealView()
                    .scaleEffect(0.25)
                    .offset(x: 70, y: 70)
            }
        }
        .scaleEffect(item.scale * currentScale * (isDragging ? 1.15 : 1.0))
        .rotationEffect(item.rotation + currentRotation + flickRotation)
        .offset(x: item.position.x + dragOffset.width, y: item.position.y + dragOffset.height)
        .shadow(color: Color.black.opacity(isDragging ? 0.4 : 0.1), radius: isDragging ? 20 : 5, x: 0, y: isDragging ? 15 : 2)
        .gesture(
            DragGesture()
                .onChanged { value in
                    if !isDragging {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                            isDragging = true
                        }
                        onDragStarted()
                        UIImpactFeedbackGenerator(style: .light).impactOccurred()
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
                    let magnitude = sqrt(pow(velocity.width, 2) + pow(velocity.height, 2))
                    
                    if magnitude > 1000 {
                        UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
                        withAnimation(.interpolatingSpring(stiffness: 50, damping: 10)) {
                            flickRotation = Angle(degrees: Double.random(in: 720...1440))
                            dragOffset = CGSize(width: velocity.width * 3, height: velocity.height * 3)
                        }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                            if velocity.height < -500 {
                                onFlickToFriend(item.imageUrl ?? item.text ?? "")
                            } else {
                                onDelete()
                            }
                        }
                    } else {
                        withAnimation(.spring(response: 0.4, dampingFraction: 0.65, blendDuration: 0)) {
                            item.position = finalPosition
                            dragOffset = .zero
                            isDragging = false
                        }
                        onDragEnded(finalPosition)
                        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                        SoundService.shared.play(name: "soft-settle", randomizePitch: true)
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
        .onTapGesture(count: 2) {
            if isPartyMode {
                onWitness?()
            }
        }
    }
}

