import SwiftUI

@main
struct DreamRoomApp: App {
    init() {
        // Initialize notification service and request permissions at app launch
        NotificationService.shared.requestAuthorization()
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
