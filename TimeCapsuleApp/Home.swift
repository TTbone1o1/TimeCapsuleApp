import SwiftUI
import Firebase
import FirebaseAuth
import FirebaseFirestore
import FirebaseStorage

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
    @State private var imageUrls: [(String, String, Timestamp)] = [] // Store (URL, Caption, Timestamp) tuples
    @State private var photoCount: Int = 0
    @State private var isShowingMessage = false
    @State private var isCaptionVisible: Bool = false
    @State private var isImageLoaded: Bool = false
    @State private var highlightedImageUrl: String? = nil
    @State private var tappedImageUrl: String? = nil
    @State private var scaleAmount: CGFloat = 1.0
    @State private var isSignedOut: Bool = false
    @State var show = false
    @State private var isScrollDisabled: Bool = false
    @State private var dragOffset: CGFloat = 0
    @State private var showProfileView: Bool = false
    @State private var homeIconColor: Color = .black
    @State private var profileIconColor = Color(.systemGray3)
    @State private var showCameraController = false
    @State private var isImageExpanded = false
    @State private var areButtonsVisible = true
    @State private var isSettingsOpen = false  // State for settings
    @State private var isShowingSetting = false
    @State private var isFullCaptionVisible: Bool = false // State for showing full caption
    @State private var preloadedProfileImage: UIImage? = nil // State to store the preloaded profile image
    
    @Environment(\.colorScheme) var currentColorScheme
    
    @Namespace var namespace
    
    var body: some View {
        if isSignedOut {
            Timecap()
        } else {
            NavigationView {
                GeometryReader { geometry in
                    ZStack {
                        mainContentView(geometry: geometry)
                            .offset(x: dragOffset)
                            .gesture(
                                DragGesture()
                                    .onChanged { value in
                                        if !showProfileView && value.translation.width < 0 {
                                            dragOffset = value.translation.width
                                        } else if showProfileView && value.translation.width > 0 {
                                            dragOffset = value.translation.width - UIScreen.main.bounds.width
                                        }
                                    }
                                    .onEnded { value in
                                        withAnimation {
                                            if value.translation.width < -100 {
                                                dragOffset = -UIScreen.main.bounds.width
                                                showProfileView = true
                                            } else if value.translation.width > 100 {
                                                dragOffset = 0
                                                showProfileView = false
                                            } else {
                                                dragOffset = showProfileView ? -UIScreen.main.bounds.width : 0
                                            }
                                            updateIconColors()
                                        }
                                    }
                            )
                        
                        if showProfileView || dragOffset < 0 {
                            Profile(isImageExpanded: $isImageExpanded,
                                    areButtonsVisible: $areButtonsVisible,
                                    isShowingSetting: $isShowingSetting,
                                    selectedImage: $preloadedProfileImage) // Pass the preloaded image here
                            .zIndex(2)
                            .offset(x: UIScreen.main.bounds.width + dragOffset)
                            .gesture(
                                DragGesture()
                                    .onChanged { value in
                                        if showProfileView && value.translation.width > 0 {
                                            dragOffset = value.translation.width - UIScreen.main.bounds.width
                                        }
                                    }
                                    .onEnded { value in
                                        withAnimation {
                                            if value.translation.width > 100 {
                                                dragOffset = 0
                                                showProfileView = false
                                                updateIconColors()
                                            } else {
                                                dragOffset = -UIScreen.main.bounds.width
                                            }
                                        }
                                    }
                            )
                            .transition(.identity)
                        }
                        
                        // Fixed VStack stays on the screen at all times
                        if !show && !isImageExpanded && !isSettingsOpen && !isShowingSetting {
                            VStack(spacing: 20) {
                                Spacer()
                                ZStack {
                                    Button(action: {
                                        // Remove animation from toggle to avoid delay
                                        let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
                                        impactFeedback.impactOccurred()

                                        // Toggle the camera view instantly without animation
                                        showCameraController = true
                                    }) {
                                        ZStack {
                                            Circle()
                                                .stroke(Color.secondary.opacity(0.7), lineWidth: 3) // Secondary adapts to the mode as a lighter color
                                                .frame(width: 52, height: 52)
                                            
                                            Circle()
                                                .fill(Color.secondary.opacity(0.7)) // Secondary adapts to light gray in both modes
                                                .frame(width: 37, height: 37)
                                        }
                                    }

                                    
                                    HStack {
                                        Image("Home")
                                            .withTintColor(showProfileView ? Color.secondary.opacity(0.7) : Color.primary) // Primary for active, Secondary for inactive
                                            .frame(width: 34, height: 34)
                                            .onTapGesture {
                                                withAnimation {
                                                    dragOffset = 0
                                                    showProfileView = false
                                                    updateIconColors()
                                                }
                                            }
                                        
                                        Spacer()
                                        
                                        Image("Profile")
                                            .withTintColor(showProfileView ? Color.primary : Color.secondary.opacity(0.7)) // Primary for active, Secondary for inactive
                                            .frame(width: 34, height: 34)
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
                            
                        }
                        
                        if showCameraController {
                            CameraController(isPresented: $showCameraController)
                                .transition(.opacity)
                                .zIndex(4)
                                //.animation(.easeInOut(duration: 0.1), value: showCameraController)
                        }
                    }
                    .edgesIgnoringSafeArea(.all)
                    .onAppear {
                        dragOffset = showProfileView ? -UIScreen.main.bounds.width : 0
                        onAppearLogic()
                        updateIconColors()
                        
                        // Preload the profile image
                        loadProfileImage()
                    }
                }
            }
        }
    }
    
    private func mainContentView(geometry: GeometryProxy) -> some View {
        ZStack {
            imageGalleryView
                .zIndex(1)
            
            VStack {
                Spacer().frame(height: 20)
                
                if tappedImageUrl == nil {
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
                }
                
                Spacer()
            }
            .zIndex(2)
        }
    }
    
    private var imageGalleryView: some View {
        ScrollViewReader { scrollProxy in
            ScrollView {
                VStack(spacing: 45) {
                    ForEach(imageUrls, id: \.0) { imageUrl, caption, timestamp in
                        ZStack(alignment: .bottom) {
                            AsyncImage(url: URL(string: imageUrl)) { phase in
                                switch phase {
                                case .empty:
                                    ProgressView()
                                case .success(let image):
                                    image
                                        .resizable()
                                        .aspectRatio(contentMode: .fill)
                                        .matchedGeometryEffect(id: imageUrl, in: namespace)
                                        .frame(width: tappedImageUrl == imageUrl ? UIScreen.main.bounds.width : 313,
                                               height: tappedImageUrl == imageUrl ? UIScreen.main.bounds.height : 421)
                                        .cornerRadius(tappedImageUrl == imageUrl ? 0 : 33)
                                        .shadow(radius: 20, x: 0, y: 24)
                                        .onTapGesture {
                                            // Trigger haptic feedback
                                            let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
                                            impactFeedback.impactOccurred()
                                            
                                            withAnimation(.spring(response: 0.5, dampingFraction: 0.95)) {
                                                if tappedImageUrl == imageUrl {
                                                    tappedImageUrl = nil
                                                    show = false
                                                    isScrollDisabled = false
                                                } else {
                                                    tappedImageUrl = imageUrl
                                                    show = true
                                                    isScrollDisabled = true
                                                    withAnimation {
                                                        scrollProxy.scrollTo(imageUrl, anchor: .center)
                                                    }
                                                }
                                            }
                                            isFullCaptionVisible = tappedImageUrl != nil
                                        }
                                        .overlay(
                                            LinearGradient(
                                                gradient: Gradient(stops: [
                                                    .init(color: Color.black.opacity(1.0), location: 0.0), // Black at the bottom
                                                    .init(color: Color.black.opacity(0.0), location: 0.2), // Gradually fade to clear
                                                    .init(color: Color.clear, location: 1.0) // Clear at the top
                                                ]),
                                                startPoint: .bottom,  // Start gradient from the bottom
                                                endPoint: .top        // End with clear at the top
                                            )
                                            .frame(width: tappedImageUrl == imageUrl ? UIScreen.main.bounds.width : 313,
                                                   height: tappedImageUrl == imageUrl ? UIScreen.main.bounds.height : 422) // Maintain the 421px height
                                                .clipShape(RoundedRectangle(cornerRadius: 33, style: .continuous)) // Round the bottom corners
                                                .allowsHitTesting(false) // Allow taps to pass through the gradient
                                        )
                                    
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
                            .id(imageUrl)
                            
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
                        }
                    }
                }
                .padding(.vertical, 130)
            }
            .scrollDisabled(isScrollDisabled)
            .ignoresSafeArea(edges: [.leading, .trailing])
            .scrollIndicators(.hidden)
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
        fetchAllPhotos()
        imagesAppeared = true
        triggerHaptic()
        NotificationManager.shared.checkForPermission { granted in
            if granted {
                NotificationManager.shared.dispatchNotification()
            } else {
                print("Notification permissions not granted.")
            }
        }
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
    
    private func fetchAllPhotos() {
        guard let user = Auth.auth().currentUser else { return }
        let db = Firestore.firestore()
        let photosCollectionRef = db.collection("users").document(user.uid).collection("photos")
        
        photosCollectionRef.getDocuments { snapshot, error in
            if let snapshot = snapshot {
                self.photoCount = snapshot.count
                self.imageUrls = snapshot.documents.compactMap { document in
                    let data = document.data()
                    if let url = data["photoURL"] as? String,
                       let caption = data["caption"] as? String,
                       let timestamp = data["timestamp"] as? Timestamp {
                        return (url, caption, timestamp)
                    }
                    return nil
                }
                self.imageUrls.sort { $0.2.dateValue() > $1.2.dateValue() }
            } else {
                print("Error fetching image URLs: \(error?.localizedDescription ?? "Unknown error")")
            }
        }
    }
    
    private func shortenCaption(_ caption: String) -> String {
        if isFullCaptionVisible {
            return caption
        } else {
            let words = caption.split(separator: " ")
            let limitedWords = words.prefix(3) // Show only the first 3 words
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
    
    struct Home_Previews: PreviewProvider {
        static var previews: some View {
            Home()
        }
    }
}
