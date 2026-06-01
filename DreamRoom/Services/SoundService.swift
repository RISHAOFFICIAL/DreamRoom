import Foundation
import AVFoundation

class SoundService {
    static let shared = SoundService()
    
    private var players: [String: AVAudioPlayer] = [:]
    
    private init() {
        // Preload sounds
        prepareSound(name: "paper-tear")
        prepareSound(name: "soft-settle")
        prepareSound(name: "golden-hour-transition")
        prepareSound(name: "cinematic-reveal")
    }
    
    private func prepareSound(name: String) {
        // Search in the shared directory or bundle
        // For the purpose of this mock, we look in the shared assets directory
        let sharedPath = "/home/team/shared/assets/final_assets/audio/\(name).m4a"
        let url = URL(fileURLWithPath: sharedPath)
        
        do {
            let player = try AVAudioPlayer(contentsOf: url)
            player.prepareToPlay()
            players[name] = player
        } catch {
            print("[SoundService] Could not load sound \(name): \(error.localizedDescription)")
        }
    }
    
    func play(name: String, randomizePitch: Bool = false) {
        guard let player = players[name] else {
            print("[SoundService] Sound \(name) not loaded")
            return
        }
        
        if player.isPlaying {
            player.stop()
            player.currentTime = 0
        }
        
        if randomizePitch {
            // AVAudioPlayer doesn't support pitch shifting directly without AVAudioEngine
            // but we can simulate it if needed. For now, just play.
            player.enableRate = true
            player.rate = Float.random(in: 0.95...1.05)
        }
        
        player.play()
        print("[SoundService] Playing sound: \(name)")
    }
}
