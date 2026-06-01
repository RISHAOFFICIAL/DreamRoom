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
    
    private var cancellables = Set<AnyCancellable>()
    private let socketService = SocketService.shared
    private var partyId: String
    private var userId: String = UUID().uuidString
    
    init(partyId: String = "test-party-123") {
        self.partyId = partyId
        setupSocketSubscriptions()
        
        // Mock initial state
        participants = [
            Participant(id: UUID(), name: "Blake", avatarUrl: nil, isBuilding: true),
            Participant(id: UUID(), name: "Casey", avatarUrl: nil, isBuilding: true)
        ]
        
        socketService.connect()
        
        // Fetch SSID and then join
        WiFiService.shared.fetchCurrentSSID()
        
        // In a real app, we would wait for the SSID to be fetched or observe it
        // For now, we'll just join after a short delay or with the initial value
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.socketService.joinParty(
                partyId: self.partyId,
                userId: self.userId,
                name: "Avery",
                ssid: WiFiService.shared.currentSSID
            )
        }
    }
    
    private func setupSocketSubscriptions() {
        socketService.participantJoined
            .receive(on: DispatchQueue.main)
            .sink { [weak self] participant in
                self?.participants.append(participant)
            }
            .store(in: &cancellables)
        
        socketService.participantLeft
            .receive(on: DispatchQueue.main)
            .sink { [weak self] id in
                self?.participants.removeAll { $0.id == id }
            }
            .store(in: &cancellables)
            
        socketService.buildingStateUpdated
            .receive(on: DispatchQueue.main)
            .sink { [weak self] update in
                if let index = self?.participants.firstIndex(where: { $0.id == update.userId }) {
                    self?.participants[index].isBuilding = update.isBuilding
                }
            }
            .store(in: &cancellables)
            
        socketService.revealStarted
            .receive(on: DispatchQueue.main)
            .sink { [weak self] countdown in
                self?.status = .revealCountdown
                self?.countdown = countdown
                self?.startInternalCountdown()
            }
            .store(in: &cancellables)
            
        socketService.revealTriggered
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in
                self?.status = .revealing
            }
            .store(in: &cancellables)
            
        socketService.goldenHourTriggered
            .receive(on: DispatchQueue.main)
            .sink { [weak self] active in
                if active && !(self?.isGoldenHour ?? true) {
                    SoundService.shared.play(name: "golden-hour-transition")
                }
                withAnimation {
                    self?.isGoldenHour = active
                }
            }
            .store(in: &cancellables)
    }
    
    func startReveal() {
        socketService.triggerReveal(partyId: partyId)
    }
    
    func toggleGoldenHour() {
        // Toggle locally and notify socket
        isGoldenHour.toggle()
        socketService.sendGoldenHourToggle(partyId: partyId, enabled: isGoldenHour)
        
        if isGoldenHour {
            SoundService.shared.play(name: "golden-hour-transition")
        }
    }
    
    private func startInternalCountdown() {
        Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { timer in
            if self.countdown > 0 {
                self.countdown -= 1
            } else {
                timer.invalidate()
            }
        }
    }
    
    func updateBuildingState(isBuilding: Bool) {
        socketService.sendBuildingState(partyId: partyId, userId: userId, isBuilding: isBuilding)
    }
}
