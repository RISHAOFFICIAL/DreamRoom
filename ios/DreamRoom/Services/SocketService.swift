import Foundation
import Combine
import SocketIO

/**
 * SocketService handles real-time communication with the backend.
 * Uses the Socket.io-Client-Swift package.
 */
class SocketService: ObservableObject {
    static let shared = SocketService()
    
    @Published var isConnected = false
    @Published var isReconnecting = false
    
    private var manager: SocketManager?
    private var socket: SocketIOClient?
    
    private var reconnectTimer: Timer?
    private var retryCount = 0
    private let maxRetries = 5
    
    // MARK: - Incoming Events
    let participantJoined = PassthroughSubject<Participant, Never>()
    let partyUpdated = PassthroughSubject<PartyData, Never>()
    let goldenRevealTriggered = PassthroughSubject<String, Never>()
    let goldenHourToggled = PassthroughSubject<Bool, Never>()
    let errorReceived = PassthroughSubject<String, Never>()
    
    private init() {
        // In the sandbox environment, the backend runs on Port 3001
        // We use 0.0.0.0 to ensure public accessibility if needed, 
        // but localhost is fine for internal sandbox communication.
        let url = URL(string: "http://localhost:3001")!
        manager = SocketManager(socketURL: url, config: [.log(false), .compress])
        socket = manager?.defaultSocket
        
        setupHandlers()
    }
    
    private func setupHandlers() {
        socket?.on(clientEvent: .connect) { [weak self] data, ack in
            print("[Socket] Connected")
            self?.isConnected = true
            self?.isReconnecting = false
            self?.retryCount = 0
        }
        
        socket?.on(clientEvent: .disconnect) { [weak self] data, ack in
            print("[Socket] Disconnected")
            self?.isConnected = false
        }
        
        socket?.on(clientEvent: .reconnectAttempt) { [weak self] data, ack in
            print("[Socket] Reconnecting...")
            self?.isReconnecting = true
        }
        
        socket?.on("partyUpdated") { [weak self] data, ack in
            guard let dict = data[0] as? [String: Any],
                  let partyData = self?.parsePartyData(dict) else { return }
            self?.partyUpdated.send(partyData)
        }
        
        socket?.on("goldenHourToggled") { [weak self] data, ack in
            guard let enabled = data[0] as? Bool else { return }
            self?.goldenHourToggled.send(enabled)
        }
        
        socket?.on("goldenRevealTriggered") { [weak self] data, ack in
            guard let partyId = data[0] as? String else { return }
            self?.goldenRevealTriggered.send(partyId)
        }
        
        socket?.on("error") { [weak self] data, ack in
            guard let message = data[0] as? String else { return }
            self?.errorReceived.send(message)
        }
    }
    
    func connect() {
        print("[Socket] Connecting to server...")
        socket?.connect()
    }
    
    func disconnect() {
        socket?.disconnect()
    }
    
    // MARK: - Outgoing Events
    
    func createParty(hostName: String, ssid: String? = nil) {
        socket?.emit("createParty", hostName, ssid ?? "")
    }
    
    func joinParty(partyId: String, userName: String, ssid: String? = nil) {
        socket?.emit("joinParty", partyId, userName, ssid ?? "")
    }
    
    func updateBuildingState(partyId: String, isBuilding: Bool) {
        socket?.emit("updateBuildingState", partyId, isBuilding)
    }
    
    func triggerReveal(partyId: String) {
        socket?.emit("triggerReveal", partyId)
    }
    
    func toggleGoldenHour(partyId: String, enabled: Bool) {
        socket?.emit("toggleGoldenHour", partyId, enabled)
    }
    
    func updateNearbyDevices(partyId: String, count: Int) {
        socket?.emit("updateNearbyDevices", partyId, count)
    }
    
    // MARK: - Parsing
    
    private func parsePartyData(_ dict: [String: Any]) -> PartyData? {
        // Simple manual parsing for MVP
        guard let id = dict["id"] as? String,
              let status = dict["status"] as? String,
              let isGoldenHour = dict["isGoldenHour"] as? Bool,
              let participantsDict = dict["participants"] as? [[String: Any]] else {
            return nil
        }
        
        let participants = participantsDict.compactMap { pDict -> Participant? in
            guard let pId = pDict["id"] as? String,
                  let pName = pDict["name"] as? String,
                  let pIsHost = pDict["isHost"] as? Bool else {
                return nil
            }
            return Participant(
                id: pId,
                name: pName,
                isHost: pIsHost,
                ssid: pDict["ssid"] as? String,
                isBuilding: pDict["isBuilding"] as? Bool ?? false
            )
        }
        
        return PartyData(
            id: id,
            status: status,
            participants: participants,
            isGoldenHour: isGoldenHour
        )
    }
}

struct PartyData {
    let id: String
    let status: String
    let participants: [Participant]
    let isGoldenHour: Bool
}
