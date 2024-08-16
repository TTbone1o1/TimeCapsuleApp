import UserNotifications
import Firebase
import FirebaseFirestore

class Notification {
    static let shared = Notification()
    private let db = Firestore.firestore()

    private init() {}

    func scheduleNotification(for userId: String) {
        // Remove existing notifications for this userId first
        cancelNotifications(for: userId)
        
        // Get the current date and time
        let now = Date()
        
        // Define the time you want the notification to trigger (e.g., 12:00 PM)
        var dateComponents = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute, .second], from: now)
        dateComponents.hour = 12
        dateComponents.minute = 0
        dateComponents.second = 0

        // If the current time is already past 12 PM, schedule for tomorrow
        if now >= Calendar.current.date(from: dateComponents)! {
            dateComponents.day! += 1
        }

        let content = UNMutableNotificationContent()
        content.title = "Time to Post!"
        content.body = "Hey, it's time to talk about what you did today."
        content.sound = .default

        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
        let request = UNNotificationRequest(identifier: "timeToPostNotification_\(userId)", content: content, trigger: trigger)

        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error scheduling notification: \(error.localizedDescription)")
            } else {
                print("Notification scheduled successfully for user \(userId) at 12:00 PM.")
            }
        }
    }

    func cancelNotifications(for userId: String) {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ["timeToPostNotification_\(userId)"])
        UNUserNotificationCenter.current().removeDeliveredNotifications(withIdentifiers: ["timeToPostNotification_\(userId)"])
        print("Notifications canceled for user \(userId).")
    }

    func checkAndScheduleNotifications(for userId: String) {
        let userRef = db.collection("users").document(userId)
        let today = Calendar.current.startOfDay(for: Date())

        userRef.getDocument { document, error in
            if let document = document, document.exists {
                if let lastPostDate = document.data()?["lastPostDate"] as? Timestamp {
                    let lastPostDate = lastPostDate.dateValue()
                    // Check if the last post date is the same as today
                    if Calendar.current.isDate(lastPostDate, inSameDayAs: today) {
                        // User has posted today, cancel notifications
                        self.cancelNotifications(for: userId)
                    } else {
                        // User has not posted today, schedule notifications
                        self.scheduleNotification(for: userId)
                    }
                } else {
                    // User has not posted yet, schedule notifications
                    self.scheduleNotification(for: userId)
                }
            } else {
                // Document does not exist or error fetching document
                print("Error fetching user document: \(error?.localizedDescription ?? "Unknown error")")
            }
        }
    }
    
    func clearAllNotifications() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        UNUserNotificationCenter.current().removeAllDeliveredNotifications()
        print("All notifications cleared.")
    }


    func updatePostDate(for userId: String) {
        let userRef = db.collection("users").document(userId)
        userRef.updateData([
            "lastPostDate": Timestamp(date: Date())
        ]) { error in
            if let error = error {
                print("Error updating post date: \(error.localizedDescription)")
            } else {
                print("Post date updated successfully for user \(userId).")
            }
        }
    }
}
