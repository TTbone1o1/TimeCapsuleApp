import SwiftUI
import Firebase
import FirebaseAuth
import FirebaseFirestore
import FirebaseStorage

struct CameraView: UIViewControllerRepresentable {
    @Binding var isShowingMessage: Bool

    func makeUIViewController(context: Context) -> Camera {
        let camera = Camera()
        camera.delegate = context.coordinator
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
            print("Photo taken, checking if posted today...")
            
            // First handle the photo-taking process, then check the condition
            parent.savePhoto { success in
                if success {
                    // Now check if the user has posted today
                    self.parent.checkIfPostedToday { hasPostedToday in
                        DispatchQueue.main.async {
                            if hasPostedToday {
                                print("User has posted today. Showing message button.")
                                self.parent.isShowingMessage = true
                            } else {
                                print("User has not posted today. Photo taken successfully.")
                                // No need to navigate or do anything else; the user stays on the camera screen
                            }
                        }
                    }
                } else {
                    print("Photo save failed.")
                }
            }
        }
    }
    
    private func checkIfPostedToday(completion: @escaping (Bool) -> Void) {
        guard let user = Auth.auth().currentUser else {
            print("No user is currently authenticated.")
            completion(false)
            return
        }
        let db = Firestore.firestore()
        let photosCollectionRef = db.collection("users").document(user.uid).collection("photos")
        
        let today = Calendar.current.startOfDay(for: Date())
        let query = photosCollectionRef.whereField("timestamp", isGreaterThanOrEqualTo: today)
            .whereField("timestamp", isLessThan: Calendar.current.date(byAdding: .day, value: 1, to: today)!)
        
        query.getDocuments { snapshot, error in
            if let snapshot = snapshot {
                let hasPosted = !snapshot.isEmpty
                print("Has the user posted today? \(hasPosted)")
                completion(hasPosted)
            } else {
                print("Error checking if posted today: \(error?.localizedDescription ?? "Unknown error")")
                completion(false)
            }
        }
    }

    private func savePhoto(completion: @escaping (Bool) -> Void) {
        // Implement the photo saving logic here.
        // Call completion(true) when the photo is successfully saved.
        // Call completion(false) if saving the photo fails.
        
        // For demonstration, we'll assume the save is successful.
        DispatchQueue.global().asyncAfter(deadline: .now() + 1) {
            completion(true)
        }
    }
}

struct CameraController: View {
    @State private var isShowingMessage = false
    @State private var navigateToProfile = false

    var body: some View {
        NavigationView {
            ZStack {
                CameraView(isShowingMessage: $isShowingMessage)
                    .edgesIgnoringSafeArea(.all)
                
                // Transparent overlay that captures gestures
                Color.clear
                    .contentShape(Rectangle())
                    .gesture(
                        DragGesture()
                            .onEnded { value in
                                if value.translation.width < -100 {
                                    withAnimation {
                                        navigateToProfile = true
                                    }
                                }
                            }
                    )
                
                // Navigation to Profile view
                if navigateToProfile {
                    Profile()
                        .background(Color.white)
                        .transition(.move(edge: .trailing))
                        .navigationBarBackButtonHidden(true)
                }

                // MessageButton is on top of other UI elements
                if isShowingMessage {
                    MessageButton(isShowing: $isShowingMessage)
                        .transition(.move(edge: .bottom))
                }
            }
            .navigationBarHidden(true)
        }
    }
}

struct CameraController_Previews: PreviewProvider {
    static var previews: some View {
        CameraController()
    }
}
