import SwiftUI
import Firebase
import FirebaseAuth
import FirebaseFirestore
import FirebaseStorage

struct Home: View {
    @State private var username: String = ""
    @State private var imagesAppeared = false
    @State private var hasPostedPhoto = false
    @State private var imageUrls: [(String, String, Timestamp)] = [] // Store (URL, Caption, Timestamp) tuples
    @State private var photoCount: Int = 0
    @State private var isShowingMessage = false
    @State private var isCaptionVisible: Bool = false
    @State private var isImageLoaded: Bool = false // New state for tracking image load status
    @State private var highlightedImageUrl: String? = nil
    @State private var tappedImageUrl: String? = nil // State to track the tapped image URL
    @State private var scaleAmount: CGFloat = 1.0 // State to control the scaling
    @State private var isSignedOut: Bool = false // State to track sign out status
    @State var show = false
    @State private var isScrollDisabled: Bool = false
    
    @State private var dragOffset: CGFloat = 0 // State to track drag offset
    @State private var showProfileView: Bool = false // State to show the profile view

    @Namespace var namespace

    var body: some View {
        if isSignedOut {
            // Navigate back to Timecap if the user is signed out
            Timecap()
        } else {
            GeometryReader { geometry in
                ZStack {
                    mainContentView(geometry: geometry)
                        .offset(x: dragOffset)
                        .gesture(
                            DragGesture()
                                .onChanged { value in
                                    if !showProfileView && value.translation.width < 0 {
                                        // Dragging left to reveal ProfileView
                                        dragOffset = value.translation.width
                                    } else if showProfileView && value.translation.width > 0 {
                                        // Dragging right to reveal HomeView
                                        dragOffset = value.translation.width - UIScreen.main.bounds.width
                                    }
                                }
                                .onEnded { value in
                                    withAnimation {
                                        if value.translation.width < -100 {
                                            // Complete transition to ProfileView
                                            dragOffset = -UIScreen.main.bounds.width
                                            showProfileView = true
                                        } else if value.translation.width > 100 {
                                            // Complete transition back to HomeView
                                            dragOffset = 0
                                            showProfileView = false
                                        } else {
                                            // Snap back to the appropriate position based on current view
                                            dragOffset = showProfileView ? -UIScreen.main.bounds.width : 0
                                        }
                                    }
                                }
                        )
                    
                    if showProfileView || dragOffset < 0 {
                        Profile()
                            .zIndex(2) // Ensure the Profile view stays on top
                            .offset(x: UIScreen.main.bounds.width + dragOffset)
                            .gesture(
                                DragGesture()
                                    .onChanged { value in
                                        if showProfileView && value.translation.width > 0 {
                                            // Allow dragging right to reveal HomeView
                                            dragOffset = value.translation.width - UIScreen.main.bounds.width
                                        }
                                    }
                                    .onEnded { value in
                                        withAnimation{
                                            if value.translation.width > 100 {
                                                // Complete transition back to HomeView
                                                dragOffset = 0
                                                showProfileView = false
                                            } else {
                                                // Snap back to ProfileView
                                                dragOffset = -UIScreen.main.bounds.width
                                            }
                                        }
                                    }
                            )
                            .transition(.identity) // Ensure no transition effects are applied
                    }
                    
                    
                    // Fixed VStack stays on the screen at all times
                    VStack(spacing: 20) {
                        Spacer()
                        ZStack {
                            // The stroked circle with the gray-filled circle inside
                            Circle()
                                .stroke(Color.gray, lineWidth: 3)
                                .frame(width: 52, height: 52)
                            
                            Circle()
                                .fill(Color.gray)
                                .frame(width: 37, height: 37)
                            
                            // HStack to position images on either side of the circle
                            HStack {
                                Image("Home")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 34, height: 34) // Adjust the size as needed
                                
                                Spacer() // This spacer ensures the images are positioned on the left and right sides
                                
                                Image("Profile")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 34, height: 34) // Adjust the size as needed
                            }
                            .frame(width: 290) // Adjust this width if needed to ensure the proper positioning
                        }
                    }
                    .padding(.horizontal, 60)
                    .padding(.bottom, 40) // Adjust the padding as needed
                    .zIndex(3) // Ensure this VStack is always on top of everything
                }
                .edgesIgnoringSafeArea(.all)
                .onAppear {
                    dragOffset = showProfileView ? -UIScreen.main.bounds.width : 0
                    onAppearLogic()
                }
            }
        }
    }

    private func mainContentView(geometry: GeometryProxy) -> some View {
        ZStack {
            // Main content with the existing image gallery, header, and footer
            imageGalleryView
                .zIndex(1) // Ensure image gallery is below header

            // Header HStack remains fixed at the top, overlaid on images
            VStack {
                Spacer().frame(height: 20) // Add space to adjust position

                if tappedImageUrl == nil {
                    HStack {
                        Text(username.isEmpty ? "" : username)
                            .font(.system(size: 18, weight: .bold, design: .rounded))
                            .fontWeight(.bold)
                            .padding(.leading)
                            .foregroundColor(Color.primary)

                        Spacer()

                        NavigationLink(destination: Profile().navigationBarBackButtonHidden(true)) {
                            VStack(spacing: 2) {
                                ForEach(0..<3) { _ in
                                    Rectangle()
                                        .frame(width: 16, height: 3)
                                        .cornerRadius(20)
                                        .foregroundColor(Color.primary)
                                }
                            }
                            .padding(.trailing)
                        }
                    }
                    .padding(.top, geometry.safeAreaInsets.top)
                    .transition(.opacity) // Add a transition for smooth appearance/disappearance
                }

                Spacer()
            }
            .zIndex(2) // Ensure header is on top
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
                                            withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                                                if tappedImageUrl == imageUrl {
                                                    tappedImageUrl = nil
                                                    show = false
                                                    isScrollDisabled = false  // Re-enable scrolling
                                                } else {
                                                    tappedImageUrl = imageUrl
                                                    show = true
                                                    isScrollDisabled = true   // Disable scrolling
                                                    withAnimation {
                                                        scrollProxy.scrollTo(imageUrl, anchor: .center)
                                                    }
                                                }
                                            }
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

                            VStack(alignment: .leading, spacing: 5) {
                                // Conditional padding for timestamp based on whether there's a caption
                                Text(formatDate(timestamp.dateValue()))
                                    .font(.system(size: 18, weight: .bold, design: .rounded))
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 28)
                                    .padding(.top, shortenCaption(caption).isEmpty ? 80 : 1)
                                    .frame(width: 348, height: 30, alignment: .leading)
                                
                                // Caption displayed below the timestamp
                                Text(shortenCaption(caption))
                                    .font(.system(size: 24, weight: .bold, design: .rounded))
                                    .padding(.horizontal, 28)
                                    .frame(width: 348, height: 30, alignment: .leading)
                                    .foregroundColor(.white)
                                    .cornerRadius(5)
                                    .padding(.bottom, 26)
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

                if self.imageUrls.isEmpty {
                    print("No photos found.")
                } else {
                    //print("Photos found: \(self.imageUrls)")
                }
            } else {
                print("Error fetching image URLs: \(error?.localizedDescription ?? "Unknown error")")
            }
        }
    }

    private func shortenCaption(_ caption: String) -> String {
        let words = caption.split(separator: " ")
        let limitedWords = words.prefix(8)
        let shortCaption = limitedWords.joined(separator: " ")
        return shortCaption
    }

    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d"
        return formatter.string(from: date)
    }

    private func triggerHaptic() {
        // Trigger haptic feedback (optional)
    }
}

struct Home_Previews: PreviewProvider {
    static var previews: some View {
        Home()
    }
}
