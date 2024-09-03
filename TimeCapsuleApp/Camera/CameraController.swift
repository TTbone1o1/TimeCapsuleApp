import SwiftUI
import Firebase
import FirebaseAuth
import FirebaseFirestore
import FirebaseStorage

struct CameraView: UIViewControllerRepresentable {
    @Binding var isShowingMessage: Bool
    @Binding var isPresented: Bool
    @Binding var isPhotoTaken: Bool

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
            
            // Show the message button immediately when the photo is taken
            DispatchQueue.main.async {
                self.parent.isShowingMessage = true
            }
            
            // Set the state to indicate that a photo has been taken
            DispatchQueue.main.async {
                self.parent.isPhotoTaken = true
            }
            
            // Handle the photo-taking process
            parent.savePhoto { success in
                if success {
                    // Check if the user has posted today
                    self.parent.checkIfPostedToday { hasPostedToday in
                        DispatchQueue.main.async {
                            if hasPostedToday {
                                print("User has posted today. Showing message button.")
                                self.parent.isShowingMessage = true
                            } else {
                                print("User has not posted today. Photo taken successfully.")
                                // Optionally remove this line to prevent automatic dismissal
                                // self.parent.isPresented = false
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
    @Binding var isPresented: Bool
    @State private var isShowingMessage = false
    @State private var isPhotoTaken = false

    var body: some View {
        NavigationView {
            ZStack {
                CameraView(isShowingMessage: $isShowingMessage, isPresented: $isPresented, isPhotoTaken: $isPhotoTaken)

                if isShowingMessage {
                    MessageButton(isShowing: $isShowingMessage)
                        .transition(.opacity.combined(with: .scale(scale: 0.95)))
                        .animation(.linear(duration: 0.1)) // Reduced duration for quicker appearance
                }

                if !isPhotoTaken {
                    Button(action: {
                        withAnimation {
                            isPresented = false
                        }
                    }) {
                        Image(systemName: "arrowshape.backward.fill")
                            .resizable()
                            .frame(width: 20, height: 20)
                            .foregroundColor(.white)
                            .padding()
                    }
                    .position(x: 40, y: 80)
                }
            }
            .navigationBarHidden(true)
            .edgesIgnoringSafeArea(.all)
        }
    }
}

struct CameraController_Previews: PreviewProvider {
    static var previews: some View {
        CameraController(isPresented: .constant(true))
    }
}
