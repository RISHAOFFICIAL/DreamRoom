import SwiftUI

struct BoardView: View {
    var body: some View {
        ZStack {
            Color(.systemBackground)
                .edgesIgnoringSafeArea(.all)
            
            Text("Vision Board Canvas")
                .font(.largeTitle)
                .foregroundColor(.secondary)
        }
    }
}
