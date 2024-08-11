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
            // Handle the photo taken event
            parent.navigateToHome = true
        }
    }
}

struct CameraController: View {
    @State private var navigateToHome = false
    @State private var isShowingMessage = false

    var body: some View {
        ZStack {
            // CameraView is at the bottom
            CameraView(navigateToHome: $navigateToHome, cameraDelegate: Coordinator(self))
                .edgesIgnoringSafeArea(.all)
            
            // HomeButton is below MessageButton
            if !navigateToHome {
                VStack {
                    Spacer()
                    HomeButton()
                        .padding(.bottom, 30) // Adjust as needed
                }
            }

            // MessageButton is on top of HomeButton
            if isShowingMessage {
                MessageButton(isShowing: $isShowingMessage)
                    .transition(.move(edge: .bottom))
            }
        }
        .navigationBarHidden(true) // Hide the navigation bar if somehow it's still shown
        .onAppear {
            checkIfPostedToday()
        }
    }
    
    private func checkIfPostedToday() {
        guard let user = Auth.auth().currentUser else { return }
        let db = Firestore.firestore()
        let photosCollectionRef = db.collection("users").document(user.uid).collection("photos")
        
        let today = Calendar.current.startOfDay(for: Date())
        let query = photosCollectionRef.whereField("timestamp", isGreaterThanOrEqualTo: today)
            .whereField("timestamp", isLessThan: Calendar.current.date(byAdding: .day, value: 1, to: today)!)
        
        query.getDocuments { snapshot, error in
            if let snapshot = snapshot {
                self.isShowingMessage = !snapshot.isEmpty
            } else {
                print("Error checking if posted today: \(error?.localizedDescription ?? "Unknown error")")
                self.isShowingMessage = false
            }
        }
    }
    
    class Coordinator: NSObject, CameraDelegate {
        var parent: CameraController

        init(_ parent: CameraController) {
            self.parent = parent
        }

        func didTakePhoto() {
            // Handle the photo taken event
            DispatchQueue.main.async {
                if self.parent.isShowingMessage {
                    self.parent.navigateToHome = false // Stay on current view
                } else {
                    self.parent.navigateToHome = true
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
