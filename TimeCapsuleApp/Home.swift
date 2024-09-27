import SwiftUI
import Firebase
import FirebaseAuth
import FirebaseFirestore
import FirebaseStorage
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
    @State private var canTap: Bool = true // Add this to control tapping
    @State private var homeProfileScale: CGFloat = 1.0
    @State private var isLoadingImages = true
    @State private var savedImages: Set<String> = loadSavedImages() // Track saved image URLs
    @State private var captionDragOffset: CGSize = .zero
    @State private var finalCaptionOffset: CGSize = .zero // To store the final drag offset

    @Environment(\.colorScheme) var currentColorScheme
    @Namespace var namespace

    var body: some View {
        if isSignedOut {
            Timecap()
        } else {
            NavigationView {
                GeometryReader { geometry in
                    ZStack {
                        Profile(isImageExpanded: $isImageExpanded,
                                isShowingSetting: $isShowingSetting,
                                selectedImage: $preloadedProfileImage,
                                homeProfileScale: $homeProfileScale)
                        .offset(x: UIScreen.main.bounds.width + dragOffset)
                        .zIndex(1)
                        
                        mainContentView(geometry: geometry)
                            .offset(x: dragOffset)
                            .gesture(
                                tappedImageUrl == nil ?
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
                        
                        if !isImageExpanded && !isSettingsOpen && !isShowingSetting && !isSignedOut {
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
                            .onChange(of: tappedImageUrl) { newValue in
                                if tappedImageUrl != nil {
                                    withAnimation(.easeInOut(duration: 0.2)) {
                                        homeProfileScale = 0.0
                                    }
                                } else {
                                    withAnimation(.easeInOut(duration: 0.2)) {
                                        homeProfileScale = 1.0
                                    }
                                }
                            }
                        }

                        if showCameraController {
                            CameraController(isPresented: $showCameraController)
                                .transition(.opacity)
                                .zIndex(4)
                        }
                    }
                    .edgesIgnoringSafeArea(.all)
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
                imageGalleryView()
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

                        if !isLoadingImages && imageUrls.isEmpty {
                            VStack {
                                Spacer()

                                Text("Take a photo to start")
                                    .font(.system(size: 18, weight: .bold, design: .rounded))
                                    .fontWeight(.bold)
                                    .padding(.bottom, 30)

                                HStack {
                                    Spacer()

                                    HStack {
                                        Image("1")
                                            .resizable()
                                            .frame(width: 82.37, height: 120.26)
                                            .cornerRadius(19)
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 19)
                                                    .stroke(Color.white, lineWidth: 4)
                                            )
                                            .rotationEffect(Angle(degrees: -16))
                                            .offset(x: 25, y: 15)
                                            .shadow(radius: 24, x: 0, y: 14)
                                            .zIndex(3)
                                            .scaleEffect(imagesAppeared ? 1 : 0)
                                            .animation(.interpolatingSpring(stiffness: 60, damping: 7).delay(0.1), value: imagesAppeared)
                                            .onAppear {
                                                if imagesAppeared {
                                                    triggerHaptic()
                                                }
                                            }

                                        Image("2")
                                            .resizable()
                                            .frame(width: 82.37, height: 120.26)
                                            .cornerRadius(19)
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 19)
                                                    .stroke(Color.white, lineWidth: 4)
                                            )
                                            .zIndex(2)
                                            .rotationEffect(Angle(degrees: -2))
                                            .shadow(radius: 24, x: 0, y: 14)
                                            .scaleEffect(imagesAppeared ? 1 : 0)
                                            .animation(.interpolatingSpring(stiffness: 60, damping: 7).delay(0.2), value: imagesAppeared)
                                            .onAppear {
                                                if imagesAppeared {
                                                    triggerHaptic()
                                                }
                                            }

                                        Image("3")
                                            .resizable()
                                            .frame(width: 82.37, height: 120.26)
                                            .cornerRadius(19)
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 19)
                                                    .stroke(Color.white, lineWidth: 4)
                                            )
                                            .zIndex(1)
                                            .rotationEffect(Angle(degrees: 17))
                                            .shadow(radius: 24, x: 0, y: 14)
                                            .offset(x: -33, y: 15)
                                            .scaleEffect(imagesAppeared ? 1 : 0)
                                            .animation(.interpolatingSpring(stiffness: 60, damping: 7).delay(0.3), value: imagesAppeared)
                                            .onAppear {
                                                if imagesAppeared {
                                                    triggerHaptic()
                                                }
                                            }
                                    }

                                    Spacer()
                                }

                                Spacer(minLength: 350)
                            }
                        }
                    }

                    Spacer()
                }
                .zIndex(2)
            }
        }
    
    private func imageGalleryView() -> some View {
        ScrollViewReader { scrollProxy in
            ScrollView {
                VStack(spacing: 45) {
                    ForEach(imageUrls, id: \.0) { imageUrl, caption, timestamp in
                        ZStack(alignment: .bottom) {
                            AsyncImage(
                                url: URL(string: imageUrl),
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
                                                .matchedGeometryEffect(id: imageUrl, in: namespace)
                                                .frame(width: tappedImageUrl == imageUrl ? UIScreen.main.bounds.width : 313,
                                                       height: tappedImageUrl == imageUrl ? UIScreen.main.bounds.height : 421)
                                                .cornerRadius(tappedImageUrl == imageUrl ? 0 : 33)
                                                .shadow(radius: 20, x: 0, y: 24)
                                                .onTapGesture {
                                                    handleImageTap(imageUrl: imageUrl, scrollProxy: scrollProxy)
                                                }

                                            if tappedImageUrl == imageUrl {
                                                Button {
                                                    saveImage(imageUrl: imageUrl)
                                                } label: {
                                                    Image(systemName: savedImages.contains(imageUrl) ? "checkmark.circle" : "square.and.arrow.down")
                                                        .foregroundColor(savedImages.contains(imageUrl) ? .green : .white)
                                                        .font(.system(size: 24))
                                                        .padding(40)
                                                        .scaleEffect(savedImages.contains(imageUrl) ? 1.2 : 1)
                                                        .animation(.easeInOut(duration: 0.2), value: savedImages.contains(imageUrl))
                                                        .transition(.opacity)
                                                }
                                                .disabled(savedImages.contains(imageUrl))
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
                                            .frame(width: tappedImageUrl == imageUrl ? UIScreen.main.bounds.width : 313,
                                                   height: tappedImageUrl == imageUrl ? UIScreen.main.bounds.height : 421)
                                            .clipShape(RoundedRectangle(cornerRadius: tappedImageUrl == imageUrl ? 0 : 33, style: .continuous))
                                            .animation(.spring(response: 0.5, dampingFraction: 0.95), value: tappedImageUrl)
                                            .allowsHitTesting(false)
                                        )

                                        // Call the caption view when the image loads successfully
                                        if currentColorScheme == .dark {
                                            captionView(caption: caption, timestamp: timestamp, tappedImageUrl: tappedImageUrl, currentImageUrl: imageUrl)
                                                .transition(.movingParts.filmExposure) // Apply transition only in dark mode
                                                .offset(y: tappedImageUrl == imageUrl ? 400 : 170)
                                        } else {
                                            captionView(caption: caption, timestamp: timestamp, tappedImageUrl: tappedImageUrl, currentImageUrl: imageUrl)
                                                .offset(y: tappedImageUrl == imageUrl ? 400 : 170) // No transition in light mode
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
                                .id(imageUrl)
                            }
                        }
                        .offset(y: tappedImageUrl == imageUrl && imageUrls.count == 1 ? -130 : 0)
                    }
                }
                .padding(.vertical, 130)
            }
            .scrollDisabled(isScrollDisabled)
            .ignoresSafeArea(edges: [.leading, .trailing])
            .scrollIndicators(.hidden)
        }
    }


    private func captionView(caption: String, timestamp: Timestamp, tappedImageUrl: String?, currentImageUrl: String) -> some View {
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
        // Offset for when the image is expanded
        .offset(tappedImageUrl != nil ? CGSize(width: finalCaptionOffset.width + captionDragOffset.width, height: finalCaptionOffset.height + captionDragOffset.height) : .zero)
        // Gesture for dragging the caption when expanded
        .gesture(
            tappedImageUrl != nil ? DragGesture()
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
        .padding(.bottom, tappedImageUrl == nil ? 10 : 0)  // Adjust padding when not expanded
    }




    private func handleImageTap(imageUrl: String, scrollProxy: ScrollViewProxy) {
        guard canTap else { return }
        canTap = false
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

                if imageUrls.first?.0 == imageUrl {
                    withAnimation {
                        scrollProxy.scrollTo(imageUrl, anchor: .top)
                    }
                } else if imageUrls.last?.0 == imageUrl {
                    withAnimation {
                        scrollProxy.scrollTo(imageUrl, anchor: .bottom)
                    }
                } else {
                    withAnimation {
                        scrollProxy.scrollTo(imageUrl, anchor: .center)
                    }
                }
            }
        }
        isFullCaptionVisible = tappedImageUrl != nil
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            canTap = true
        }
    }

    private func saveImage(imageUrl: String) {
        if !savedImages.contains(imageUrl) {
            PHPhotoLibrary.requestAuthorization { status in
                if status == .authorized {
                    downloadAndSaveImage(from: imageUrl) {
                        print("Image successfully saved to Photos.")
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

    func saveImageUrlToUserDefaults(imageUrl: String) {
        var savedImages = Home.loadSavedImages()
        savedImages.insert(imageUrl)
        UserDefaults.standard.set(Array(savedImages), forKey: "savedImages")
    }

    func downloadAndSaveImage(from urlString: String, completion: @escaping () -> Void) {
        guard let url = URL(string: urlString) else { return }

        DispatchQueue.main.async {
            savedImages.insert(urlString)  // Optimistically insert the image into savedImages
            saveImageUrlToUserDefaults(imageUrl: urlString)
        }

        DispatchQueue.global(qos: .background).async {
            URLSession.shared.dataTask(with: url) { data, response, error in
                if let data = data, let image = UIImage(data: data) {
                    UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)

                    DispatchQueue.main.async {
                        completion()
                        print("Image successfully saved to Photos.")
                    }
                } else {
                    print("Error downloading image: \(error?.localizedDescription ?? "Unknown error")")
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
        fetchAllPhotos()
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
                self.isLoadingImages = false
            } else {
                print("Error fetching image URLs: \(error?.localizedDescription ?? "Unknown error")")
                self.isLoadingImages = false
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
