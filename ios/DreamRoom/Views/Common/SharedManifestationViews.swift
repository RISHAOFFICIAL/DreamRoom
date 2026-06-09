import SwiftUI

struct WitnessSealView: View {
    var color: Color = .gold
    
    var body: some View {
        ZStack {
            Circle()
                .stroke(color.opacity(0.4), lineWidth: 2)
                .frame(width: 200, height: 200)
            
            Image(systemName: "checkmark")
                .font(.system(size: 80, weight: .light))
                .foregroundColor(color)
            
            Text("WITNESSED")
                .font(.custom(DreamTheme.fontName, size: 20))
                .foregroundColor(color)
                .tracking(2)
                .offset(y: 70)
        }
    }
}

struct LinenTextureView: View {
    var color: Color = .gold
    
    var body: some View {
        Canvas { context, size in
            let step: CGFloat = 10
            for x in stride(from: 0, through: size.width, by: step) {
                context.stroke(
                    Path { path in
                        path.move(to: CGPoint(x: x, y: 0))
                        path.addLine(to: CGPoint(x: x, y: size.height))
                    },
                    with: .color(color.opacity(0.1)),
                    lineWidth: 0.5
                )
            }
            for y in stride(from: 0, through: size.height, by: step) {
                context.stroke(
                    Path { path in
                        path.move(to: CGPoint(x: 0, y: y))
                        path.addLine(to: CGPoint(x: size.width, y: y))
                    },
                    with: .color(color.opacity(0.1)),
                    lineWidth: 0.5
                )
            }
        }
    }
}
