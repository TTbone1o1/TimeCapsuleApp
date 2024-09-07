import UIKit
import UserNotifications

class NotificationManager {
    
    // Singleton instance for easy access
    static let shared = NotificationManager()
    
    // Private initializer to enforce singleton pattern
    private init() {}

    // Method to check and request notification permissions
    func checkForPermission(completion: @escaping (Bool) -> Void) {
        let notificationCenter = UNUserNotificationCenter.current()
        notificationCenter.getNotificationSettings { settings in
            switch settings.authorizationStatus {
            case .authorized:
                completion(true)
            case .denied:
                completion(false)
            case .notDetermined:
                notificationCenter.requestAuthorization(options: [.alert, .sound]) { didAllow, error in
                    completion(didAllow)
                }
            default:
                completion(false)
            }
        }
    }

    // Method to schedule the notification
    func dispatchMultipleNotifications() {
        let times = [
            (identifier: "my-2pm-notification", hour: 14, minute: 0),
            (identifier: "my-4pm-notification", hour: 16, minute: 0),
            (identifier: "my-6pm-notification", hour: 18, minute: 0)
        ]
        
        let title = "Share what you’re doing right now!"
        let body = "You haven't posted your daily photo yet. Share what you've been up to today!"
        let isDaily = true
        let notificationCenter = UNUserNotificationCenter.current()

        for time in times {
            let content = UNMutableNotificationContent()
            content.title = title
            content.body = body
            content.sound = .default
            
            let calendar = Calendar.current
            var dateComponents = DateComponents(calendar: calendar, timeZone: TimeZone.current)
            dateComponents.hour = time.hour
            dateComponents.minute = time.minute
            
            let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: isDaily)
            let request = UNNotificationRequest(identifier: time.identifier, content: content, trigger: trigger)
            
            // Remove any previous notifications with the same identifier
            notificationCenter.removePendingNotificationRequests(withIdentifiers: [time.identifier])
            
            // Add the new notification request
            notificationCenter.add(request) { error in
                if let error = error {
                    print("Error scheduling \(time.identifier): \(error.localizedDescription)")
                } else {
                    print("\(time.identifier) scheduled successfully at \(time.hour):\(time.minute).")
                }
            }
        }
    }
}
