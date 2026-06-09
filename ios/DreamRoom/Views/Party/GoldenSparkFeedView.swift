import SwiftUI

struct GoldenSparkFeedView: View {
    let sparks: [GoldenSpark]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            ForEach(sparks.suffix(3).reversed()) { spark in
                HStack {
                    Image(systemName: "sparkles")
                        .foregroundColor(.gold)
                    Text(spark.fromName)
                        .font(.custom("CormorantGaramond-Bold", size: 14))
                        .foregroundColor(.gold)
                    Text("witnessed a dream")
                        .font(.custom("CormorantGaramond-Italic", size: 14))
                        .foregroundColor(.white.opacity(0.8))
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(BlurView(style: .systemThinMaterialDark))
                .cornerRadius(20)
                .transition(.move(edge: .leading).combined(with: .opacity))
            }
        }
        .padding()
    }
}

struct BlurView: UIViewRepresentable {
    var style: UIBlurEffect.Style
    
    func makeUIView(context: Context) -> UIVisualEffectView {
        UIVisualEffectView(effect: UIBlurEffect(style: style))
    }
    
    func updateUIView(_ uiView: UIVisualEffectView, context: Context) {
        uiView.effect = UIBlurEffect(style: style)
    }
}
