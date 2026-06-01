import Foundation
import SwiftUI

class ProfileViewModel: ObservableObject {
    @Published var userProfile: UserProfile {
        didSet {
            saveProfile()
        }
    }
    
    private let profileKey = "dreamroom.userProfile"
    
    init() {
        if let data = UserDefaults.standard.data(forKey: profileKey),
           let decoded = try? JSONDecoder().decode(UserProfile.self, from: data) {
            self.userProfile = decoded
        } else {
            self.userProfile = UserProfile(name: "New Dreamer", bio: "Building my vision...")
        }
    }
    
    private func saveProfile() {
        if let encoded = try? JSONEncoder().encode(userProfile) {
            UserDefaults.standard.set(encoded, forKey: profileKey)
        }
    }
}
