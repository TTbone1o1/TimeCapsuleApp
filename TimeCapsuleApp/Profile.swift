import SwiftUI
import Firebase
import FirebaseStorage
import FirebaseFirestore
import FirebaseAuth

struct Profile: View {
    @Binding var isImageExpanded: Bool // Binding to control the state from Home
    @State private var currentDate = Date()
    @State private var selectedDate = Date()
    @State private var displayedMonth = Calendar.current.component(.month, from: Date())
    @State private var displayedYear = Calendar.current.component(.year, from: Date())
    @State private var isShowingSetting = false
    @State private var isSignedOut = false
    @Environment(\.presentationMode) var presentationMode
    @State private var navigateToTimeCap = false
    @State private var selectedImage: UIImage? = nil
    @State private var showingImagePicker = false
    @State private var isLoading = true
    @State private var username: String = ""
    @State private var photos: [(String, String, Timestamp)] = [] // Store (URL, Caption, Timestamp) tuples
    @State private var photosForSelectedDate: [(String, String, Timestamp)] = [] // Filtered photos for the selected date
    
    //@State private var isImageExpanded = false
    @State private var tappedImageUrl: String? = nil // To track the tapped image URL

    @Namespace private var namespace

    private var userID: String {
        return Auth.auth().currentUser?.uid ?? ""
    }

