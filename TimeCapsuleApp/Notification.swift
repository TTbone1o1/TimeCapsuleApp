import UserNotifications

class Notification {
    static let shared = Notification()

    func scheduleNotification() {
        let content = UNMutableNotificationContent()
        content.title = "Time to Post!"
        content.body = "Hey, it's time to talk about what you did today."
        content.sound = .default

        // Change the interval to 7200 seconds for 2 hours
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 7200, // 60 seconds for testing, change to 7200 for production
                                                        repeats: true)
        
        let request = UNNotificationRequest(identifier: "timeToPostNotification", // Use a fixed identifier if you want to manage notifications
                                            content: content,
                                            trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error scheduling notification: \(error.localizedDescription)")
            } else {
                print("Notification scheduled successfully.")
            }
        }
    }

    func cancelNotifications() {
        // Cancels notifications with the specific identifier
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ["timeToPostNotification"])
    }
}
