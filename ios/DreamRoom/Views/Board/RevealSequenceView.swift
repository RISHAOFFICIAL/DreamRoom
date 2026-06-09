import SwiftUI

enum RevealStep {
    case anticipation
    case reveal
    case celebration
}

struct RevealSequenceView: View {
    let participantsCount: Int
    let userName: String
    var onComplete: () -> Void
    
    @State private var step: RevealStep = .anticipation
    @State private var backgroundOpacity: Double = 0.5
    @State private var gradientOffset: CGFloat = 0
    @State private var isGlowActive: Bool = false
    
    var body: some View {
        ZStack {
            // Dark luxury background
            Color.dreamBackground
                .edgesIgnoringSafeArea(.all)
            
            // Atmospheric Shift: Moving gold radial gradient
            RadialGradient(
                gradient: Gradient(colors: [Color.gold.opacity(0.15), .clear]),
                center: .center,
                startRadius: 5,
                endRadius: 600
            )
            .scaleEffect(isGlowActive ? 1.2 : 0.8)
            .offset(x: gradientOffset, y: gradientOffset)
            .opacity(backgroundOpacity)
            .onAppear {
                withAnimation(.easeInOut(duration: 4).repeatForever(autoreverses: true)) {
                    gradientOffset = 50
                    isGlowActive = true
                }
            }
            
            VStack {
                if step == .anticipation {
                    VStack(spacing: 24) {
                        Text("THE GOLDEN HOUR")
                            .font(.custom(DreamTheme.boldFontName, size: 16))
                            .tracking(10)
                            .foregroundColor(.gold)
                        
                        Text("Silence Your Mind")
                            .font(.custom(DreamTheme.italicFontName, size: 52))
                            .foregroundColor(.white)
                    }
                    .transition(.asymmetric(
                        insertion: .scale(scale: 0.9).combined(with: .opacity),
                        removal: .scale(scale: 1.1).combined(with: .opacity)
                    ))
                } else if step == .reveal {
                    VStack(spacing: 40) {
                        VStack(spacing: 12) {
                            Text("The Collective Vision")
                                .font(.custom(DreamTheme.boldFontName, size: 36))
                                .foregroundColor(.gold)
                            Text("Witnessed by \(participantsCount) dreamers")
                                .font(.custom(DreamTheme.italicFontName, size: 20))
                                .foregroundColor(.white.opacity(0.7))
                        }
                        
                        // Board Canvas Placeholder (Luxury Frame)
                        ZStack {
                            RoundedRectangle(cornerRadius: 32)
                                .fill(Color.black)
                                .frame(width: 320, height: 480)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 32)
                                        .stroke(Color.gold, lineWidth: 1.5)
                                )
                                .shadow(color: Color.gold.opacity(0.3), radius: 40)
                            
                            LinenTextureView()
                                .opacity(0.1)
                                .clipShape(RoundedRectangle(cornerRadius: 32))
                            
                            Text("DREAMS")
                                .font(.custom(DreamTheme.italicFontName, size: 84))
                                .foregroundColor(.gold.opacity(0.15))
                            
                            // Seal placeholder
                            WitnessSealView()
                                .scaleEffect(0.3)
                                .offset(y: 180)
                        }
                        .padding(.horizontal)
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                    }
                } else if step == .celebration {
                    VStack(spacing: 48) {
                        VStack(spacing: 24) {
                            Image(systemName: "sparkles")
                                .font(.system(size: 64))
                                .foregroundColor(.gold)
                                .shadow(color: .gold.opacity(0.5), radius: 10)
                            
                            Text("Manifested, \(userName)")
                                .font(.custom(DreamTheme.italicFontName, size: 44))
                                .foregroundColor(.gold)
                                .multilineTextAlignment(.center)
                            
                            Text("Your dreams have been witnessed by the circle. Now, step into the light.")
                                .font(.custom(DreamTheme.fontName, size: 18))
                                .foregroundColor(.white.opacity(0.85))
                                .multilineTextAlignment(.center)
                                .lineSpacing(6)
                                .padding(.horizontal, 48)
                        }
                        
                        VStack(spacing: 28) {
                            Button(action: onComplete) {
                                Text("CONTINUE THE JOURNEY")
                                    .font(.custom(DreamTheme.boldFontName, size: 14))
                                    .tracking(2)
                                    .padding(.horizontal, 48)
                                    .padding(.vertical, 22)
                                    .background(Color.gold)
                                    .foregroundColor(.dreamBackground)
                                    .clipShape(Capsule())
                                    .shadow(color: Color.gold.opacity(0.4), radius: 20)
                            }
                            
                            Text("Share your vision to inspire others.")
                                .font(.custom(DreamTheme.fontName, size: 14))
                                .foregroundColor(.white.opacity(0.4))
                        }
                    }
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                }
            }
            
            // Cinematic Particles: Shimmering gold particles
            RevealParticlesView()
                .edgesIgnoringSafeArea(.all)
                .allowsHitTesting(false)
        }
        .onAppear {
            SoundService.shared.play(name: "reveal-shimmer")
            
            // Haptics buildup
            let generator = UIImpactFeedbackGenerator(style: .soft)
            generator.prepare()
            
            // Repeat soft haptics during anticipation
            Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { timer in
                if step == .anticipation {
                    generator.impactOccurred(intensity: 0.5)
                } else {
                    timer.invalidate()
                }
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 4) {
                withAnimation(.easeInOut(duration: 1.2)) {
                    step = .reveal
                    UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
                }
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 10) {
                withAnimation(.easeInOut(duration: 1.2)) {
                    step = .celebration
                    UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                }
            }
        }
    }
}

struct RevealParticlesView: View {
    let particleCount = 40
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                ForEach(0..<particleCount, id: \.self) { _ in
                    RevealParticleElement(size: geometry.size)
                }
            }
        }
    }
}

struct RevealParticleElement: View {
    let size: CGSize
    @State private var x = CGFloat.random(in: 0...1000)
    @State private var y = CGFloat.random(in: 0...1000)
    @State private var opacity = 0.0
    @State private var scale = 1.0
    
    var body: some View {
        Circle()
            .fill(Color.gold)
            .frame(width: CGFloat.random(in: 1...4), height: CGFloat.random(in: 1...4))
            .position(x: x, y: y)
            .opacity(opacity)
            .scaleEffect(scale)
            .onAppear {
                x = CGFloat.random(in: 0...size.width)
                y = size.height + 20 // Start from bottom
                
                let duration = Double.random(in: 4...8)
                let delay = Double.random(in: 0...4)
                
                withAnimation(Animation.linear(duration: duration).repeatForever(autoreverses: false).delay(delay)) {
                    y = -50 // Rise to top
                }
                
                withAnimation(Animation.easeInOut(duration: 1.5).repeatForever(autoreverses: true).delay(delay)) {
                    opacity = Double.random(in: 0.3...0.9)
                    scale = Double.random(in: 0.5...1.5)
                    x += CGFloat.random(in: -20...20)
                }
            }
    }
}
