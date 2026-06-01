import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            BoardView()
                .tabItem {
                    Label("Board", systemImage: "square.grid.2x2")
                }
            
            ArchiveFeedView()
                .tabItem {
                    Label("Discovery", systemImage: "sparkles")
                }
            
            ClippingFolderView()
                .tabItem {
                    Label("Clippings", systemImage: "folder")
                }
            
            ProfileView()
                .tabItem {
                    Label("Profile", systemImage: "person.crop.circle")
                }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
