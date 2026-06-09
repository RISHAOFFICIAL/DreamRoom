import Foundation
import SwiftUI
import Combine

enum RecallStep: Equatable {
    case intro
    case item(Int) // Index of the item
    case finalReveal
    
    static func == (lhs: RecallStep, rhs: RecallStep) -> Bool {
        switch (lhs, rhs) {
        case (.intro, .intro): return true
        case (.finalReveal, .finalReveal): return true
        case (.item(let i1), .item(let i2)): return i1 == i2
        default: return false
        }
    }
}

enum RecallMilestone: String, CaseIterable {
    case nextDay = "The First Spark"
    case oneWeek = "Gaining Momentum"
    case oneMonth = "Vision in Motion"
}

class RecallViewModel: ObservableObject {
    @Published var currentStep: RecallStep = .intro
    @Published var items: [BoardItem] = []
    @Published var progress: Double = 0
    @Published var isPlaying: Bool = false
    @Published var milestone: RecallMilestone = .nextDay
    
    var soundscapeName: String {
        switch milestone {
        case .nextDay:
            return "zen-forest"
        case .oneWeek:
            return "urban-ambient"
        case .oneMonth:
            return "celestial"
        }
    }
    
    private var timer: AnyCancellable?
    private let itemDuration: TimeInterval = 5.0
    private let introDuration: TimeInterval = 3.0
    
    init(items: [BoardItem], milestone: RecallMilestone = .nextDay) {
        self.milestone = milestone
        
        switch milestone {
        case .nextDay:
            // Design doc: Focuses on the "core" 3-5 items placed.
            self.items = Array(items.prefix(5))
        case .oneWeek:
            // Highlight items that were "witnessed".
            let witnessed = items.filter { $0.hasWitnessSeal }
            if witnessed.isEmpty {
                self.items = Array(items.prefix(5))
            } else {
                self.items = witnessed
            }
        case .oneMonth:
            // Full board overview.
            self.items = Array(items.prefix(10))
        }
    }
    
    func start() {
        isPlaying = true
        currentStep = .intro
        startTimer(duration: introDuration)
    }
    
    func nextStep() {
        switch currentStep {
        case .intro:
            if !items.isEmpty {
                currentStep = .item(0)
                startTimer(duration: itemDuration)
            } else {
                currentStep = .finalReveal
            }
        case .item(let index):
            if index + 1 < items.count {
                currentStep = .item(index + 1)
                startTimer(duration: itemDuration)
            } else {
                currentStep = .finalReveal
            }
        case .finalReveal:
            isPlaying = false
            timer?.cancel()
        }
    }
    
    private func startTimer(duration: TimeInterval) {
        progress = 0
        timer?.cancel()
        timer = Timer.publish(every: 0.05, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                guard let self = self else { return }
                withAnimation(.linear(duration: 0.05)) {
                    self.progress += 0.05 / duration
                }
                if self.progress >= 1.0 {
                    self.nextStep()
                }
            }
    }
    
    func skip() {
        nextStep()
    }
}
