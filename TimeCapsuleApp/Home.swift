import SwiftUI
import Firebase
import FirebaseAuth
import FirebaseFirestore
import FirebaseStorage
import AVKit
import Pow
import Photos

// Image extension to apply a tint color
extension Image {
    func withTintColor(_ color: Color) -> some View {
        self
            .renderingMode(.template)
            .resizable()
            .aspectRatio(contentMode: .fit)
            .foregroundColor(color)
    }
}

struct Home: View {
    @State private var username: String = ""
    @State private var imagesAppeared = false
    @State private var hasPostedPhoto = false
    @State private var mediaUrls: [(String, String, Timestamp, String)] = [] // Store (URL, Caption, Timestamp, Type) tuples ("photo" or "video")
    @State private var photoCount: Int = 0
    @State private var isShowingMessage = false
    @State private var isCaptionVisible: Bool = false
    @State private var isImageLoaded: Bool = false
    @State private var highlightedMediaUrl: String? = nil
    @State private var tappedMediaUrl: String? = nil
    @State private var scaleAmount: CGFloat = 1.0
    @State private var isSignedOut: Bool = false
    @State var show = false
    @State private var isScrollDisabled: Bool = false
    @State private var dragOffset: CGFloat = 0
    @State private var showProfileView: Bool = false
    @State private var homeIconColor: Color = .black
    @State private var profileIconColor = Color(.systemGray3)
    @State private var showCameraController = false
    @State private var isMediaExpanded = false
    @State private var areButtonsVisible = true
    @State private var isSettingsOpen = false  // State for settings
    @State private var isShowingSetting = false
    @State private var isFullCaptionVisible: Bool = false // State for showing full caption
    @State private var preloadedProfileImage: UIImage? = nil // State to store the preloaded profile image
    @State private var canTap: Bool = true // Add this to control tapping
    @State private var homeProfileScale: CGFloat = 1.0
    @State private var isLoadingMedia = true
    @State private var savedImages: Set<String> = loadSavedImages() // Track saved image URLs
    @State private var captionDragOffset: CGSize = .zero
    @State private var finalCaptionOffset: CGSize = .zero // To store the final drag offset

    @Environment(\.colorScheme) var currentColorScheme
    @Namespace var namespace
    
    // Custom Video Player View to hide the play button and the skip controls
    struct CustomVideoPlayerView: UIViewControllerRepresentable {
        var videoURL: URL
        
        func makeUIViewController(context: Context) -> AVPlayerViewController {
            let player = AVPlayer(url: videoURL)
            let controller = AVPlayerViewController()
            
            // Hide all playback controls
            controller.showsPlaybackControls = false
            
            // Set video gravity to fill the screen
            controller.videoGravity = .resizeAspectFill
            
            controller.view.backgroundColor = .clear
            
            // Ensure the video plays automatically
            player.play()
            
            // Listen for when the video ends to loop it
            NotificationCenter.default.addObserver(
                forName: .AVPlayerItemDidPlayToEndTime,
                object: player.currentItem,
                queue: .main
            ) { _ in
                player.seek(to: .zero) // Restart video
                player.play() // Play again
            }
            
            controller.player = player // Set the player
            return controller
        }
        
        func updateUIViewController(_ uiViewController: AVPlayerViewController, context: Context) {
            // Handle updates here if needed
        }
    }

