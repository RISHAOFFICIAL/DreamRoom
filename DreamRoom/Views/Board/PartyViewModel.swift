import Foundation
import SwiftUI

struct Participant: Identifiable, Codable {
    let id: UUID
    var name: String
    var avatarUrl: String?
    var isBuilding: Bool = false
    var isReady: Bool = false
}

enum PartyStatus: String, Codable {
    case building
    case revealCountdown
    case revealing
    case completed
}

class PartyViewModel: ObservableObject {
    @Published var participants: [Participant] = []
    @Published var status: PartyStatus = .building
    @Published var countdown: Int = 10
    @Published var isGoldenHour: Bool = false
    @Published var isHost: Bool = false
    
    private var timer: Timer?
    
    init() {
        // Mock participants
        participants = [
            Participant(id: UUID(), name: "Blake", avatarUrl: nil, isBuilding: true),
            Participant(id: UUID(), name: "Casey", avatarUrl: nil, isBuilding: true),
            Participant(id: UUID(), name: "Jordan", avatarUrl: nil, isBuilding: false, isReady: true)
        ]
        
        // Check if Golden Hour should be active (mock)
        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
            withAnimation {
                self.isGoldenHour = true
            }
            // Analytics
            AnalyticsService.shared.track(.ritualReveal(partyId: UUID(), participantCount: self.participants.count))
        }
    }
    
    func startReveal() {
        guard isHost || true else { return } // Force true for demo
        status = .revealCountdown
        countdown = 10
        
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            if self.countdown > 0 {
                self.countdown -= 1
            } else {
                self.timer?.invalidate()
                self.status = .revealing
            }
        }
    }
}
