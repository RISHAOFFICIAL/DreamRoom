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
    let itemWitnessed = PassthroughSubject<WitnessData, Never>()
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
        
        socket?.on("itemWitnessed") { [weak self] data, ack in
            guard let dict = data[0] as? [String: Any],
                  let itemIdStr = dict["itemId"] as? String,
                  let itemId = UUID(uuidString: itemIdStr),
                  let witnessedBy = dict["witnessedBy"] as? String,
                  let sparkDict = dict["spark"] as? [String: Any],
                  let spark = self?.parseGoldenSpark(sparkDict) else { return }
            
            self?.itemWitnessed.send(WitnessData(itemId: itemId, witnessedBy: witnessedBy, spark: spark))
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
    
    func sendBuildingState(partyId: String, isBuilding: Bool) {
        socket?.emit("updateBuildingState", partyId, isBuilding)
    }
    
    func witnessItem(partyId: String, itemId: UUID) {
        socket?.emit("witnessItem", partyId, itemId.uuidString)
    }
    
    func addItem(partyId: String, item: BoardItem) {
        let itemDict: [String: Any] = [
            "id": item.id.uuidString,
            "url": item.imageUrl ?? "",
            "text": item.text ?? "",
            "x": Double(item.position.x),
            "y": Double(item.position.y),
            "rotation": Double(item.rotation.degrees),
            "scale": Double(item.scale)
        ]
        socket?.emit("addItem", partyId, itemDict)
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
              let isBuilderHosted = dict["isBuilderHosted"] as? Bool,
              let participantsDict = dict["participants"] as? [[String: Any]],
              let itemsDict = dict["items"] as? [[String: Any]] else {
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
        
        let items = itemsDict.compactMap { iDict -> BoardItem? in
            guard let iIdStr = iDict["id"] as? String,
                  let iId = UUID(uuidString: iIdStr),
                  let x = iDict["x"] as? Double,
                  let y = iDict["y"] as? Double else {
                return nil
            }
            
            let url = iDict["url"] as? String
            let text = iDict["text"] as? String
            let rotation = iDict["rotation"] as? Double ?? 0
            let scale = iDict["scale"] as? Double ?? 1.0
            let witnesses = iDict["witnesses"] as? [String] ?? []
            
            return BoardItem(
                id: iId,
                imageUrl: url,
                text: text,
                position: CGPoint(x: x, y: y),
                rotation: Angle(degrees: rotation),
                scale: CGFloat(scale),
                witnesses: witnesses
            )
        }
        
        let sparksDict = dict["sparks"] as? [[String: Any]] ?? []
        let sparks = sparksDict.compactMap { parseGoldenSpark($0) }
        
        return PartyData(
            id: id,
            status: status,
            participants: participants,
            items: items,
            isGoldenHour: isGoldenHour,
            isBuilderHosted: isBuilderHosted,
            sparks: sparks
        )
    }
    
    private func parseGoldenSpark(_ dict: [String: Any]) -> GoldenSpark? {
        guard let id = dict["id"] as? String,
              let fromName = dict["fromName"] as? String,
              let itemIdStr = dict["itemId"] as? String,
              let itemId = UUID(uuidString: itemIdStr),
              let timestamp = dict["timestamp"] as? Double else {
            return nil
        }
        return GoldenSpark(id: id, fromName: fromName, itemId: itemId, timestamp: Date(timeIntervalSince1970: timestamp / 1000.0))
    }
}

struct PartyData {
    let id: String
    let status: String
    let participants: [Participant]
    let items: [BoardItem]
    let isGoldenHour: Bool
    let isBuilderHosted: Bool
    let sparks: [GoldenSpark]
}

struct GoldenSpark: Identifiable, Codable {
    let id: String
    let fromName: String
    let itemId: UUID
    let timestamp: Date
}

struct WitnessData {
    let itemId: UUID
    let witnessedBy: String
    let spark: GoldenSpark
}