    var body: some View {
        if isSignedOut {
            Timecap()
        } else {
            NavigationView {
                GeometryReader { geometry in
                    ZStack {
                        Profile(isImageExpanded: $isMediaExpanded,
                                isShowingSetting: $isShowingSetting,
                                selectedImage: $preloadedProfileImage,
                                homeProfileScale: $homeProfileScale)
                        .offset(x: UIScreen.main.bounds.width + dragOffset)
                        .zIndex(1)
                        
                        mainContentView(geometry: geometry)
                            .offset(x: min(0, max(-geometry.size.width, dragOffset + geometry.safeAreaInsets.leading)))
                            .gesture(
                                tappedMediaUrl == nil ?
                                DragGesture()
                                    .onChanged { value in
                                        let translationWidth = value.translation.width
                                        dragOffset = min(0, max(-UIScreen.main.bounds.width, translationWidth + (showProfileView ? -UIScreen.main.bounds.width : 0)))
                                    }
                                    .onEnded { value in
                                        withAnimation {
                                            if value.translation.width < -geometry.size.width / 3 {
                                                dragOffset = -UIScreen.main.bounds.width
                                                showProfileView = true
                                            } else if value.translation.width > geometry.size.width / 3 {
                                                dragOffset = 0
                                                showProfileView = false
                                            } else {
                                                dragOffset = showProfileView ? -UIScreen.main.bounds.width : 0
                                            }
                                            updateIconColors()
                                        }
                                    }
                                : nil
                            )
                            .zIndex(2)
                        
                        if !isMediaExpanded && !isSettingsOpen && !isShowingSetting && !isSignedOut {
                            VStack(spacing: 20) {
                                Spacer()
                                ZStack {
                                    Button(action: {
                                        let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
                                        impactFeedback.impactOccurred()
                                        showCameraController = true
                                    }) {
                                        ZStack {
                                            Circle()
                                                .stroke(Color.secondary.opacity(0.9), lineWidth: 3)
                                                .frame(width: 52, height: 52)

                                            Circle()
                                                .fill(Color.secondary.opacity(0.7))
                                                .frame(width: 37, height: 37)
                                        }
                                        .scaleEffect(homeProfileScale)
                                    }
                                    
                                    HStack {
                                        Image("Home")
                                            .withTintColor(showProfileView ? Color.secondary.opacity(0.9) : Color.primary)
                                            .frame(width: 34, height: 34)
                                            .scaleEffect(homeProfileScale)
                                            .padding(.leading, geometry.safeAreaInsets.leading) // Add safe area padding here
                                            .onTapGesture {
                                                withAnimation {
                                                    dragOffset = 0
                                                    showProfileView = false
                                                    updateIconColors()
                                                }
                                            }

                                        Spacer()

                                        Image("Profile")
                                            .withTintColor(showProfileView ? Color.primary : Color.secondary.opacity(0.9))
                                            .frame(width: 34, height: 34)
                                            .scaleEffect(homeProfileScale)
                                            .onTapGesture {
                                                withAnimation {
                                                    dragOffset = -UIScreen.main.bounds.width
                                                    showProfileView = true
                                                    updateIconColors()
                                                }
                                            }
                                    }
                                    .frame(width: 290)
                                }
                            }
                            .padding(.horizontal, 60)
                            .padding(.bottom, 40)
                            .zIndex(3)
                            .onChange(of: tappedMediaUrl) { newValue in
                                if tappedMediaUrl != nil {
                                    withAnimation(.easeInOut(duration: 0.2)) {
                                        homeProfileScale = 0.0
                                    }
                                } else {
                                    withAnimation(.easeInOut(duration: 0.2)) {
                                        homeProfileScale = 1.0
                                    }
                                }
                            }
                            .disabled(tappedMediaUrl != nil) // Add this here to disable buttons
                        }

                        if showCameraController {
                            CameraController(isPresented: $showCameraController)
                                .transition(.opacity)
                                .zIndex(4)
                        }
                    }
                    .edgesIgnoringSafeArea(.all)
                    .padding(.leading, geometry.safeAreaInsets.leading)
                    .onAppear {
                        dragOffset = showProfileView ? -UIScreen.main.bounds.width : 0
                        onAppearLogic()
                        updateIconColors()
                        loadProfileImage()
                    }
                }
            }
            .navigationViewStyle(StackNavigationViewStyle())
        }
    }
    
    private func mainContentView(geometry: GeometryProxy) -> some View {
            ZStack {
                mediaGalleryView()
                    .zIndex(1)

                VStack {
                    Spacer().frame(height: 20)

                    if tappedMediaUrl == nil {
                        HStack {
                            Text(username.isEmpty ? "" : username)
                                .font(.system(size: 18, weight: .bold, design: .rounded))
                                .fontWeight(.bold)
                                .padding(.leading)
                                .foregroundColor(Color.primary)
                            Spacer()
                        }
                        .padding(.top, geometry.safeAreaInsets.top)
                        .transition(.opacity)

                        if !isLoadingMedia && mediaUrls.isEmpty {
                            VStack {
                                Spacer()

                                Text("Take a photo or video to start")
                                    .font(.system(size: 18, weight: .bold, design: .rounded))
                                    .fontWeight(.bold)
                                    .padding(.bottom, 30)

                                Spacer(minLength: 350)
                            }
                        }
                    }

                    Spacer()
                }
                .zIndex(2)
            }
        }
    
