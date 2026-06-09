import Foundation
import UserNotifications

class NotificationService: NSObject, UNUserNotificationCenterDelegate {
    static let shared = NotificationService()
    
    private override init() {
        super.init()
        UNUserNotificationCenter.current().delegate = self
    }
    
    func requestAuthorization() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if granted {
                print("Notification permission granted.")
                // Schedule initial reminders
                DispatchQueue.main.async {
                    self.scheduleRecurringReminders()
                }
            } else if let error = error {
                print("Notification permission error: \(error.localizedDescription)")
            }
        }
    }
    
    func scheduleRecurringReminders() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        
        let items = BoardViewModel.shared.items
        guard !items.isEmpty else { return }
        
        // Schedule up to 5 reminders
        let count = min(items.count, 5)
        let shuffledItems = items.shuffled()
        
        for i in 0..<count {
            let item = shuffledItems[i]
            let content = UNMutableNotificationContent()
            content.title = "VISION CALLING"
            
            if let text = item.text, !text.isEmpty {
                content.body = "Take a moment to witness your progress on \"\(text)\"."
            } else {
                content.body = "Take a moment to witness your progress."
            }
            
            content.sound = .default
            content.userInfo = ["itemId": item.id.uuidString]
            
            // Random time in the next few days for demo purposes
            // In real app, might be a set schedule
            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: Double(86400 * (i + 1)), repeats: false)
            
            let request = UNNotificationRequest(identifier: "vision-reminder-\(item.id.uuidString)", content: content, trigger: trigger)
            
            UNUserNotificationCenter.current().add(request) { error in
                if let error = error {
                    print("Error scheduling notification: \(error.localizedDescription)")
                }
            }
        }
    }
    
    func scheduleGoldenSparkNotification(from friendName: String, itemId: UUID) {
        let content = UNMutableNotificationContent()
        content.title = "VISION CALLING"
        content.body = "\(friendName) just flicked a dream your way."
        content.sound = .default
        content.userInfo = ["itemId": itemId.uuidString]
        
        let request = UNNotificationRequest(identifier: "golden-spark-\(UUID().uuidString)", content: content, trigger: nil) // Deliver immediately
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error scheduling golden spark notification: \(error.localizedDescription)")
            }
        }
    }
    
    // MARK: - UNUserNotificationCenterDelegate
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        let userInfo = response.notification.request.content.userInfo
        if let itemIdString = userInfo["itemId"] as? String, let itemId = UUID(uuidString: itemIdString) {
            // Handle deep link
            NotificationCenter.default.post(name: .didReceiveDeepLink, object: nil, userInfo: ["itemId": itemId])
        }
        completionHandler()
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.banner, .sound])
    }
}

extension Notification.Name {
    static let didReceiveDeepLink = Notification.Name("didReceiveDeepLink")
}
