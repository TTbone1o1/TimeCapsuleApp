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
    @State private var isEditing = false // New state to track if the TextEditor is being edited
    @State private var showCameraController = false
    
    @Environment(\.colorScheme) var currentColorScheme
    
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
//                                Color.clear
//                                .frame(height: 200) // Adjust height as needed
//                                .edgesIgnoringSafeArea(.top)
//                                .overlay(
//                                    LinearGradient(
//                                        gradient: Gradient(stops: [
//                                            .init(color: currentColorScheme == .dark ? Color.black.opacity(0.8) : Color.black.opacity(1.0), location: 0.0),
//                                            .init(color: Color.black.opacity(0.0), location: 0.2),
//                                            .init(color: Color.clear, location: 1.0)
//                                        ]),
//                                        startPoint: .bottom,
//                                        endPoint: .top
//                                    )
//                                )
//                                //.offset(y: -110)
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
                                // Custom MultilineTextField for user input
                                MultilineTextField(text: $caption, isEditing: $isEditing, moveToTop: $moveToTop, showBlurView: $showBlurView, timestamp: $timestamp)
                                    .frame(minHeight: 50, maxHeight: .infinity)
                                    .multilineTextAlignment(.center)
                                    .padding(.horizontal, 24)
                                    .background(isEditing ? Color.clear : Color.clear)
                                    .cornerRadius(10)
                                    .offset(y: moveToTop ? -65 : 0)
                                    .zIndex(3)
                                    .onTapGesture {
                                        isEditing = true
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
                dismissKeyboardAndMoveContentUp()
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
                                .font(.system(size: 16, weight: .bold, design: .rounded))
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
                    Button(action: {
                        showCameraController = true
                    }) {
                        Image(systemName: "arrow.triangle.2.circlepath.camera")
                            .font(.system(size: 24))
                            .foregroundColor(.black)
                            .padding(20)
                    }
                    Spacer()
                }
                Spacer()
            }
            .fullScreenCover(isPresented: $showCameraController, onDismiss: {
                // Reset any relevant state here
            }) {
                CameraController(isPresented: $showCameraController)
                    .edgesIgnoringSafeArea(.all)
            }
        }
        .background(Color.clear)
    }

    // Helper function to format the date
    private func formatDate(date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d"
        return formatter.string(from: date)
    }

    // Helper function to dismiss keyboard and move the content up
    private func dismissKeyboardAndMoveContentUp() {
        if isEditing && !caption.isEmpty { // Check if caption is not empty
            withAnimation {
                moveToTop = true
                timestamp = formatDate(date: Date())
                showBlurView = true
            }
            isEditing = false
            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
        }
    }

    private func uploadPhoto(image: UIImage) {
        guard let uid = Auth.auth().currentUser?.uid else { return }

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
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    navigateToHome = true
                }
            }
            isUploading = false
        }
    }
}

// Custom MultilineTextField with keyboard dismissal and move content up
struct MultilineTextField: View {
    @Binding var text: String
    @Binding var isEditing: Bool
    @Binding var moveToTop: Bool
    @Binding var showBlurView: Bool
    @Binding var timestamp: String
    
    var body: some View {
        VStack {
            ZStack(alignment: .leading) {
                // Custom placeholder with two lines
                if text.isEmpty && !isEditing {
                    VStack {
                        Text("Say something about")
                            .font(.system(size: 24, weight: .bold, design: .rounded))
                            .foregroundColor(.white) // Placeholder styling
                            .multilineTextAlignment(.center)

                        Text("this day...")
                            .font(.system(size: 24, weight: .bold, design: .rounded))
                            .foregroundColor(.white) // Placeholder styling
                            .multilineTextAlignment(.center)
                    }
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.horizontal, 24)
                    .onTapGesture {
                        // Ensure tapping on the placeholder focuses the TextField
                        isEditing = true
                    }
                }

                // The actual TextField with no prompt
                TextField("", text: $text, onEditingChanged: { editing in
                    isEditing = editing
                })
                .submitLabel(.done)
                .onSubmit {
                    if !text.isEmpty { // Check if the text is not empty
                        withAnimation {
                            moveToTop = true
                            timestamp = formatDate(date: Date())
                            showBlurView = true
                        }
                        isEditing = false
                        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                    }
                }
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(.white)
                .frame(minHeight: 50, maxHeight: .infinity, alignment: .center)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 24)
                .background(isEditing ? Color.clear : Color.clear)
                .cornerRadius(10)

            }
            .frame(minHeight: 50, maxHeight: .infinity, alignment: .center)
        }

    }

    // Helper function to format the date
    private func formatDate(date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d"
        return formatter.string(from: date)
    }
}



#Preview {
    PostView(selectedImage: UIImage(systemName: "photo")!)
}