    private func mediaGalleryView() -> some View {
        ScrollViewReader { scrollProxy in
            ScrollView {
                VStack(spacing: 45) {
                    ForEach(mediaUrls, id: \.0) { mediaUrl, caption, timestamp, mediaType in
                        ZStack(alignment: .bottom) {
                            if mediaType == "photo" {
                                AsyncImage(
                                    url: URL(string: mediaUrl),
                                    transaction: .init(animation: .easeInOut(duration: 1.8))
                                ) { phase in
                                    ZStack {
                                        switch phase {
                                        case .empty:
                                            Color.clear
                                                .frame(width: 313, height: 421)
                                                .transition(.movingParts.filmExposure)

                                        case .success(let image):
                                            ZStack(alignment: .topTrailing) {
                                                image
                                                    .resizable()
                                                    .aspectRatio(contentMode: .fill)
                                                    .matchedGeometryEffect(id: mediaUrl, in: namespace)
                                                    .frame(width: tappedMediaUrl == mediaUrl ? UIScreen.main.bounds.width : 313,
                                                           height: tappedMediaUrl == mediaUrl ? UIScreen.main.bounds.height : 421)
                                                    .cornerRadius(tappedMediaUrl == mediaUrl ? 0 : 33)
                                                    .shadow(radius: 20, x: 0, y: 24)
                                                    .onTapGesture {
                                                        handleMediaTap(mediaUrl: mediaUrl, mediaType: mediaType, scrollProxy: scrollProxy)
                                                    }
                                            }
                                            .overlay(
                                                LinearGradient(
                                                    gradient: Gradient(stops: [
                                                        .init(color: currentColorScheme == .dark ? Color.black.opacity(0.8) : Color.black.opacity(1.0), location: 0.0),
                                                        .init(color: Color.black.opacity(0.0), location: 0.2),
                                                        .init(color: Color.clear, location: 1.0)
                                                    ]),
                                                    startPoint: .bottom,
                                                    endPoint: .top
                                                )
                                                .frame(width: tappedMediaUrl == mediaUrl ? UIScreen.main.bounds.width : 313,
                                                       height: tappedMediaUrl == mediaUrl ? UIScreen.main.bounds.height : 421)
                                                .clipShape(RoundedRectangle(cornerRadius: tappedMediaUrl == mediaUrl ? 0 : 33, style: .continuous))
                                                .animation(.spring(response: 0.5, dampingFraction: 0.95), value: tappedMediaUrl)
                                                .allowsHitTesting(false)
                                            )

                                            // Call the caption view when the image loads successfully
                                            if currentColorScheme == .dark {
                                                captionView(caption: caption, timestamp: timestamp, tappedMediaUrl: tappedMediaUrl, currentMediaUrl: mediaUrl)
                                                    .transition(.movingParts.filmExposure) // Apply transition only in dark mode
                                                    .offset(y: tappedMediaUrl == mediaUrl ? 400 : 170)
                                            } else {
                                                captionView(caption: caption, timestamp: timestamp, tappedMediaUrl: tappedMediaUrl, currentMediaUrl: mediaUrl)
                                                    .offset(y: tappedMediaUrl == mediaUrl ? 400 : 170) // No transition in light mode
                                            }

                                        case .failure:
                                            Image(systemName: "xmark.circle")
                                                .resizable()
                                                .aspectRatio(contentMode: .fit)
                                                .frame(width: 100, height: 100)
                                        @unknown default:
                                            EmptyView()
                                        }
                                    }
                                    .frame(maxWidth: .infinity)
                                    .id(mediaUrl)
                                }
                            } else if mediaType == "video" {
                                CustomVideoPlayerView(videoURL: URL(string: mediaUrl)!)
                                    .frame(width: tappedMediaUrl == mediaUrl ? UIScreen.main.bounds.width : 313,
                                           height: tappedMediaUrl == mediaUrl ? UIScreen.main.bounds.height : 421)
                                    .cornerRadius(tappedMediaUrl == mediaUrl ? 0 : 33)
                                    .shadow(radius: 20, x: 0, y: 24)
                                    .onTapGesture {
                                        handleMediaTap(mediaUrl: mediaUrl, mediaType: mediaType, scrollProxy: scrollProxy)
                                    }
                                    .transition(.movingParts.filmExposure)  // Add the transition here for videos
                            }
                        }
                        .offset(y: tappedMediaUrl == mediaUrl && mediaUrls.count == 1 ? -130 : 0)
                    }
                }
                .padding(.vertical, 130)
            }
            .scrollDisabled(isScrollDisabled)
            .ignoresSafeArea(edges: [.leading, .trailing])
            .scrollIndicators(.hidden)
        }
    }

