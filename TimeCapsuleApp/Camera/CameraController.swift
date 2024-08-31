import SwiftUI
import Firebase
import FirebaseAuth
import FirebaseFirestore
import FirebaseStorage

struct CameraView: UIViewControllerRepresentable {
    @Binding var navigateToHome: Bool
    var cameraDelegate: CameraDelegate?

    func makeUIViewController(context: Context) -> Camera {
        let camera = Camera()
        camera.delegate = cameraDelegate
        return camera
    }

    func updateUIViewController(_ uiViewController: Camera, context: Context) {
        // Update the view controller if needed
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, CameraDelegate {
        var parent: CameraView

        init(_ parent: CameraView) {
            self.parent = parent
        }

        func didTakePhoto() {
            // Notify CameraController when a photo is taken
            parent.navigateToHome = true
        }
    }
}

struct CameraController: View {
    @State private var navigateToHome = false
    @State private var isShowingMessage = false
    @State private var navigateToProfile = false // State to track navigation to Profile

    var body: some View {
        NavigationView {
            ZStack {
                // CameraView is at the bottom
                CameraView(navigateToHome: $navigateToHome, cameraDelegate: Coordinator(self))
                    .edgesIgnoringSafeArea(.all)
                
                // Transparent overlay that captures gestures
                Color.clear
                    .contentShape(Rectangle()) // Ensures the gesture is recognized on the entire view
                    .gesture(
                        DragGesture()
                            .onEnded { value in
                                if value.translation.width < -100 {
                                    withAnimation {
                                        navigateToProfile = true
                                    }
                                } else if value.translation.width > 100 {
                                    withAnimation {
                                        navigateToHome = true
                                    }
                                }
                            }
                    )
                
                // Navigation to Profile view
                if navigateToProfile {
                    Profile()
                        .background(Color.white)
                        .transition(.move(edge: .trailing)) // Slide in from the left
                        .navigationBarBackButtonHidden(true)
                }
                
                // Navigation to Home view with smooth transition
                if navigateToHome {
                    Home()
                        .background(Color.white)
                        .transition(.move(edge: .leading)) // Slide in from the left
                        .navigationBarBackButtonHidden(true)
                }

                // MessageButton is on top of HomeButton
                if isShowingMessage {
                    MessageButton(isShowing: $isShowingMessage)
                        .transition(.move(edge: .bottom))
                }
            }
            .navigationBarHidden(true)
        }
    }
    
    private func checkIfPostedToday(completion: @escaping (Bool) -> Void) {
        guard let user = Auth.auth().currentUser else { return }
        let db = Firestore.firestore()
        let photosCollectionRef = db.collection("users").document(user.uid).collection("photos")
        
        let today = Calendar.current.startOfDay(for: Date())
        let query = photosCollectionRef.whereField("timestamp", isGreaterThanOrEqualTo: today)
            .whereField("timestamp", isLessThan: Calendar.current.date(byAdding: .day, value: 1, to: today)!)
        
        query.getDocuments { snapshot, error in
            if let snapshot = snapshot {
                completion(!snapshot.isEmpty)
            } else {
                print("Error checking if posted today: \(error?.localizedDescription ?? "Unknown error")")
                completion(false)
            }
        }
    }
    
    class Coordinator: NSObject, CameraDelegate {
        var parent: CameraController

        init(_ parent: CameraController) {
            self.parent = parent
        }

        func didTakePhoto() {
            // Check if the user has posted today
            parent.checkIfPostedToday { hasPostedToday in
                if hasPostedToday {
                    // Show the message button if the user has posted today
                    DispatchQueue.main.async {
                        self.parent.isShowingMessage = true
                    }
                } else {
                    // Handle the case where the user has not posted today
                    DispatchQueue.main.async {
                        self.parent.navigateToHome = true
                    }
                }
            }
        }
    }
}

struct CameraController_Previews: PreviewProvider {
    static var previews: some View {
        CameraController()
    }
}
