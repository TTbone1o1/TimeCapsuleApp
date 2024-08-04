//import SwiftUI
//
//struct MainView: View {
//    @State private var showModal = true
//    @State private var userInput = ""
//
//    var body: some View {
//        ZStack {
//            // Your camera view or any other content
//            CameraViewControllerRepresentable()
//                .opacity(showModal ? 0 : 1) // Hide camera view when modal is shown
//
//            if showModal {
//                Modal(showModal: $showModal, username: "User", userInput: $userInput) {
//                    // Handle submission logic here
//                    print("Submitted: \(userInput)")
//                }
//                .transition(.move(edge: .bottom)) // Optional: Add transition for modal dismissal
//                .animation(.easeInOut, value: showModal) // Optional: Animate modal appearance/disappearance
//            }
//        }
//    }
//}
//
//#Preview {
//    MainView()
//}
