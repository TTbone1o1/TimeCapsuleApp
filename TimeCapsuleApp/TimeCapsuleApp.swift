import FirebaseCore
import SwiftUI
import UserNotifications

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication
            .LaunchOptionsKey: Any]? = nil
    ) -> Bool {
        // Initialize Firebase
        FirebaseApp.configure()

        // Manually trigger the noon check for testing purposes
        NotificationManager.shared.handleNoonCheck()

        return true
    }
}

@main
struct TimeCapsuleAppApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    var body: some Scene {
        WindowGroup {
            NavigationView {
                SplashScreen()
                    .navigationBarHidden(true)
                    .navigationBarBackButtonHidden(true)
            }
            .navigationViewStyle(StackNavigationViewStyle())
        }

    }
}