    private func captionView(caption: String, timestamp: Timestamp, tappedMediaUrl: String?, currentMediaUrl: String) -> some View {
        VStack(alignment: .center, spacing: 5) {
            Text(formatDate(timestamp.dateValue()))
                .font(.system(size: 18, weight: .bold, design: .rounded))
                .foregroundColor(.white)
                .padding(.horizontal, 28)

            Text(isFullCaptionVisible ? caption : shortenCaption(caption))
                .font(.system(size: 24, weight: .bold, design: .rounded))
                .padding(.horizontal, 28)
                .frame(maxWidth: .infinity, alignment: .center)
                .foregroundColor(.white)
                .cornerRadius(5)
                .padding(.bottom, isFullCaptionVisible ? 50 : 26)
        }
        // Offset for when the media is expanded, only apply drag gesture for the tapped media
        .offset(tappedMediaUrl == currentMediaUrl ? CGSize(width: finalCaptionOffset.width + captionDragOffset.width, height: finalCaptionOffset.height + captionDragOffset.height) : .zero)
        // Gesture for dragging the caption when expanded
        .gesture(
            tappedMediaUrl == currentMediaUrl ? DragGesture()
                .onChanged { value in
                    captionDragOffset = value.translation // Track current drag position
                }
                .onEnded { value in
                    finalCaptionOffset.height += value.translation.height // Accumulate the drag offset
                    finalCaptionOffset.width += value.translation.width
                    captionDragOffset = .zero // Reset the temporary drag state
                }
            : nil
        )
        // Padding when not expanded
        .padding(.bottom, tappedMediaUrl == currentMediaUrl ? 10 : 0)  // Adjust padding when not expanded
    }

