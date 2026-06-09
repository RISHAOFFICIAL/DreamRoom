import SwiftUI

extension Color {
    static let gold = Color(red: 232/255, green: 201/255, blue: 122/255) // #E8C97A
    static let dreamBackground = Color(red: 14/255, green: 12/255, blue: 20/255) // #0E0C14
    static let sapphire = Color(red: 94/255, green: 143/255, blue: 167/255) // #5E8FA7
}

struct DreamTheme {
    static let gold = Color.gold
    static let background = Color.dreamBackground
    static let sapphire = Color.sapphire
    
    static let fontName = "CormorantGaramond-Regular"
    static let italicFontName = "CormorantGaramond-Italic"
    static let boldFontName = "CormorantGaramond-Bold"
}

struct GoldenHourModifier: ViewModifier {
    var active: Bool
    
    func body(content: Content) -> some View {
        content
            .foregroundColor(active ? .gold : .sapphire)
            .shadow(color: active ? .gold.opacity(0.5) : .clear, radius: active ? 10 : 0)
            .animation(.easeInOut(duration: 0.8), value: active)
    }
}

extension View {
    func goldenHour(active: Bool) -> some View {
        self.modifier(GoldenHourModifier(active: active))
    }
}

struct GoldenHourBackground: View {
    var active: Bool
    @State private var animateGlow = false
    
    var body: some View {
        ZStack {
            Color.dreamBackground
            
            if active {
                RadialGradient(
                    gradient: Gradient(colors: [Color.gold.opacity(0.15), .clear]),
                    center: .center,
                    startRadius: animateGlow ? 10 : 50,
                    endRadius: animateGlow ? 600 : 400
                )
                .onAppear {
                    withAnimation(.easeInOut(duration: 3).repeatForever(autoreverses: true)) {
                        animateGlow = true
                    }
                }
            }
        }
        .edgesIgnoringSafeArea(.all)
    }
}
