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
    func dispatchNotification() {
        let identifier = "my-morning-notification"
        let title = "Time to take a picture!"
        let body = "You haven't posted your daily photo yet. Share what you've been up to today!"
        let hour = 16
        let minute = 0
        let isDaily = true
        
        let notificationCenter = UNUserNotificationCenter.current()
        
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default
        
        let calendar = Calendar.current
        var dateComponents = DateComponents(calendar: calendar, timeZone: TimeZone.current)
        dateComponents.hour = hour
        dateComponents.minute = minute
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: isDaily)
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
        
        // Remove any previous notifications with the same identifier
        notificationCenter.removePendingNotificationRequests(withIdentifiers: [identifier])
        
        // Add the new notification request
        notificationCenter.add(request) { error in
            if let error = error {
                print("Error scheduling notification: \(error.localizedDescription)")
            } else {
                print("Notification scheduled successfully.")
            }
        }
    }
}
