import UserNotifications
import Firebase
import FirebaseFirestore

class Notification {
    static let shared = Notification()
    private let db = Firestore.firestore()

    private init() {}

    func scheduleNotification(for userId: String) {
        let content = UNMutableNotificationContent()
        content.title = "Time to Post!"
        content.body = "Hey, it's time to talk about what you did today."
        content.sound = .default

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 60, repeats: true)
        let request = UNNotificationRequest(identifier: "timeToPostNotification_\(userId)", content: content, trigger: trigger)

        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error scheduling notification: \(error.localizedDescription)")
            } else {
                print("Notification scheduled successfully for user \(userId).")
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
