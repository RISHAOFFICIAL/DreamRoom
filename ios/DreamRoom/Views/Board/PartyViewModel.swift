import Foundation
import SwiftUI
import Combine

struct Participant: Identifiable, Codable {
    let id: String
    var name: String
    var isHost: Bool
    var ssid: String?
    var isBuilding: Bool = false
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
    @Published var isBuilderHosted: Bool = false
    @Published var isHost: Bool = false
    @Published var partyId: String = ""
    @Published var sparks: [GoldenSpark] = []
    
    private var cancellables = Set<AnyCancellable>()
    private let socketService = SocketService.shared
    private let proximityService = ProximityService.shared
    private var userId: String = UUID().uuidString
    
    init(partyId: String = "test-party-123") {
        self.partyId = partyId
        setupSocketSubscriptions()
        setupProximitySubscription()
        
        socketService.connect()
        proximityService.start()
        
        // Fetch SSID and then join
        WiFiService.shared.fetchCurrentSSID()
        
        // Join the party
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.socketService.joinParty(
                partyId: self.partyId,
                userName: "Avery",
                ssid: WiFiService.shared.currentSSID
            )
        }
    }
    
    private func setupSocketSubscriptions() {
        socketService.partyUpdated
            .receive(on: DispatchQueue.main)
            .sink { [weak self] partyData in
                self?.partyId = partyData.id
                self?.participants = partyData.participants
                self?.isGoldenHour = partyData.isGoldenHour
                self?.isBuilderHosted = partyData.isBuilderHosted
                DreamKitService.shared.isBuilderHosted = partyData.isBuilderHosted
                BoardViewModel.shared.activePartyId = partyData.id
                self?.sparks = partyData.sparks
                
                // Update status if needed
                if partyData.status == "reveal" && self?.status == .building {
                    self?.status = .revealCountdown
                    self?.countdown = 10
                    self?.startInternalCountdown()
                } else if partyData.status == "finished" {
                    self?.status = .completed
                }
            }
            .store(in: &cancellables)
            
        socketService.goldenHourToggled
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
            
        socketService.goldenRevealTriggered
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.status = .revealing
            }
            .store(in: &cancellables)
            
        socketService.itemWitnessed
            .receive(on: DispatchQueue.main)
            .sink { [weak self] witnessData in
                // Add spark to local history for immediate feedback
                withAnimation {
                    self?.sparks.append(witnessData.spark)
                }
                
                // If it's for our item, maybe show a special animation or sound
                // (Logic can be added here)
                if self?.isGoldenHour ?? false {
                    SoundService.shared.play(name: "gold-spark")
                }
            }
            .store(in: &cancellables)
            
        socketService.errorReceived
            .receive(on: DispatchQueue.main)
            .sink { message in
                print("[UI Error] \(message)")
            }
            .store(in: &cancellables)
    }
    
    private func setupProximitySubscription() {
        proximityService.$nearbyDevicesCount
            .receive(on: DispatchQueue.main)
            .sink { [weak self] count in
                guard let self = self, !self.partyId.isEmpty else { return }
                self.socketService.updateNearbyDevices(partyId: self.partyId, count: count)
            }
            .store(in: &cancellables)
    }
    
    func startReveal() {
        socketService.triggerReveal(partyId: partyId)
    }
    
    func toggleGoldenHour() {
        socketService.toggleGoldenHour(partyId: partyId, enabled: !isGoldenHour)
    }
    
    func witnessItem(itemId: UUID) {
        socketService.witnessItem(partyId: partyId, itemId: itemId)
        if isGoldenHour {
            SoundService.shared.play(name: "gold-spark")
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
        socketService.sendBuildingState(partyId: partyId, isBuilding: isBuilding)
    }
}
