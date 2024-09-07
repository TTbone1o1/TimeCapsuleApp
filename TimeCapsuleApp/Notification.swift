import UIKit
import UserNotifications
import FirebaseFirestore
import FirebaseAuth

class NotificationManager {

    // Singleton instance for easy access
    static let shared = NotificationManager()

    // Firestore reference
    let db = Firestore.firestore()

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

    // Check if the user has posted today by querying Firestore
    private func hasPostedToday(completion: @escaping (Bool) -> Void) {
        guard let user = Auth.auth().currentUser else {
            completion(false) // If no user is authenticated, return false
            return
        }

        let photosCollectionRef = db.collection("users").document(user.uid).collection("photos")

        // Order by the timestamp and limit to the most recent photo
        photosCollectionRef.order(by: "timestamp", descending: true).limit(to: 1).getDocuments { snapshot, error in
            if let error = error {
                print("Error fetching photos: \(error.localizedDescription)")
                completion(false)
                return
            }

            guard let snapshot = snapshot, let document = snapshot.documents.first else {
                print("No photos found.")
                completion(false)
                return
            }

            // Extract the timestamp from the most recent photo
            let data = document.data()
            if let timestamp = data["timestamp"] as? Timestamp {
                let lastPostDate = timestamp.dateValue()
                let calendar = Calendar.current

                // Check if the timestamp is from today
                if calendar.isDateInToday(lastPostDate) {
                    print("User has posted today. No need to send notifications.")
                    completion(true) // User has posted today
                } else {
                    print("User has not posted today. This account needs notifications!!")
                    completion(false) // User has not posted today
                }
            } else {
                print("No valid timestamp found.")
                completion(false)
            }
        }
    }

    // Schedule a daily task to check at 12:00 PM if the user has posted
    func scheduleDailyCheckAtNoon() {
        let notificationCenter = UNUserNotificationCenter.current()
        
        // Remove any previous noon check notifications
        notificationCenter.removePendingNotificationRequests(withIdentifiers: ["noon-check-notification"])
        
        let content = UNMutableNotificationContent()
        content.title = "Checking if you've posted today"
        content.body = "Let's see if you need notifications for posting!"
        content.sound = nil // No sound, this is just a trigger for background logic
        
        var dateComponents = DateComponents()
        dateComponents.hour = 12
        dateComponents.minute = 0

        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        let request = UNNotificationRequest(identifier: "noon-check-notification", content: content, trigger: trigger)

        notificationCenter.add(request) { error in
            if let error = error {
                print("Error scheduling daily check notification: \(error.localizedDescription)")
            } else {
                print("Daily noon check scheduled successfully.")
            }
        }
    }

    // Method to handle what happens when the noon notification triggers
    func handleNoonCheck() {
        hasPostedToday { hasPosted in
            if hasPosted {
                print("User has posted. Cancelling notifications.")
                self.cancelAllNotifications() // If the user has posted, cancel all notifications
            } else {
                print("User has not posted. Scheduling reminder notifications.")
                self.scheduleReminderNotifications() // Schedule notifications if the user hasn't posted
            }
        }
    }

    // Cancel all scheduled notifications
    private func cancelAllNotifications() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        print("All notifications have been cancelled.")
    }

    // Schedule reminder notifications at 2 PM, 4 PM, and 6 PM
    private func scheduleReminderNotifications() {
        let times = [
            (identifier: "my-2pm-notification", hour: 14, minute: 0),
            (identifier: "my-4pm-notification", hour: 16, minute: 0),
            (identifier: "my-6pm-notification", hour: 18, minute: 0)
        ]
        
        let title = "Share what you’re doing right now!"
        let body = "You haven't posted your daily photo yet. Share what you've been up to today!"
        let notificationCenter = UNUserNotificationCenter.current()

        for time in times {
            let content = UNMutableNotificationContent()
            content.title = title
            content.body = body
            content.sound = .default

            var dateComponents = DateComponents()
            dateComponents.hour = time.hour
            dateComponents.minute = time.minute

            let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
            let request = UNNotificationRequest(identifier: time.identifier, content: content, trigger: trigger)

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
