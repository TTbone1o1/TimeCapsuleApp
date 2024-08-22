import SwiftUI
import Firebase
import FirebaseStorage
import FirebaseAuth
import FirebaseFirestore
import AuthenticationServices
import UserNotifications

struct PostView: View {
    @ObservedObject private var keyboardObserver = KeyboardObserver()
    @State private var caption: String = ""
    @State private var username: String = ""
    @State private var navigateToHome = false
    @State private var isUploading = false
    @State private var moveToTop = false
    @State private var timestamp: String = "" // New state for timestamp
    @State private var showBlurView: Bool = false // New state for showing blur view
    @State private var showCameraController = false // New state to present the CameraController
    @State private var isEditing = false // New state to track if the TextEditor is being edited
    var selectedImage: UIImage?

    var body: some View {
        ZStack(alignment: .bottom) {
            GeometryReader { geometry in
                ScrollView {
                    VStack {
                        // Spacer to adjust content position based on moveToTop state
                        Spacer()
                            .frame(height: moveToTop ? 55 : 315)
                        
                        // Main content area
                        ZStack {
                            if showBlurView {
                                // Show the blur view at the top of the screen
                                TransparentBlurView(removeAllFilters: true)
                                    .blur(radius: 5)
                                    .frame(height: 200) // Adjust height as needed
                                    .edgesIgnoringSafeArea(.top)
                                    .offset(y: -110)
                            }
                            
                            // Display formatted timestamp
                            if !timestamp.isEmpty {
                                Text(timestamp)
                                    .font(.system(size: 18))
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 28)
                                    .frame(width: 348, height: 30, alignment: .center)
                                    .background(showBlurView ? Color.clear : Color.black.opacity(0.3))
                                    .offset(y: -100)
                                    .zIndex(2) // Ensure timestamp is on top of the blur view
                            }
                            
                            ZStack(alignment: .leading) {
                                if caption.isEmpty && !isEditing {
                                    Text("Say something about this day...")
                                        .font(.system(size: 24, weight: .bold))
                                        .foregroundColor(.white)
                                        .frame(width: 300)
                                        .multilineTextAlignment(.center)
                                        .padding(.horizontal, 24)
                                }

                                TextEditor(text: $caption)
                                    .font(.system(size: 24, weight: .bold))
                                    .foregroundColor(.white) // Keep text color white
                                    .frame(width: 300, height: 50) // Adjust the height as needed
                                    .multilineTextAlignment(.center)
                                    .padding(.horizontal, 24)
                                    //.background(Color.clear) // Ensure background is clear
                                    .cornerRadius(10)
                                    .scrollContentBackground(.hidden)
                                    .offset(y: moveToTop ? -45 : 0) // Move caption on top of blur when moving up
                                    .zIndex(3)
                                    .onTapGesture {
                                        isEditing = true
                                    }
                                    .onDisappear {
                                        isEditing = false
                                    }


                            }
                            .padding()
                            Spacer()
                        }
                        .frame(width: geometry.size.width)
                    }
                }
            }
            .contentShape(Rectangle())
            .onTapGesture {
                // Move text up when tapping outside the TextEditor
                if isEditing {
                    withAnimation {
                        moveToTop = true
                        // Update timestamp with formatted date
                        timestamp = formatDate(date: Date())
                        // Show blur view when text editor is dismissed and text is not empty
                        showBlurView = true
                    }
                    isEditing = false // Stop editing when tapping outside
                    UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                }
            }

            if !keyboardObserver.isKeyboardVisible && !isUploading {
                NavigationLink(destination: Home().navigationBarBackButtonHidden(true),
                               isActive: $navigateToHome,
                               label: {
                    ZStack {
                        Rectangle()
                            .frame(width: 291, height: 62)
                            .cornerRadius(40)
                            .foregroundColor(.black)
                            .shadow(radius: 24, x: 0, y: 14)
                        
                        HStack {
                            Text("Post")
                                .foregroundColor(.white)
                                .font(.system(size: 16, weight: .semibold))
                        }
                    }
                })
                .simultaneousGesture(TapGesture().onEnded {
                    if let image = selectedImage {
                        isUploading = true
                        uploadPhoto(image: image)
                    }
                })
                .padding(.bottom, 20)
            }
            
            // Add a black circle in the top left corner with a tap gesture to retake photo
            VStack {
                HStack {
                    Circle()
                        .fill(Color.black)
                        .frame(width: 50, height: 50)
                        .padding([.top, .leading], 20) // Adjust padding as needed
                        .onTapGesture {
                            // Reset navigation state and show camera controller
                            navigateToHome = false
                            showCameraController = true // Toggle the CameraController view
                            moveToTop = false // Reset the moveToTop state
                            timestamp = "" // Clear the timestamp
                        }
                    Spacer()
                }
                Spacer()
            }
        }
        //This colored the background
        .background(Color.clear)
        .fullScreenCover(isPresented: $showCameraController, onDismiss: {
            // Reset the state to avoid navigation conflicts
            showCameraController = false // Ensure this is reset
        }) {
            CameraController() // Present CameraController
                .edgesIgnoringSafeArea(.all)
        }
    }

    // Helper function to format the date
    private func formatDate(date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d" // Format for "Aug 13"
        return formatter.string(from: date)
    }

    private func uploadPhoto(image: UIImage) {
        guard let uid = Auth.auth().currentUser?.uid else { return }

        // Check if the user has already posted today
        let db = Firestore.firestore()
        let photosCollectionRef = db.collection("users").document(uid).collection("photos")

        let startOfToday = Calendar.current.startOfDay(for: Date())
        photosCollectionRef
            .whereField("timestamp", isGreaterThanOrEqualTo: Timestamp(date: startOfToday))
            .getDocuments { snapshot, error in
                if let error = error {
                    print("Error checking today's post: \(error.localizedDescription)")
                    isUploading = false
                    return
                }

                if let snapshot = snapshot, !snapshot.isEmpty {
                    print("User has already posted today")
                    isUploading = false
                    return
                } else {
                    performUpload(image: image)
                }
            }
    }
    
    private func performUpload(image: UIImage) {
        guard let uid = Auth.auth().currentUser?.uid else { return }

        let photoID = UUID().uuidString
        let storageRef = Storage.storage().reference().child("users/\(uid)/photos/\(photoID).jpg")

        guard let imageData = image.jpegData(compressionQuality: 0.75) else {
            isUploading = false
            return
        }

        storageRef.putData(imageData, metadata: nil) { metadata, error in
            if let error = error {
                print("Error uploading photo: \(error.localizedDescription)")
                isUploading = false
                return
            }

            storageRef.downloadURL { url, error in
                if let error = error {
                    print("Error getting download URL: \(error.localizedDescription)")
                    isUploading = false
                    return
                }

                if let downloadURL = url {
                    savePhotoMetadata(photoURL: downloadURL.absoluteString, caption: caption)
                }
            }
        }
    }

    private func savePhotoMetadata(photoURL: String, caption: String) {
        guard let uid = Auth.auth().currentUser?.uid else { return }

        let db = Firestore.firestore()
        let photoData: [String: Any] = [
            "photoURL": photoURL,
            "caption": caption,
            "timestamp": Timestamp(date: Date())
        ]

        db.collection("users").document(uid).collection("photos").addDocument(data: photoData) { error in
            if let error = error {
                print("Error saving photo metadata: \(error.localizedDescription)")
                isUploading = false
            } else {
                print("Photo metadata successfully saved")
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { // Add a delay
                    navigateToHome = true
                }
            }
            isUploading = false
        }
    }
    
    func checkIfUserPostedToday(uid: String, completion: @escaping (Bool) -> Void) {
        let db = Firestore.firestore()
        let photosCollectionRef = db.collection("users").document(uid).collection("photos")

        let startOfToday = Calendar.current.startOfDay(for: Date())
        photosCollectionRef
            .whereField("timestamp", isGreaterThanOrEqualTo: Timestamp(date: startOfToday))
            .getDocuments { snapshot, error in
                if let error = error {
                    print("Error checking today's post: \(error.localizedDescription)")
                    completion(false)
                    return
                }

                if let snapshot = snapshot, !snapshot.isEmpty {
                    completion(true) // User has posted today
                } else {
                    completion(false) // No posts today
                }
            }
    }
}

#Preview {
    PostView(selectedImage: UIImage(systemName: "photo")!)
}
