import SwiftUI
import AVKit
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
    @State private var isUploading = false
    @State private var moveToTop = false
    @State private var timestamp: String = ""
    @State private var showBlurView: Bool = false
    @State private var isEditing = false
    @State private var showCameraController = false
    @State private var navigateToHome = false // Use @State to manage navigation
    
    @Environment(\.colorScheme) var currentColorScheme
    
    var selectedImage: UIImage?
    var videoURL: URL? // Video URL passed in
    
    var body: some View {
        ZStack(alignment: .bottom) {
            if navigateToHome { // Conditional navigation
                Home() // Show Home view
            } else {
                GeometryReader { geometry in
                    ScrollView {
                        VStack {
                            Spacer()
                                .frame(height: moveToTop ? 55 : 315)

                            ZStack {
                                if showBlurView {
                                    Color.clear
                                        .frame(height: 200)
                                        .edgesIgnoringSafeArea(.top)
                                        .overlay(
                                            LinearGradient(
                                                gradient: Gradient(stops: [
                                                    .init(color: currentColorScheme == .dark ? Color.black.opacity(0.9) : Color.black.opacity(1.0), location: 0.0),
                                                    .init(color: Color.black.opacity(0.0), location: 0.9),
                                                    .init(color: Color.clear, location: 1.0)
                                                ]),
                                                startPoint: .top,
                                                endPoint: .bottom
                                            )
                                        )
                                        .offset(y: -110)
                                }

                                if !timestamp.isEmpty {
                                    Text(timestamp)
                                        .font(.system(size: 18))
                                        .foregroundColor(.white)
                                        .padding(.horizontal, 28)
                                        .frame(width: 348, height: 30, alignment: .center)
                                        .background(showBlurView ? Color.clear : Color.black.opacity(0.3))
                                        .offset(y: -100)
                                        .zIndex(2)
                                }

                                ZStack(alignment: .leading) {
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

                                // Show the video player if there is a video URL
                                if let videoURL = videoURL {
                                    VideoPlayerView(videoURL: videoURL)
                                        .frame(width: geometry.size.width, height: geometry.size.height) // Full screen frame
                                        .scaleEffect(1.11)
                                        .offset(y: -(geometry.size.height * 0.40))  // Dynamically adjust offset based on screen
                                        .edgesIgnoringSafeArea(.all)  // Ignore safe areas for full-screen effect
                                }
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
                    Button(action: {
                        if let image = selectedImage {
                            isUploading = true
                            uploadPhoto(image: image)
                        }
                    }) {
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
                    }
                    .padding(.bottom, 20)
                }

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
        if isEditing && !caption.isEmpty {
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
                    isUploading = false
                    navigateToHome = true // Navigate to Home after post
                }
            }
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
                if text.isEmpty && !isEditing {
                    VStack {
                        Text("Say something about")
                            .font(.system(size: 24, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                            .multilineTextAlignment(.center)

                        Text("this day...")
                            .font(.system(size: 24, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                            .multilineTextAlignment(.center)
                    }
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.horizontal, 24)
                    .onTapGesture {
                        isEditing = true
                    }
                }

                TextField("", text: $text, onEditingChanged: { editing in
                    isEditing = editing
                })
                .submitLabel(.done)
                .onSubmit {
                    if !text.isEmpty {
                        withAnimation {
                            moveToTop = true
                            timestamp = formatDate(date: Date())
                            showBlurView = true
                        }
                        isEditing = false
                        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                    }
                }
                .font(.system(size: 24, weight: .bold, design: .rounded))
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

    private func formatDate(date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d"
        return formatter.string(from: date)
    }
}

// Custom Video Player View for playing video in full screen
struct VideoPlayerView: UIViewControllerRepresentable {
    var videoURL: URL

    func makeUIViewController(context: Context) -> AVPlayerViewController {
        let player = AVPlayer(url: videoURL)
        let playerViewController = AVPlayerViewController()
        playerViewController.player = player

        // Set video gravity to resizeAspectFill (fill the screen without stretching)
        playerViewController.videoGravity = .resizeAspectFill
        
        // Ensure video plays repeatedly
        NotificationCenter.default.addObserver(forName: .AVPlayerItemDidPlayToEndTime, object: player.currentItem, queue: .main) { _ in
            player.seek(to: .zero)
            player.play()
        }

        // Play the video automatically
        player.play()
        return playerViewController
    }

    func updateUIViewController(_ uiViewController: AVPlayerViewController, context: Context) {
        // No updates needed for now
    }
}



#Preview {
    PostView(selectedImage: UIImage(systemName: "photo")!)
}
