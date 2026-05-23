import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            BoardView()
                .tabItem {
                    Label("Board", systemImage: "square.grid.2x2")
                }
            
            ClippingFolderView()
                .tabItem {
                    Label("Clippings", systemImage: "folder")
                }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
