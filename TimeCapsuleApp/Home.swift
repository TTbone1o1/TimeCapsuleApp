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
    @Namespace var namespace

    var body: some View {
        if isSignedOut {
            // Navigate back to Timecap if the user is signed out
            Timecap()
        } else {
            GeometryReader { geometry in
                let safeArea = geometry.safeAreaInsets
                
                NavigationView {
                    VStack {
                        // Header HStack remains fixed at the top
                        HStack {
                            Text(username.isEmpty ? "" : username)
                                .font(.system(size: 18))
                                .fontWeight(.bold)
                                .padding()
                            
                            Spacer()
                            
                            NavigationLink(destination: Setting(isSignedOut: $isSignedOut).navigationBarBackButtonHidden(true)) {
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
                        .background(Color.white) // Ensure background is set to avoid overlap issues
                        .zIndex(2) // Keep it above other content
                        .opacity(tappedImageUrl == nil ? 1 : 0) // Hide when an image is tapped
                        .animation(.easeInOut(duration: 0.3), value: tappedImageUrl)
                        
                        Spacer()
                        
                        ZStack {
                            VStack {
                                content
                                Spacer()
                            }
                            .padding()
                            .frame(maxHeight: .infinity)
                            .onAppear(perform: onAppearLogic)
                            .onDisappear {
                                imagesAppeared = false
                            }

                            floatingFooter(safeArea: safeArea, isVisible: true) // Pass visibility state
                                .zIndex(1)
                        }
                        .edgesIgnoringSafeArea(.bottom)
                    }
                }
            }
        }
    }

    private var content: some View {
        Group {
            if imageUrls.isEmpty {
                emptyStateView
            } else {
                imageGalleryView
            }
        }
    }
    
    private var emptyStateView: some View {
        VStack {
            Spacer()
                .frame(height: 200)
            Text("Take a photo to start")
                .font(.system(size: 18))
                .padding(.bottom, 30)
                .fontWeight(.bold)
            
            HStack {
                Spacer()
                
                HStack {
                    imageView(imageName: "1", zIndex: 3, rotation: -16, offset: (25, 15), delay: 0.1)
                    imageView(imageName: "2", zIndex: 2, rotation: -2, delay: 0.2)
                    imageView(imageName: "3", zIndex: 1, rotation: 17, offset: (-33, 15), delay: 0.3)
                }
                
                Spacer()
            }
            Spacer()
        }
    }
    
    private func imageView(imageName: String, zIndex: Double, rotation: Double, offset: (x: CGFloat, y: CGFloat) = (0, 0), delay: Double) -> some View {
        Image(imageName)
            .resizable()
            .frame(width: 82.37, height: 120.26)
            .cornerRadius(19)
            .overlay(
                RoundedRectangle(cornerRadius: 19)
                    .stroke(Color.white, lineWidth: 4)
            )
            .rotationEffect(Angle(degrees: rotation))
            .offset(x: offset.x, y: offset.y)
            .shadow(radius: 24, x: 0, y: 14)
            .zIndex(zIndex)
            .scaleEffect(imagesAppeared ? 1 : 0)
            .animation(.interpolatingSpring(stiffness: 60, damping: 7).delay(delay), value: imagesAppeared)
            .onAppear {
                if imagesAppeared {
                    triggerHaptic()
                }
            }
    }
    
    private var imageGalleryView: some View {
        ScrollViewReader { scrollProxy in
            ZStack {
                // Main content (image gallery)
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
                                            .frame(width: tappedImageUrl == imageUrl ? 413 : 313,
                                                   height: tappedImageUrl == imageUrl ? .infinity : 421)
                                            .cornerRadius(tappedImageUrl == imageUrl ? 20 : 33)
                                            .shadow(radius: 20, x: 0, y: 24)
                                            .onTapGesture {
                                                withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                                                    if tappedImageUrl == imageUrl {
                                                        // If the tapped image is already enlarged, reset
                                                        tappedImageUrl = nil
                                                        show = false
                                                    } else {
                                                        // Enlarge the tapped image and scroll to it
                                                        tappedImageUrl = imageUrl
                                                        show = true
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
                                .id(imageUrl) // Assign the image URL as the ID

                                VStack(alignment: .leading, spacing: 5) {
                                    Text(formatDate(timestamp.dateValue()))
                                        .font(.system(size: 18))
                                        .foregroundColor(.white)
                                        .padding(.horizontal, 28)
                                        .frame(width: 348, height: 30, alignment: .leading)
                                    Text(shortenCaption(caption))
                                        .font(.system(size: 24))
                                        .padding(.horizontal, 28)
                                        .frame(width: 348, height: 70, alignment: .leading)
                                        .foregroundColor(.white)
                                        .cornerRadius(5)
                                        .padding(.bottom, 16)
                                }
                            }
                        }
                    }
                    .padding(.vertical, 20)
                }
                .ignoresSafeArea(edges: [.leading, .trailing])
                .scrollIndicators(.hidden)
            }
        }
    }

    private func floatingFooter(safeArea: EdgeInsets, isVisible: Bool) -> some View {
        ZStack {
            TransparentBlurView(removeAllFilters: true)
                .blur(radius: 10)
                .frame(height: 100 + safeArea.bottom)
                .zIndex(1)
                .offset(y: 35)
                .opacity(isVisible && tappedImageUrl == nil ? 1 : 0) // Hide when an image is tapped
            
            HStack {
                NavigationLink(destination: CameraController().edgesIgnoringSafeArea(.all)) {
                    ZStack {
                        Circle()
                            .stroke(photoCount >= 2 ? Color.white : Color.gray, lineWidth: 3)
                            .frame(width: 24, height: 24)
                        
                        Circle()
                            .frame(width: 13, height: 13)
                            .foregroundColor(photoCount >= 2 ? .white : .gray)
                    }
                    .opacity(photoCount >= 2 ? 0.4 : 0.2)
                    
                    Spacer()
                        .frame(width: 72)
                }
                Button(action: {
                    // Action for button
                }) {
                    Image("Notebook")
                        .renderingMode(.template)
                        .foregroundColor(photoCount >= 2 ? .white : .gray)
                }
            }
            .zIndex(1)
            .padding(.bottom, -10)
        }
        .frame(maxHeight: .infinity, alignment: .bottom)
        .animation(.easeInOut(duration: 0.3), value: isVisible && tappedImageUrl == nil)
        .opacity(isVisible && tappedImageUrl == nil ? 1 : 0) // Hide when an image is tapped
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
                        print("Fetched image URL: \(url) with caption: \(caption) and timestamp: \(timestamp.dateValue())")
                        return (url, caption, timestamp)
                    }
                    return nil
                }
                self.imageUrls.sort { $0.2.dateValue() > $1.2.dateValue() }
                
                if self.imageUrls.isEmpty {
                    print("No photos found.")
                } else {
                    print("Photos found: \(self.imageUrls)")
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
