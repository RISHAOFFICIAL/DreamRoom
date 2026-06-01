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
    
    var body: some View {
        ZStack {
            // Dark luxury background
            Color(red: 0.05, green: 0.05, blue: 0.08)
                .edgesIgnoringSafeArea(.all)
            
            // Background Glow
            RadialGradient(
                gradient: Gradient(colors: [Color.gold.opacity(0.2), .clear]),
                center: .center,
                startRadius: 5,
                endRadius: 500
            )
            .opacity(backgroundOpacity)
            
            VStack {
                if step == .anticipation {
                    VStack(spacing: 20) {
                        Text("THE GOLDEN HOUR")
                            .font(.system(size: 14, weight: .bold))
                            .tracking(8)
                            .foregroundColor(.gold)
                        
                        Text("Silence Your Mind")
                            .font(.custom("CormorantGaramond-Italic", size: 48))
                            .foregroundColor(.white)
                    }
                    .transition(.asymmetric(
                        insertion: .scale(scale: 0.9).combined(with: .opacity),
                        removal: .scale(scale: 1.1).combined(with: .opacity)
                    ))
                } else if step == .reveal {
                    VStack(spacing: 40) {
                        VStack(spacing: 8) {
                            Text("The Collective Vision")
                                .font(.custom("CormorantGaramond-Bold", size: 36))
                                .foregroundColor(.gold)
                            Text("Witnessed by \(participantsCount) dreamers")
                                .font(.custom("CormorantGaramond-Italic", size: 18))
                                .foregroundColor(.white.opacity(0.6))
                        }
                        
                        // Board Canvas Placeholder
                        ZStack {
                            RoundedRectangle(cornerRadius: 30)
                                .fill(Color.black)
                                .frame(width: 320, height: 480)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 30)
                                        .stroke(Color.gold, lineWidth: 2)
                                )
                                .shadow(color: Color.gold.opacity(0.2), radius: 50)
                            
                            Text("DREAMS")
                                .font(.custom("CormorantGaramond-Italic", size: 80))
                                .foregroundColor(.gold.opacity(0.1))
                            
                            LinearGradient(
                                gradient: Gradient(colors: [.clear, .black.opacity(0.6)]),
                                startPoint: .top,
                                endPoint: .bottom
                            )
                            .cornerRadius(30)
                        }
                        .padding(.horizontal)
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                    }
                } else if step == .celebration {
                    VStack(spacing: 40) {
                        VStack(spacing: 20) {
                            Image(systemName: "sparkles")
                                .font(.system(size: 60))
                                .foregroundColor(.gold)
                            
                            Text("Manifest with Us, \(userName)")
                                .font(.custom("CormorantGaramond-Italic", size: 42))
                                .foregroundColor(.gold)
                                .multilineTextAlignment(.center)
                            
                            Text("The gathering doesn't end here. Your dreams have been witnessed. Now, bring them to life.")
                                .font(.custom("CormorantGaramond-Regular", size: 18))
                                .foregroundColor(.white.opacity(0.8))
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 40)
                        }
                        
                        VStack(spacing: 24) {
                            Button(action: onComplete) {
                                HStack(spacing: 12) {
                                    Image(systemName: "applelogo")
                                        .font(.title2)
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text("GET THE APP")
                                            .font(.system(size: 10, weight: .bold))
                                            .tracking(2)
                                        Text("Continue the Gathering")
                                            .font(.custom("CormorantGaramond-Italic", size: 18))
                                    }
                                }
                                .padding(.horizontal, 40)
                                .padding(.vertical, 20)
                                .background(Color.gold)
                                .foregroundColor(Color(red: 0.05, green: 0.05, blue: 0.08))
                                .cornerRadius(40)
                                .shadow(color: Color.gold.opacity(0.3), radius: 30)
                            }
                            
                            Text("Join 2,500+ gathering leaders building their future.")
                                .font(.system(size: 12))
                                .foregroundColor(.white.opacity(0.4))
                        }
                    }
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                }
            }
            
            // Cinematic Particles
            RevealParticlesView()
                .edgesIgnoringSafeArea(.all)
                .allowsHitTesting(false)
        }
        .onAppear {
            SoundService.shared.play(name: "cinematic-reveal")
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 4) {
                withAnimation(.easeInOut(duration: 1.0)) {
                    step = .reveal
                }
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 10) {
                withAnimation(.easeInOut(duration: 1.0)) {
                    step = .celebration
                }
            }
        }
    }
}

struct RevealParticlesView: View {
    let particleCount = 20
    
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
    
    var body: some View {
        Circle()
            .fill(Color.gold)
            .frame(width: 4, height: 4)
            .position(x: x, y: y)
            .opacity(opacity)
            .onAppear {
                x = CGFloat.random(in: 0...size.width)
                y = CGFloat.random(in: 0...size.height)
                
                withAnimation(Animation.easeInOut(duration: Double.random(in: 2...5)).repeatForever(autoreverses: false).delay(Double.random(in: 0...5))) {
                    y -= 200
                    opacity = 0.8
                }
                
                withAnimation(Animation.easeInOut(duration: 1.0).repeatForever(autoreverses: true).delay(Double.random(in: 0...5))) {
                    opacity = 0
                }
            }
    }
}
