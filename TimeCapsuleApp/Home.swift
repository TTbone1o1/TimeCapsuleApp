import SwiftUI
import Firebase
import FirebaseAuth
import FirebaseFirestore
import FirebaseStorage

struct Home: View {
    @State private var username: String = ""
    @State private var imagesAppeared = false
    @State private var hasPostedPhoto = false
    @State private var imageUrls: [String] = []
    @State private var photoCount: Int = 0
    @State private var isShowingMessage = false

    var body: some View {
        GeometryReader { geometry in
            let safeArea = geometry.safeAreaInsets
            
            NavigationView {
                ZStack {
                    VStack {
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
                        
                        Spacer()

                        if !hasPostedPhoto {
                            Text("Take a photo to start")
                                .font(.system(size: 18))
                                .padding(.bottom, 30)
                                .fontWeight(.bold)
                            
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
                            Spacer()
                        } else {
                            ScrollView {
                                VStack(spacing: 45) {
                                    ForEach(imageUrls, id: \.self) { imageUrl in
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
                                                .shadow(radius: 20, x: 0, y: 24) // Apply the shadow here
                                        } placeholder: {
                                            ProgressView()
                                        }
                                        .frame(maxWidth: .infinity) // Ensure the image is centered and takes up full width
                                        .padding(.horizontal, (UIScreen.main.bounds.width - 313) / 2) // Adjust padding to ensure the image is centered
                                    }
                                }
                                .padding(.vertical, 20) // Optional: Add vertical padding for spacing between images
                            }
                            .ignoresSafeArea(edges: [.leading, .trailing]) // Ignore safe area on left and right sides
                            .scrollIndicators(.hidden)
                        }

                        Spacer()
                    }
                    .padding()
                    .frame(maxHeight: .infinity)
                    .onAppear {
                        fetchUsername()
                        checkIfUserHasPosted()
                        imagesAppeared = true
                        triggerHaptic()
                    }
                    .onDisappear {
                        imagesAppeared = false
                    }
                    
                    // Floating HStack at the bottom
                    ZStack {
                        TransparentBlurView(removeAllFilters: true)
                            .blur(radius: 25)
                            .frame(height: 100 + safeArea.bottom)
                            .zIndex(1)
                            .offset(y: 400)
                        HStack {
                            NavigationLink(destination: CameraController()
                                .edgesIgnoringSafeArea(.all)
                            ) {
                                ZStack {
                                    Circle()
                                        .stroke(photoCount >= 2 ? Color.white : Color.gray, lineWidth: 3)
                                        .frame(width: 24, height: 24)
                                    
                                    Circle()
                                        .frame(width: 13, height: 13)
                                        .foregroundColor(photoCount >= 2 ? .white : .gray)
                                }
                                .opacity(photoCount >= 2 ? 0.4 : 0.2) // Set opacity to 40%
                                
                                Spacer()
                                    .frame(width: 72)
                            }
                            Button(action: {
                                // Action for button
                            }) {
                                Image("Notebook")
                                    .renderingMode(.template) // Use template rendering mode to apply color
                                    .foregroundColor(photoCount >= 2 ? .white : .gray) // Set the color of the image
                            }
                        }
                        .zIndex(1) // Ensure the HStack is above the scrollable content
                        .padding(.bottom, 50) // Adjust padding to place it correctly at the bottom
                    }
                    .frame(maxHeight: .infinity, alignment: .bottom)
                }
                .edgesIgnoringSafeArea(.bottom)
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
    
    private func checkIfUserHasPosted() {
        guard let user = Auth.auth().currentUser else { return }
        let db = Firestore.firestore()
        let photosCollectionRef = db.collection("users").document(user.uid).collection("photos")
        
        photosCollectionRef.getDocuments { snapshot, error in
            if let snapshot = snapshot {
                let today = Calendar.current.startOfDay(for: Date())
                let postedToday = snapshot.documents.contains { document in
                    if let timestamp = document.data()["timestamp"] as? Timestamp {
                        let photoDate = Calendar.current.startOfDay(for: timestamp.dateValue())
                        return photoDate == today
                    }
                    return false
                }
                
                self.hasPostedPhoto = postedToday
                if self.hasPostedPhoto {
                    self.fetchImageUrls()
                }
                
                // Show the message button if user has posted today
                self.isShowingMessage = postedToday
            } else {
                print("Error fetching photos: \(error?.localizedDescription ?? "Unknown error")")
                self.hasPostedPhoto = false
            }
        }
    }
    
    private func fetchImageUrls() {
        guard let user = Auth.auth().currentUser else { return }
        let db = Firestore.firestore()
        let photosCollectionRef = db.collection("users").document(user.uid).collection("photos")
        
        photosCollectionRef.getDocuments { snapshot, error in
            if let snapshot = snapshot {
                self.photoCount = snapshot.count
                self.imageUrls = snapshot.documents.compactMap { document in
                    let data = document.data()
                    if let url = data["photoURL"] as? String {
                        print("Fetched image URL: \(url)") // Debug log
                        return url
                    }
                    return nil
                }
            } else {
                print("Error fetching image URLs: \(error?.localizedDescription ?? "Unknown error")")
            }
        }
    }
    
    private func triggerHaptic() {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
    }
}

struct Home_Previews: PreviewProvider {
    static var previews: some View {
        Home()
    }
}
