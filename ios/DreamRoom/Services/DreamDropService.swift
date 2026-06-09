import Foundation
import MultipeerConnectivity
import Combine

/**
 * DreamDropService uses Apple Multipeer Connectivity to share assets between nearby devices.
 * This enables "Dream Drop" - a peer-to-peer asset sharing mechanism that bypasses the backend.
 */
class DreamDropService: NSObject, ObservableObject {
    static let shared = DreamDropService()
    
    @Published var availablePeers: [MCPeerID] = []
    @Published var receivedAsset: String? = nil // URL or Name of the received asset
    
    private let serviceType = "dream-drop"
    private let myPeerId = MCPeerID(displayName: UIDevice.current.name)
    private var serviceAdvertiser: MCNearbyServiceAdvertiser
    private var serviceBrowser: MCNearbyServiceBrowser
    private var session: MCSession
    
    private override init() {
        self.session = MCSession(peer: myPeerId, securityIdentity: nil, encryptionPreference: .required)
        self.serviceAdvertiser = MCNearbyServiceAdvertiser(peer: myPeerId, discoveryInfo: nil, serviceType: serviceType)
        self.serviceBrowser = MCNearbyServiceBrowser(peer: myPeerId, serviceType: serviceType)
        
        super.init()
        
        self.session.delegate = self
        self.serviceAdvertiser.delegate = self
        self.serviceBrowser.delegate = self
    }
    
    func start() {
        print("[DreamDrop] Starting services...")
        serviceAdvertiser.startAdvertisingPeer()
        serviceBrowser.startBrowsingForPeers()
    }
    
    func stop() {
        print("[DreamDrop] Stopping services...")
        serviceAdvertiser.stopAdvertisingPeer()
        serviceBrowser.stopBrowsingForPeers()
    }
    
    func sendAsset(name: String, to peer: MCPeerID) {
        print("[DreamDrop] Sending asset '\(name)' to peer: \(peer.displayName)")
        
        // Invite peer to session if not already connected
        if session.connectedPeers.contains(peer) {
            do {
                let data = name.data(using: .utf8)!
                try session.send(data, toPeers: [peer], with: .reliable)
            } catch {
                print("[DreamDrop] Error sending asset: \(error.localizedDescription)")
            }
        } else {
            print("[DreamDrop] Peer not connected, sending invitation...")
            serviceBrowser.invitePeer(peer, to: session, withContext: nil, timeout: 30)
            // Note: In a real app, we'd wait for connection before sending.
            // This is a prototype simplified logic.
        }
    }
    
    func broadcastAsset(name: String) {
        print("[DreamDrop] Broadcasting asset '\(name)' to all connected peers")
        guard !session.connectedPeers.isEmpty else { return }
        
        do {
            let data = name.data(using: .utf8)!
            try session.send(data, toPeers: session.connectedPeers, with: .reliable)
        } catch {
            print("[DreamDrop] Error broadcasting asset: \(error.localizedDescription)")
        }
    }
}

extension DreamDropService: MCSessionDelegate {
    func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
        switch state {
        case .connected:
            print("[DreamDrop] Peer connected: \(peerID.displayName)")
        case .connecting:
            print("[DreamDrop] Peer connecting: \(peerID.displayName)")
        case .notConnected:
            print("[DreamDrop] Peer disconnected: \(peerID.displayName)")
        @unknown default:
            break
        }
    }
    
    func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
        if let assetName = String(data: data, encoding: .utf8) {
            print("[DreamDrop] Received asset '\(assetName)' from \(peerID.displayName)")
            DispatchQueue.main.async {
                self.receivedAsset = assetName
                // Trigger a notification or toast in the UI
            }
        }
    }
    
    func session(_ session: MCSession, didReceive stream: InputStream, withName streamName: String, fromPeer peerID: MCPeerID) {}
    func session(_ session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, with progress: Progress) {}
    func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, at localURL: URL?, withError error: Error?) {}
}

extension DreamDropService: MCNearbyServiceAdvertiserDelegate {
    func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didReceiveInvitationFromPeer peerID: MCPeerID, withContext context: Data?, invitationHandler: @escaping (Bool, MCSession?) -> Void) {
        print("[DreamDrop] Received invitation from \(peerID.displayName). Accepting...")
        invitationHandler(true, self.session)
    }
}

extension DreamDropService: MCNearbyServiceBrowserDelegate {
    func browser(_ browser: MCNearbyServiceBrowser, foundPeer peerID: MCPeerID, withDiscoveryInfo info: [String : String]?) {
        print("[DreamDrop] Found peer: \(peerID.displayName)")
        DispatchQueue.main.async {
            if !self.availablePeers.contains(peerID) {
                self.availablePeers.append(peerID)
            }
        }
    }
    
    func browser(_ browser: MCNearbyServiceBrowser, lostPeer peerID: MCPeerID) {
        print("[DreamDrop] Lost peer: \(peerID.displayName)")
        DispatchQueue.main.async {
            self.availablePeers.removeAll { -bash == peerID }
        }
    }
}