    private func handleMediaTap(mediaUrl: String, mediaType: String, scrollProxy: ScrollViewProxy) {
        guard canTap else { return }
        canTap = false
        let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
        impactFeedback.impactOccurred()

        withAnimation(.spring(response: 0.5, dampingFraction: 0.95)) {
            if tappedMediaUrl == mediaUrl {
                tappedMediaUrl = nil
                show = false
                isScrollDisabled = false
            } else {
                tappedMediaUrl = mediaUrl
                show = true
                isScrollDisabled = true

                if mediaUrls.first?.0 == mediaUrl {
                    withAnimation {
                        scrollProxy.scrollTo(mediaUrl, anchor: .top)
                    }
                } else if mediaUrls.last?.0 == mediaUrl {
                    withAnimation {
                        scrollProxy.scrollTo(mediaUrl, anchor: .bottom)
                    }
                } else {
                    withAnimation {
                        scrollProxy.scrollTo(mediaUrl, anchor: .center)
                    }
                }
            }
        }
        isFullCaptionVisible = tappedMediaUrl != nil
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            canTap = true
        }
    }

    private func saveMedia(mediaUrl: String) {
        if !savedImages.contains(mediaUrl) {
            PHPhotoLibrary.requestAuthorization { status in
                if status == .authorized {
                    downloadAndSaveMedia(from: mediaUrl) {
                        print("Media successfully saved to Photos.")
                    }
                } else {
                    print("Permission to access photo library is denied.")
                }
            }
        }
    }

    static func loadSavedImages() -> Set<String> {
        if let savedData = UserDefaults.standard.array(forKey: "savedImages") as? [String] {
            return Set(savedData)
        }
        return []
    }

    func saveMediaUrlToUserDefaults(mediaUrl: String) {
        var savedImages = Home.loadSavedImages()
        savedImages.insert(mediaUrl)
        UserDefaults.standard.set(Array(savedImages), forKey: "savedImages")
    }

    func downloadAndSaveMedia(from urlString: String, completion: @escaping () -> Void) {
        guard let url = URL(string: urlString) else { return }

        DispatchQueue.main.async {
            savedImages.insert(urlString)  // Optimistically insert the media into savedImages
            saveMediaUrlToUserDefaults(mediaUrl: urlString)
        }

        DispatchQueue.global(qos: .background).async {
            URLSession.shared.dataTask(with: url) { data, response, error in
                if let data = data, let image = UIImage(data: data) {
                    UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)

                    DispatchQueue.main.async {
                        completion()
                        print("Media successfully saved to Photos.")
                    }
                } else {
                    print("Error downloading media: \(error?.localizedDescription ?? "Unknown error")")
                }
            }.resume()
        }
    }

    private func updateIconColors() {
        if showProfileView {
            homeIconColor = Color(.systemGray3)
            profileIconColor = .black
        } else {
            homeIconColor = .black
            profileIconColor = Color(.systemGray3)
        }
    }
    
    private func onAppearLogic() {
        fetchUsername()
        fetchAllMedia()
        imagesAppeared = true
        triggerHaptic()
    }
    
    private func fetchUsername() {
        guard let user = Auth.auth().currentUser else { return }
        let db = Firestore.firestore()
        let usernameDocRef = db.collection("users").document(user.uid).collection("username").document("info")
        usernameDocRef.getDocument { document, error in
            if let document = document, document.exists {
                let username = document.data()?["username"] as? String
                self.username = username ?? ""
            } else {
                print("Username not found in Firestore")
                self.username = "No Username"
            }
        }
    }

    private func fetchAllMedia() {
        guard let user = Auth.auth().currentUser else { return }
        let db = Firestore.firestore()
        
        // Fetch both photos and videos, combine them
        let photosCollectionRef = db.collection("users").document(user.uid).collection("photos")
        let videosCollectionRef = db.collection("users").document(user.uid).collection("videos")

        photosCollectionRef.getDocuments { photoSnapshot, error in
            if let photoSnapshot = photoSnapshot {
                let photoUrls = photoSnapshot.documents.compactMap { document in
                    let data = document.data()
                    if let url = data["photoURL"] as? String,
                       let caption = data["caption"] as? String,
                       let timestamp = data["timestamp"] as? Timestamp {
                        return (url, caption, timestamp, "photo")
                    }
                    return nil
                }

                videosCollectionRef.getDocuments { videoSnapshot, error in
                    if let videoSnapshot = videoSnapshot {
                        let videoUrls = videoSnapshot.documents.compactMap { document in
                            let data = document.data()
                            if let url = data["videoURL"] as? String,
                               let caption = data["caption"] as? String,
                               let timestamp = data["timestamp"] as? Timestamp {
                                return (url, caption, timestamp, "video")
                            }
                            return nil
                        }

                        // Combine photo and video URLs
                        self.mediaUrls = (photoUrls + videoUrls).sorted { $0.2.dateValue() > $1.2.dateValue() }
                        self.isLoadingMedia = false
                    }
                }
            }
        }
    }

    private func shortenCaption(_ caption: String) -> String {
        if isFullCaptionVisible {
            return caption
        } else {
            let words = caption.split(separator: " ")
            let limitedWords = words.prefix(3)
            let shortCaption = limitedWords.joined(separator: " ")
            return shortCaption + (words.count > 3 ? "..." : "")
        }
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d"
        return formatter.string(from: date)
    }

    private func triggerHaptic() {
        // Implement haptic feedback here
    }

    private func loadProfileImage() {
        let db = Firestore.firestore()
        let userRef = db.collection("users").document(Auth.auth().currentUser?.uid ?? "")
        userRef.getDocument { document, error in
            if let document = document, document.exists {
                if let urlString = document.data()?["profileImageURL"] as? String, let url = URL(string: urlString) {
                    downloadProfileImage(from: url)
                }
            }
        }
    }
    
    private func downloadProfileImage(from url: URL) {
        let storageRef = Storage.storage().reference(forURL: url.absoluteString)
        storageRef.getData(maxSize: Int64(1 * 1024 * 1024)) { data, error in
            if let data = data, let image = UIImage(data: data) {
                DispatchQueue.main.async {
                    self.preloadedProfileImage = image
                }
            }
        }
    }
}

struct Home_Previews: PreviewProvider {
    static var previews: some View {
        Home()
    }
}
