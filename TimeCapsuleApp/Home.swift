import SwiftUI
import Firebase
import FirebaseAuth
import FirebaseFirestore
import FirebaseStorage

struct Home: View {
    @State private var username: String = ""
    @State private var imagesAppeared = false
    @State private var hasPostedPhoto = false
    @State private var imageUrls: [(String, String, Timestamp)] = [] // Updated to store (URL, Caption, Timestamp) tuples
    @State private var photoCount: Int = 0
    @State private var isShowingMessage = false
    @State private var selectedImageUrl: String? = nil
    @State private var selectedImageCaption: String = ""
    @State private var selectedImageTimestamp: Timestamp? = nil
    @State private var isCaptionVisible: Bool = false

    var body: some View {
        GeometryReader { geometry in
            let safeArea = geometry.safeAreaInsets
            
            NavigationView {
                ZStack {
                    VStack {
                        header
                        content
                        Spacer()
                    }
                    .padding()
                    .frame(maxHeight: .infinity)
                    .onAppear(perform: onAppearLogic)
                    .onDisappear {
                        imagesAppeared = false
                    }
                    
                    // Fullscreen image view, placed above other content
                    if let selectedImageUrl = selectedImageUrl {
                        ZStack {
                            AsyncImage(url: URL(string: selectedImageUrl)) { image in
                                image
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
                                    .edgesIgnoringSafeArea(.all) // Cover the entire screen
                                    .onTapGesture {
                                        self.selectedImageUrl = nil
                                        self.selectedImageCaption = ""
                                        self.selectedImageTimestamp = nil
                                        self.isCaptionVisible = false
                                    }
                            } placeholder: {
                                ProgressView()
                            }
                            .zIndex(3) // Highest zIndex to ensure it is on top of everything
                        }
                        .onAppear {
                            withAnimation(.easeInOut(duration: 0.3)) {
                                self.isCaptionVisible = true
                            }
                        }
                    }

                    // Transparent color for tapping to dismiss
                    if selectedImageUrl != nil {
                        Color.clear
                            .edgesIgnoringSafeArea(.all)
                            .onTapGesture {
                                self.selectedImageUrl = nil
                                self.selectedImageCaption = ""
                                self.selectedImageTimestamp = nil
                                self.isCaptionVisible = false
                            }
                            .zIndex(2) // Ensure this view is below the fullscreen image view but above other content
                    }

                    floatingFooter(safeArea: safeArea, isVisible: selectedImageUrl == nil) // Pass visibility state
                        .zIndex(1) // Ensure this view is below the fullscreen image view and overlay
                    
                    // Caption view
                    if selectedImageUrl != nil {
                        VStack {
                            Spacer()
                            HStack {
                                VStack(alignment: .leading, spacing: 5) {
                                    Text(formatDate(selectedImageTimestamp?.dateValue() ?? Date()))
                                        .font(.system(size: 18))
                                        .foregroundColor(.white)
                                        .padding(.horizontal, 28)
                                        .frame(width: 348, height: 30, alignment: .leading)
                                    Text(shortenCaption(selectedImageCaption))
                                        .font(.system(size: 24))
                                        .padding(.horizontal, 28)
                                        .frame(width: 348, height: 70, alignment: .leading)
                                        .foregroundColor(.white)
                                        .cornerRadius(5)
                                        .padding(.bottom, 16)
                                }
                                .padding(.bottom, 53) // Pacing from the bottom
                                .opacity(isCaptionVisible ? 1 : 0) // Fade in/out based on visibility
                                .animation(.easeInOut(duration: 0.3), value: isCaptionVisible) // Smooth transition for visibility change
                            }
                            .padding(.horizontal)
                        }
                        .zIndex(1) // Ensure this view is above other content
                    }
                }
                .edgesIgnoringSafeArea(.bottom)
            }
        }
    }
    
    private var header: some View {
        HStack {
            Text(username.isEmpty ? "" : username)
                .font(.system(size: 18))
                .fontWeight(.bold)
                .padding()
            
            Spacer()
            
            Button(action: {
                // Action for button
            }) {
                VStack(spacing: 2) {
                    ForEach(0..<3) { _ in
                        Rectangle()
                            .frame(width: 16, height: 3)
                            .cornerRadius(20)
                            .foregroundColor(.black)
                    }
                }
                .padding(.trailing)
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
        ZStack {
            // Main content (image gallery)
            ScrollView {
                VStack(spacing: 45) {
                    ForEach(imageUrls, id: \.0) { imageUrl, caption, timestamp in
                        ZStack(alignment: .bottom) {
                            AsyncImage(url: URL(string: imageUrl)) { image in
                                image
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(width: 313, height: 421) // Fixed width
                                    .cornerRadius(33)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 33)
                                            .stroke(Color.clear, lineWidth: 0) // Overlay to maintain corner radius
                                    )
                                    .shadow(radius: 20, x: 0, y: 24)
                                    .onTapGesture {
                                        if selectedImageUrl == imageUrl {
                                            // Deselect image if tapped again
                                            selectedImageUrl = nil
                                            selectedImageCaption = ""
                                            selectedImageTimestamp = nil
                                            isCaptionVisible = false
                                        } else {
                                            // Select new image
                                            selectedImageUrl = imageUrl
                                            selectedImageCaption = caption
                                            selectedImageTimestamp = timestamp
                                            isCaptionVisible = true
                                        }
                                    }
                            } placeholder: {
                                ProgressView()
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.horizontal, (UIScreen.main.bounds.width - 313) / 2)
                            
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
    
    private func floatingFooter(safeArea: EdgeInsets, isVisible: Bool) -> some View {
        ZStack {
            TransparentBlurView(removeAllFilters: true)
                .blur(radius: 10)
                .frame(height: 100 + safeArea.bottom)
                .zIndex(1) // Lower zIndex to be behind other views
                .offset(y: 35)
                .opacity(isVisible ? 1 : 0) // Control visibility based on isVisible
            
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
            .zIndex(1) // Same zIndex as the footer, ensuring the footer is always beneath
            .padding(.bottom, -10)
        }
        .frame(maxHeight: .infinity, alignment: .bottom)
        .animation(.easeInOut(duration: 0.3), value: isVisible) // Smooth transition for visibility change
        .opacity(isVisible ? 1 : 0)
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
                        print("Fetched image URL: \(url) with caption: \(caption) and timestamp: \(timestamp.dateValue())") // Debug log
                        return (url, caption, timestamp)
                    }
                    return nil
                }
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
        formatter.dateFormat = "MMM d" // Format for "Aug 12"
        return formatter.string(from: date)
    }

    private func triggerHaptic() {
        // Trigger haptic feedback (optional)
    }

    private func handleImageTap(imageUrl: String) {
        print("Image tapped: \(imageUrl)")
        // Add any other logic here
    }
}

struct Home_Previews: PreviewProvider {
    static var previews: some View {
        Home()
    }
}
