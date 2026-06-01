import Foundation
import Combine

/**
 * SocketService handles real-time communication with the backend.
 * In a real environment, this would use the Socket.io-Client-Swift package.
 */
class SocketService: ObservableObject {
    static let shared = SocketService()
    
    @Published var isConnected = false
    @Published var isReconnecting = false
    
    private var reconnectTimer: Timer?
    private var retryCount = 0
    private let maxRetries = 5
    
    private init() {
        // Setup socket configuration
        // let url = URL(string: "http://0.0.0.0:3000")!
        // manager = SocketManager(socketURL: url, config: [.log(true), .compress])
        // socket = manager?.defaultSocket
    }
    
    func connect() {
        print("[Socket] Connecting to server...")
        isReconnecting = true
        
        // Simulate connection logic with retry
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            // Simulate spotty connection: 30% chance of failure
            let success = Double.random(in: 0...1) > 0.3
            
            if success {
                self.isConnected = true
                self.isReconnecting = false
                self.retryCount = 0
                print("[Socket] Connected")
            } else {
                print("[Socket] Connection failed")
                self.attemptReconnect()
            }
        }
    }
    
    /**
     * Reconnection strategy for the Detroit Tour:
     * - Uses exponential backoff to avoid hammering the server during venue-wide outages.
     * - Retries up to 5 times before requiring manual intervention.
     * - Maintains an 'isReconnecting' state to show a subtle UI indicator to the user.
     */
    private func attemptReconnect() {
        guard retryCount < maxRetries else {
            isReconnecting = false
            print("[Socket] Max retries reached. Manual intervention needed.")
            return
        }
        
        retryCount += 1
        let delay = pow(2.0, Double(retryCount)) // Exponential backoff
        print("[Socket] Reconnecting in \(delay)s (Attempt \(retryCount))")
        
        reconnectTimer?.invalidate()
        reconnectTimer = Timer.scheduledTimer(withTimeInterval: delay, repeats: false) { [weak self] _ in
            self?.connect()
        }
    }
    
    func disconnect() {
        reconnectTimer?.invalidate()
        self.isConnected = false
        self.isReconnecting = false
        print("[Socket] Disconnected")
    }
    
    // MARK: - Outgoing Events
    
    func joinParty(partyId: String, userId: String, name: String, ssid: String? = nil) {
        var data: [String: Any] = [
            "partyId": partyId,
            "userId": userId,
            "name": name
        ]
        if let ssid = ssid {
            data["ssid"] = ssid
        }
        print("[Socket] Sending joinParty: \(data)")
        // socket?.emit("joinParty", data)
    }
    
    func sendBuildingState(partyId: String, userId: String, isBuilding: Bool) {
        let data: [String: Any] = [
            "partyId": partyId,
            "userId": userId,
            "isBuilding": isBuilding
        ]
        print("[Socket] Sending updateBuildingState: \(data)")
        // socket?.emit("updateBuildingState", data)
    }
    
    func triggerReveal(partyId: String) {
        print("[Socket] Sending triggerReveal for party: \(partyId)")
        // socket?.emit("triggerReveal", ["partyId": partyId])
    }
    
    func sendGoldenHourToggle(partyId: String, enabled: Bool) {
        let data: [String: Any] = [
            "partyId": partyId,
            "enabled": enabled
        ]
        print("[Socket] Sending toggleGoldenHour: \(data)")
        // socket?.emit("toggleGoldenHour", data)
    }
    
    // MARK: - Incoming Events (Simulated)
    
    // In a real app, these would be handled via socket.on("eventName") callbacks
    // and then published via PassthroughSubjects or @Published properties.
    
    let participantJoined = PassthroughSubject<Participant, Never>()
    let participantLeft = PassthroughSubject<UUID, Never>()
    let buildingStateUpdated = PassthroughSubject<(userId: UUID, isBuilding: Bool), Never>()
    let revealStarted = PassthroughSubject<Int, Never>() // Countdown duration
    let revealTriggered = PassthroughSubject<Void, Never>()
    let goldenHourTriggered = PassthroughSubject<Bool, Never>()
}
