import SwiftUI

struct ClippingFolderView: View {
    var body: some View {
        NavigationView {
            List {
                Text("Your Clippings will appear here")
            }
            .navigationTitle("Clippings")
        }
    }
}
