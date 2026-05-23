import Foundation

struct UserProfile: Codable {
    var name: String
    var avatarUrl: String?
    var bio: String
}

enum BoardPrivacy: String, Codable, CaseIterable {
    case privateBoard = "Private"
    case partyOnly = "Party Only"
    case friends = "Friends"
    
    var description: String {
        switch self {
        case .privateBoard: return "Just me"
        case .partyOnly: return "Visible during active parties"
        case .friends: return "Visible to followers"
        }
    }
}

struct BoardSettings: Codable {
    var privacy: BoardPrivacy = .privateBoard
}
