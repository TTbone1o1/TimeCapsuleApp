import SwiftUI
import Firebase
import FirebaseStorage
import FirebaseAuth
import FirebaseFirestore
import AuthenticationServices

struct PostView: View {
    @ObservedObject private var keyboardObserver = KeyboardObserver()
    @State private var caption: String = ""
    @State private var username: String = ""
    @State private var navigateToHome = false
    @State private var isUploading = false // To handle uploading state
    var selectedImage: UIImage?

    var body: some View {
        ZStack(alignment: .bottom) {
            // Scrollable Content
            ScrollView {
                VStack {
                    Spacer()
                        .frame(height: 310)
                    
                    ZStack(alignment: .leading) {
                        if caption.isEmpty {
                            Text("Say something about this day...")
                                .font(.system(size: 24, weight: .bold))
                                .foregroundColor(.white)
                                .frame(width: 300)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 24)
                        }
                        TextField("", text: $caption)
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(.white)
                            .frame(width: 300)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 24)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    .padding()
                    
                    Spacer()
                }
                .frame(maxWidth: .infinity) // Center content horizontally
            }
            
            // Navigation Button
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
                    }
                )
                .simultaneousGesture(TapGesture().onEnded {
                    if let image = selectedImage {
                        isUploading = true
                        uploadPhoto(image: image)
                    }
                })
                .padding(.bottom, 20) // Ensure some space from the bottom
            }
        }
        .background(Color.clear) // Ensure background is clear
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
                    return
                }

                if let snapshot = snapshot, !snapshot.isEmpty {
                    print("User has already posted today")
                    // Optionally, you can show an alert here to notify the user
                    return
                } else {
                    // If no posts were found for today, proceed with the upload
                    performUpload(image: image)
                }
            }
    }
    
    private func performUpload(image: UIImage) {
        guard let uid = Auth.auth().currentUser?.uid else { return }

        // Create a unique identifier for the photo
        let photoID = UUID().uuidString
        let storageRef = Storage.storage().reference().child("users/\(uid)/photos/\(photoID).jpg")

        // Convert UIImage to Data
        guard let imageData = image.jpegData(compressionQuality: 0.75) else { return }

        // Upload the photo
        storageRef.putData(imageData, metadata: nil) { metadata, error in
            if let error = error {
                print("Error uploading photo: \(error.localizedDescription)")
                return
            }

            // Get the download URL
            storageRef.downloadURL { url, error in
                if let error = error {
                    print("Error getting download URL: \(error.localizedDescription)")
                    return
                }

                if let downloadURL = url {
                    // Save the metadata to Firestore
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
            } else {
                print("Photo metadata successfully saved")
                navigateToHome = true
            }

            isUploading = false
        }
    }
}

#Preview {
    PostView(selectedImage: UIImage(systemName: "photo")!) // For preview purposes
}