    var body: some View {
        ZStack {
            GeometryReader { geometry in
                VStack {
                    Spacer()
                        .frame(height: 128)

                    ZStack {
                        Circle()
                            .stroke(Color(.systemGray6), lineWidth: 6)
                            .frame(width: 148, height: 148)

                        if isLoading {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle())
                                .frame(width: 125, height: 125)
                                .scaleEffect(isShowingSetting ? 1.1 : 1.0)
                                .animation(.interpolatingSpring(stiffness: 170, damping: 5).repeatCount(1, autoreverses: true), value: isShowingSetting)
                        } else if let image = selectedImage {
                            Image(uiImage: image)
                                .resizable()
                                .clipShape(Circle())
                                .frame(width: 125, height: 125)
                                .scaleEffect(isShowingSetting ? 1.1 : 1.0)
                                .animation(.interpolatingSpring(stiffness: 170, damping: 5).repeatCount(1, autoreverses: true), value: isShowingSetting)
                        } else {
                            Circle()
                                .foregroundColor(.black)
                                .frame(width: 125, height: 125)
                                .scaleEffect(isShowingSetting ? 1.1 : 1.0)
                                .animation(.interpolatingSpring(stiffness: 170, damping: 5).repeatCount(1, autoreverses: true), value: isShowingSetting)
                        }
                    }
                    .onTapGesture {
                        withAnimation {
                            isShowingSetting.toggle()
                        }
                    }

                    Spacer()
                        .frame(height: 20)
                    
                    Text(username.isEmpty ? "Loading..." : username)
                        .font(.system(size: 32, weight: .bold, design: .rounded))
                        .fontWeight(.bold)
                        .padding(.leading)
                        .foregroundColor(Color.primary)

                    CalendarView(currentDate: $currentDate, selectedDate: $selectedDate, displayedMonth: $displayedMonth, displayedYear: $displayedYear, photosForSelectedDate: $photosForSelectedDate, tappedImageUrl: $tappedImageUrl, filterPhotos: filterPhotosForSelectedDate)

                    Spacer()
                }
                .edgesIgnoringSafeArea(.top)
            }

            if let tappedImageUrl = tappedImageUrl {
                ZStack {
                    AsyncImage(url: URL(string: tappedImageUrl)) { phase in
                        switch phase {
                        case .empty:
                            ProgressView()
                        case .success(let image):
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .matchedGeometryEffect(id: tappedImageUrl, in: namespace)
                                .frame(width: isImageExpanded ? UIScreen.main.bounds.width : 0,
                                       height: isImageExpanded ? UIScreen.main.bounds.height : 0)
                                .cornerRadius(isImageExpanded ? 33 : 33)
                                .transition(.scale)
                                .onTapGesture {
                                    withAnimation(.spring(response: 0.4, dampingFraction: 0.7, blendDuration: 0.4)) {
                                        isImageExpanded.toggle()
                                    }

                                    // Delay the dismissal of the image to allow the scale-down animation
                                    if !isImageExpanded {
                                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                            self.tappedImageUrl = nil
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
                    .frame(maxWidth: isImageExpanded ? UIScreen.main.bounds.width : 0,
                           maxHeight: isImageExpanded ? UIScreen.main.bounds.height : 0)
                    .animation(.spring(response: 0.6, dampingFraction: 0.6, blendDuration: 0.6))
                }
                .zIndex(2)
            }

            if isShowingSetting {
                Setting(isShowing: $isShowingSetting, isSignedOut: $isSignedOut, onChangeProfilePicture: {
                    self.showingImagePicker = true
                })
                .transition(.move(edge: .bottom))
                .animation(.easeInOut)
                .zIndex(1)
            }

            if navigateToTimeCap {
                Timecap()
                    .transition(.opacity)
                    .zIndex(1)
            }

        }
        .onChange(of: isSignedOut) { signedOut in
            if signedOut {
                navigateToTimeCap = true
            }
        }
        .onAppear {
            fetchProfileData()
            fetchAllPhotos()
        }
        .sheet(isPresented: $showingImagePicker) {
            ImagePicker(image: $selectedImage) {
                self.showingImagePicker = false
                uploadProfileImage()
            }
        }
    }

    private func fetchProfileData() {
        if selectedImage == nil {
            loadProfileImage()
        }
        fetchUsername()
    }

    private func uploadProfileImage() {
        guard let image = selectedImage, let imageData = image.jpegData(compressionQuality: 0.75) else { return }
        let storageRef = Storage.storage().reference().child("users/\(userID)/profileimage.jpg")

        // Upload image to Firebase Storage
        let uploadTask = storageRef.putData(imageData, metadata: nil) { metadata, error in
            guard metadata != nil else {
                print("Error uploading image: \(String(describing: error?.localizedDescription))")
                return
            }
            // Get download URL
            storageRef.downloadURL { url, error in
                guard let downloadURL = url else {
                    print("Error getting download URL: \(String(describing: error?.localizedDescription))")
                    return
                }
                saveProfileImageURL(url: downloadURL.absoluteString)
            }
        }
    }

    private func saveProfileImageURL(url: String) {
        let db = Firestore.firestore()
        let userRef = db.collection("users").document(userID)
        userRef.setData(["profileImageURL": url], merge: true) { error in
            if let error = error {
                print("Error saving profile image URL: \(error.localizedDescription)")
            } else {
                print("Profile image URL saved successfully")
            }
        }
    }

    private func loadProfileImage() {
        let db = Firestore.firestore()
        let userRef = db.collection("users").document(userID)
        userRef.getDocument { document, error in
            if let document = document, document.exists {
                if let urlString = document.data()?["profileImageURL"] as? String, let url = URL(string: urlString) {
                    downloadProfileImage(from: url)
                } else {
                    // Reset to default image if no URL is available
                    self.selectedImage = nil
                    self.isLoading = false
                }
            } else {
                print("Document does not exist")
                // Reset to default image if document doesn't exist
                self.selectedImage = nil
                self.isLoading = false
            }
        }
    }

    private func downloadProfileImage(from url: URL) {
        let storageRef = Storage.storage().reference(forURL: url.absoluteString)
        storageRef.getData(maxSize: 1 * 1024 * 1024) { data, error in
            if let error = error {
                print("Error downloading image: \(error.localizedDescription)")
                // Reset to default image in case of error
                self.selectedImage = nil
            } else if let data = data {
                DispatchQueue.main.async {
                    self.selectedImage = UIImage(data: data)
                    self.isLoading = false
                }
            }
        }
    }
    
    private func fetchUsername() {
        guard let user = Auth.auth().currentUser else { return }
        let db = Firestore.firestore()
        let usernameDocRef = db.collection("users").document(user.uid).collection("username").document("info")
        usernameDocRef.getDocument { document, error in
            if let document = document, document.exists {
                let fetchedUsername = document.data()?["username"] as? String
                DispatchQueue.main.async {
                    self.username = fetchedUsername ?? "No Username"
                }
            } else {
                print("Username not found in Firestore")
                DispatchQueue.main.async {
                    self.username = "No Username"
                }
            }
        }
    }

    private func fetchAllPhotos() {
        guard let user = Auth.auth().currentUser else { return }
        let db = Firestore.firestore()
        let photosCollectionRef = db.collection("users").document(user.uid).collection("photos")

        photosCollectionRef.getDocuments { snapshot, error in
            if let snapshot = snapshot {
                self.photos = snapshot.documents.compactMap { document in
                    let data = document.data()
                    if let url = data["photoURL"] as? String,
                       let caption = data["caption"] as? String,
                       let timestamp = data["timestamp"] as? Timestamp {
                        return (url, caption, timestamp)
                    }
                    return nil
                }
            } else {
                print("Error fetching image URLs: \(error?.localizedDescription ?? "Unknown error")")
            }
        }
    }

    private func filterPhotosForSelectedDate(selectedDate: Date) {
        let calendar = Calendar.current
        photosForSelectedDate = photos.filter { photo in
            let photoDate = photo.2.dateValue() // Convert timestamp to Date
            return calendar.isDate(photoDate, inSameDayAs: selectedDate)
        }
        
        // Automatically expand the first image when a date is selected
        if let firstPhoto = photosForSelectedDate.first {
            tappedImageUrl = firstPhoto.0
            isImageExpanded = true
        }
    }

    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d"
        return formatter.string(from: date)
    }

    private func shortenCaption(_ caption: String) -> String {
        let words = caption.split(separator: " ")
        let limitedWords = words.prefix(8)
        let shortCaption = limitedWords.joined(separator: " ")
        return shortCaption
    }
}

struct CalendarView: View {
    @Binding var currentDate: Date
    @Binding var selectedDate: Date
    @Binding var displayedMonth: Int
    @Binding var displayedYear: Int
    @Binding var photosForSelectedDate: [(String, String, Timestamp)]
    @Binding var tappedImageUrl: String?
    var filterPhotos: (Date) -> Void

    let calendar = Calendar.current
    let dateFormatter = DateFormatter()
    let yearFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .none
        return formatter
    }()

    var body: some View {
        
        Spacer()
        
        VStack {
            HStack {
                Button(action: {
                    changeMonth(by: -1)
                }) {
                    Image(systemName: "arrow.left")
                        .foregroundColor(.black)
                }

                Spacer()

                Text("\(monthName(for: displayedMonth)) \(formattedYear)")
                    .font(.system(size: 24, weight: .bold, design: .rounded))
                    .foregroundColor(.black)

                Spacer()

                Button(action: {
                    changeMonth(by: 1)
                }) {
                    Image(systemName: "arrow.right")
                        .foregroundColor(.black)
                }
            }
            .padding(.horizontal)

            let daysInMonth = calendar.range(of: .day, in: .month, for: firstOfMonth())!.count
            let firstWeekday = calendar.component(.weekday, from: firstOfMonth())
            let columns = Array(repeating: GridItem(.flexible()), count: 7)

            LazyVGrid(columns: columns, spacing: 10) {
                ForEach((0..<daysInMonth + firstWeekday - 1).filter { $0 >= firstWeekday - 1 }, id: \.self) { i in
                    let day = i - firstWeekday + 2
                    Text("\(day)")
                        .font(.system(size: 24, weight: .bold, design: .rounded))
                        .foregroundColor(colorForDay(day))
                        .onTapGesture {
                            selectDay(day)
                        }
                }
            }
        }
    }

    private func firstOfMonth() -> Date {
        let components = DateComponents(year: displayedYear, month: displayedMonth)
        return calendar.date(from: components)!
    }

    private func monthName(for month: Int) -> String {
        dateFormatter.dateFormat = "MMMM"
        return dateFormatter.monthSymbols[month - 1]
    }

    private func changeMonth(by value: Int) {
        if let newDate = calendar.date(byAdding: .month, value: value, to: firstOfMonth()) {
            displayedMonth = calendar.component(.month, from: newDate)
            displayedYear = calendar.component(.year, from: newDate)
        }
    }

    private func isCurrentMonth() -> Bool {
        let today = Date()
        return calendar.component(.month, from: today) == displayedMonth &&
               calendar.component(.year, from: today) == displayedYear
    }

    private func colorForDay(_ day: Int) -> Color {
        let today = Date()
        let currentDay = calendar.component(.day, from: today)
        
        if isCurrentMonth() && day == currentDay {
            return .black
        } else if calendar.component(.day, from: selectedDate) == day &&
                  calendar.component(.month, from: selectedDate) == displayedMonth &&
                  calendar.component(.year, from: selectedDate) == displayedYear {
            return .blue
        } else {
            return .gray
        }
    }

    private func selectDay(_ day: Int) {
        let dateComponents = DateComponents(year: displayedYear, month: displayedMonth, day: day)
        if let date = calendar.date(from: dateComponents) {
            selectedDate = date
            
            // Filter photos based on the selected date
            filterPhotos(selectedDate)
        }
    }
    
    private var formattedYear: String {
        return yearFormatter.string(from: NSNumber(value: displayedYear)) ?? "\(displayedYear)"
    }
}
