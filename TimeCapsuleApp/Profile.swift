import AVKit
import Firebase
import FirebaseAuth
import FirebaseFirestore
import FirebaseStorage
import SwiftUI

struct Profile: View {
    @Binding var isImageExpanded: Bool
    @Binding var isShowingSetting: Bool
    @Binding var selectedImage: UIImage?
    @Binding var homeProfileScale: CGFloat

    @State private var currentDate = Date()
    @State private var selectedDate = Date()
    @State private var displayedMonth = Calendar.current.component(
        .month,
        from: Date()
    )
    @State private var displayedYear = Calendar.current.component(
        .year,
        from: Date()
    )
    @State private var isSignedOut = false
    @Environment(\.presentationMode) var presentationMode
    @State private var navigateToTimeCap = false
    @State private var showingImagePicker = false
    @State private var username: String = ""
    @State private var media: [(String, String, Timestamp, String)] = []  // Store (URL, Caption, Timestamp, Type: "photo"/"video")
    @State private var mediaForSelectedDate:
        [(String, String, Timestamp, String)] = []  // Filtered media (photos/videos) for the selected date
    @State private var tappedMediaUrl: String? = nil  // To track the tapped media URL
    @Namespace private var namespace

    @State private var isFadingOut: Bool = false  // New state for managing opacity

    private var userID: String {
        return Auth.auth().currentUser?.uid ?? ""
    }

    var body: some View {
        ZStack {
            GeometryReader { geometry in
                VStack {
                    // Dynamically calculated space for the top section
                    Spacer().frame(height: geometry.size.height * 0.15)

                    ZStack {
                        Circle()
                            .stroke(Color(.systemGray6), lineWidth: 6)
                            .frame(width: 148, height: 148)

                        if let image = selectedImage {
                            Image(uiImage: image)
                                .resizable()
                                .scaledToFill()
                                .clipShape(Circle())
                                .frame(width: 125, height: 125)
                                .scaleEffect(isShowingSetting ? 0.8 : 1.0)
                                .animation(
                                    .interpolatingSpring(
                                        stiffness: 130,
                                        damping: 6
                                    ),
                                    value: isShowingSetting
                                )
                        } else {
                            Image(systemName: "person.crop.circle.fill")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 125, height: 125)
                                .foregroundColor(.gray)
                                .scaleEffect(isShowingSetting ? 0.8 : 1.0)
                                .animation(
                                    .interpolatingSpring(
                                        stiffness: 130,
                                        damping: 5
                                    ),
                                    value: isShowingSetting
                                )
                        }
                    }
                    .gesture(
                        LongPressGesture(minimumDuration: 0.5)
                            .onEnded { _ in
                                withAnimation {
                                    let impactFeedback =
                                        UIImpactFeedbackGenerator(
                                            style: .medium
                                        )
                                    impactFeedback.impactOccurred()
                                    isShowingSetting = true

                                    withAnimation(.easeInOut(duration: 0.2)) {
                                        homeProfileScale = 0.0
                                    }
                                }
                            }
                    )

                    Spacer().frame(height: 20)

                    Text(username.isEmpty ? "Loading..." : username)
                        .font(
                            .system(size: 32, weight: .bold, design: .rounded)
                        )
                        .fontWeight(.bold)
                        .foregroundColor(Color.primary)
                        .frame(maxWidth: .infinity)
                        .multilineTextAlignment(.center)

                    CalendarView(
                        currentDate: $currentDate,
                        selectedDate: $selectedDate,
                        displayedMonth: $displayedMonth,
                        displayedYear: $displayedYear,
                        mediaForSelectedDate: $mediaForSelectedDate,
                        tappedMediaUrl: $tappedMediaUrl,
                        filterMedia: filterMediaForSelectedDate,
                        media: media  // Pass the media array here
                    )
                    .frame(maxHeight: geometry.size.height * 0.5)  // Limit the height of the calendar to avoid cutoff issues
                    .offset(y: -230)
                    Spacer()
                }
                .edgesIgnoringSafeArea(.top)
            }

            if let tappedMediaUrl = tappedMediaUrl {
                ZStack {
                    // Replace the video player ZStack section (around line 115) with this:

                    if let mediaType = mediaForSelectedDate.first(where: {
                        $0.0 == tappedMediaUrl
                    })?.3, mediaType == "video" {
                        CustomVideoPlayerView(
                            videoURL: URL(string: tappedMediaUrl)!
                        )
                        .matchedGeometryEffect(
                            id: tappedMediaUrl,
                            in: namespace
                        )
                        .frame(
                            width: isImageExpanded
                                ? UIScreen.main.bounds.width : 0,
                            height: isImageExpanded
                                ? UIScreen.main.bounds.height : 0
                        )
                        .cornerRadius(isImageExpanded ? 33 : 33)
                        .opacity(isImageExpanded ? 1 : isFadingOut ? 0 : 1)
                        .scaleEffect(isImageExpanded ? 1 : 0.001)
                        .animation(
                            .spring(
                                response: 0.6,
                                dampingFraction: 0.75,
                                blendDuration: 0.6
                            ),
                            value: isImageExpanded
                        )
                        .transition(
                            isImageExpanded
                                ? .scale
                                : .asymmetric(
                                    insertion: .scale,
                                    removal: .opacity
                                )
                        )
                        .onTapGesture {
                            let impactFeedback = UIImpactFeedbackGenerator(
                                style: .medium
                            )
                            impactFeedback.impactOccurred()

                            if isImageExpanded {
                                withAnimation(
                                    .spring(
                                        response: 0.5,
                                        dampingFraction: 0.9,
                                        blendDuration: 0.4
                                    )
                                ) {
                                    isImageExpanded.toggle()
                                    isFadingOut = true
                                }

                                DispatchQueue.main.asyncAfter(
                                    deadline: .now() + 0.4
                                ) {
                                    self.tappedMediaUrl = nil
                                    withAnimation(.easeInOut(duration: 0.15)) {
                                        homeProfileScale = 1.0
                                    }
                                }

                            } else {
                                withAnimation(
                                    .spring(
                                        response: 0.5,
                                        dampingFraction: 0.85,
                                        blendDuration: 0.4
                                    )
                                ) {
                                    isImageExpanded.toggle()
                                    isFadingOut = false
                                }
                            }
                        }
                    } else {
                        AsyncImage(url: URL(string: tappedMediaUrl)) { phase in
                            switch phase {
                            case .success(let image):
                                image
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .matchedGeometryEffect(
                                        id: tappedMediaUrl,
                                        in: namespace
                                    )
                                    .frame(
                                        width: isImageExpanded
                                            ? UIScreen.main.bounds.width : 0,
                                        height: isImageExpanded
                                            ? UIScreen.main.bounds.height : 0
                                    )
                                    .cornerRadius(isImageExpanded ? 33 : 33)
                                    .opacity(
                                        isImageExpanded
                                            ? 1 : isFadingOut ? 0 : 1
                                    )
                                    .transition(
                                        isImageExpanded
                                            ? .scale
                                            : .asymmetric(
                                                insertion: .scale,
                                                removal: .opacity
                                            )
                                    )
                                    .onTapGesture {
                                        let impactFeedback =
                                            UIImpactFeedbackGenerator(
                                                style: .medium
                                            )
                                        impactFeedback.impactOccurred()

                                        if isImageExpanded {
                                            withAnimation(
                                                .spring(
                                                    response: 0.5,
                                                    dampingFraction: 0.9,
                                                    blendDuration: 0.4
                                                )
                                            ) {
                                                isImageExpanded.toggle()
                                                isFadingOut = true
                                            }

                                            DispatchQueue.main.asyncAfter(
                                                deadline: .now() + 0.4
                                            ) {
                                                self.tappedMediaUrl = nil
                                                withAnimation(
                                                    .easeInOut(duration: 0.15)
                                                ) {
                                                    homeProfileScale = 1.0
                                                }
                                            }

                                        } else {
                                            withAnimation(
                                                .spring(
                                                    response: 0.5,
                                                    dampingFraction: 0.85,
                                                    blendDuration: 0.4
                                                )
                                            ) {
                                                isImageExpanded.toggle()
                                                isFadingOut = false
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
                        .frame(
                            maxWidth: isImageExpanded
                                ? UIScreen.main.bounds.width : 0,
                            maxHeight: isImageExpanded
                                ? UIScreen.main.bounds.height : 0
                        )
                        .animation(
                            .spring(
                                response: 0.6,
                                dampingFraction: 0.75,
                                blendDuration: 0.6
                            )
                        )
                    }
                }
                .zIndex(2)
            }

            if isShowingSetting {
                Setting(
                    isShowing: $isShowingSetting,
                    isSignedOut: $isSignedOut,
                    onChangeProfilePicture: {
                        self.showingImagePicker = true
                    }
                )
                .zIndex(1)
            }

            if navigateToTimeCap {
                Timecap()
                    .transition(.opacity)
                    .zIndex(1)
            }

        }
        .onChange(of: isShowingSetting) { isShowing in
            withAnimation(.easeInOut(duration: 0.2)) {
                if !isShowing {
                    homeProfileScale = 1.0
                }
            }
        }
        .onAppear {
            fetchProfileData()
            fetchAllMedia()  // Fetch both photos and videos
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
        guard let image = selectedImage,
              let imageData = image.jpegData(compressionQuality: 0.75) else {
            print("uploadProfileImage: selectedImage is nil")
            return
        }

        guard !userID.isEmpty else {
            print("uploadProfileImage: userID is empty (user not logged in?)")
            return
        }

        let storageRef = Storage.storage().reference().child(
            "users/\(userID)/profileimage.jpg"
        )

        storageRef.putData(imageData, metadata: nil) { _, error in
            if let error = error {
                print("Error uploading image: \(error.localizedDescription)")
                return
            }
            storageRef.downloadURL { url, error in
                if let error = error {
                    print("Error getting download URL: \(error.localizedDescription)")
                    return
                }
                guard let downloadURL = url else { return }
                self.saveProfileImageURL(url: downloadURL.absoluteString)
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
                // ✅ Reload from Firestore URL
                self.loadProfileImage()
            }
        }
    }


    private func loadProfileImage() {
        let db = Firestore.firestore()
        let userRef = db.collection("users").document(userID)
        userRef.getDocument { document, error in
            if let error = error {
                print("Error fetching profile doc: \(error.localizedDescription)")
                return
            }

            guard let document = document, document.exists else {
                print("Profile document does not exist")
                return  // ✅ don't nil out selectedImage
            }

            guard let urlString = document.data()?["profileImageURL"] as? String,
                  let url = URL(string: urlString) else {
                print("No profileImageURL field on user")
                return  // ✅ keep existing image
            }

            self.downloadProfileImage(from: url)
        }
    }


    private func downloadProfileImage(from url: URL) {
        let storageRef = Storage.storage().reference(forURL: url.absoluteString)
        storageRef.getData(maxSize: Int64(5 * 1024 * 1024)) { data, error in
            if let error = error {
                print("Error downloading image: \(error.localizedDescription)")
                return
            }
            if let data = data, let image = UIImage(data: data) {
                DispatchQueue.main.async {
                    self.selectedImage = image
                }
            }
        }
    }



    private func fetchUsername() {
        guard let user = Auth.auth().currentUser else { return }
        let db = Firestore.firestore()
        let usernameDocRef = db.collection("users").document(user.uid)
            .collection("username").document("info")
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

    private func fetchAllMedia() {
        guard let user = Auth.auth().currentUser else { return }
        let db = Firestore.firestore()

        let photosCollectionRef = db.collection("users").document(user.uid)
            .collection("photos")
        let videosCollectionRef = db.collection("users").document(user.uid)
            .collection("videos")

        photosCollectionRef.getDocuments { photoSnapshot, error in
            if let photoSnapshot = photoSnapshot {
                let photoUrls = photoSnapshot.documents.compactMap { document in
                    let data = document.data()
                    if let url = data["photoURL"] as? String,
                        let caption = data["caption"] as? String,
                        let timestamp = data["timestamp"] as? Timestamp
                    {
                        return (url, caption, timestamp, "photo")
                    }
                    return nil
                }

                videosCollectionRef.getDocuments { videoSnapshot, error in
                    if let videoSnapshot = videoSnapshot {
                        let videoUrls = videoSnapshot.documents.compactMap {
                            document in
                            let data = document.data()
                            if let url = data["videoURL"] as? String,
                                let caption = data["caption"] as? String,
                                let timestamp = data["timestamp"] as? Timestamp
                            {
                                return (url, caption, timestamp, "video")
                            }
                            return nil
                        }

                        self.media = (photoUrls + videoUrls).sorted {
                            $0.2.dateValue() > $1.2.dateValue()
                        }
                    }
                }
            }
        }
    }

    // Replace the filterMediaForSelectedDate function (around line 390) with this:

    private func filterMediaForSelectedDate(selectedDate: Date) {
        let calendar = Calendar.current
        mediaForSelectedDate = media.filter { mediaItem in
            let mediaDate = mediaItem.2.dateValue()
            return calendar.isDate(mediaDate, inSameDayAs: selectedDate)
        }

        if let firstMedia = mediaForSelectedDate.first {
            tappedMediaUrl = firstMedia.0

            // Important: Start with isImageExpanded = false, then animate to true
            isImageExpanded = false
            isFadingOut = false

            withAnimation(.easeInOut(duration: 0.1)) {
                homeProfileScale = 0.0
            }

            // Delay the expansion animation so it starts from scale 0
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                withAnimation(
                    .spring(
                        response: 0.5,
                        dampingFraction: 0.85,
                        blendDuration: 0.4
                    )
                ) {
                    isImageExpanded = true
                }
            }
        }
    }
}

// Custom Video Player to play videos in a loop and hide controls
struct CustomVideoPlayerView: UIViewControllerRepresentable {
    var videoURL: URL

    func makeUIViewController(context: Context) -> AVPlayerViewController {
        let player = AVPlayer(url: videoURL)
        let controller = AVPlayerViewController()

        // Hide all playback controls
        controller.showsPlaybackControls = false
        controller.videoGravity = .resizeAspectFill
        controller.view.backgroundColor = .clear

        // Ensure video plays automatically and loops
        player.play()

        NotificationCenter.default.addObserver(
            forName: .AVPlayerItemDidPlayToEndTime,
            object: player.currentItem,
            queue: .main
        ) { _ in
            player.seek(to: .zero)
            player.play()  // Loop the video
        }

        controller.player = player
        return controller
    }

    func updateUIViewController(
        _ uiViewController: AVPlayerViewController,
        context: Context
    ) {
        // Handle updates if needed
    }
}

struct CalendarView: View {
    @Binding var currentDate: Date
    @Binding var selectedDate: Date
    @Binding var displayedMonth: Int
    @Binding var displayedYear: Int
    @Binding var mediaForSelectedDate: [(String, String, Timestamp, String)]
    @Binding var tappedMediaUrl: String?
    var filterMedia: (Date) -> Void

    @State private var isLeftButtonPressed = false
    @State private var isRightButtonPressed = false

    let media: [(String, String, Timestamp, String)]  // Photos and Videos
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
                    isLeftButtonPressed = true
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        isLeftButtonPressed = false
                    }
                }) {
                    Image(systemName: "chevron.left")
                        .foregroundColor(isLeftButtonPressed ? .black : .gray)
                        .font(.system(size: 25))
                        .padding(.leading, 20)
                        .fontWeight(.bold)
                }

                Spacer()

                Text("\(monthName(for: displayedMonth)) \(formattedYear)")
                    .font(.system(size: 24, weight: .bold, design: .rounded))
                    .foregroundColor(Color.primary)

                Spacer()

                Button(action: {
                    changeMonth(by: 1)
                    isRightButtonPressed = true
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        isRightButtonPressed = false
                    }
                }) {
                    Image(systemName: "chevron.right")
                        .foregroundColor(isRightButtonPressed ? .black : .gray)
                        .font(.system(size: 25))
                        .padding(.trailing, 20)
                        .fontWeight(.bold)
                }
            }
            .padding(.horizontal)

            let daysInMonth = calendar.range(
                of: .day,
                in: .month,
                for: firstOfMonth()
            )!.count
            let firstWeekday = calendar.component(
                .weekday,
                from: firstOfMonth()
            )
            let columns = Array(repeating: GridItem(.flexible()), count: 7)

            LazyVGrid(columns: columns, spacing: 10) {
                ForEach(
                    (0..<daysInMonth + firstWeekday - 1).filter {
                        $0 >= firstWeekday - 1
                    },
                    id: \.self
                ) { i in
                    let day = i - firstWeekday + 2
                    Text("\(day)")
                        .font(
                            .system(size: 24, weight: .bold, design: .rounded)
                        )
                        .foregroundColor(colorForDay(day))
                        .onTapGesture {
                            selectDay(day)
                        }
                }
            }
        }.padding(.horizontal, 20)
    }

    private func firstOfMonth() -> Date {
        let components = DateComponents(
            year: displayedYear,
            month: displayedMonth
        )
        return calendar.date(from: components)!
    }

    private func monthName(for month: Int) -> String {
        dateFormatter.dateFormat = "MMMM"
        return dateFormatter.monthSymbols[month - 1]
    }

    private func changeMonth(by value: Int) {
        if let newDate = calendar.date(
            byAdding: .month,
            value: value,
            to: firstOfMonth()
        ) {
            displayedMonth = calendar.component(.month, from: newDate)
            displayedYear = calendar.component(.year, from: newDate)
        }
    }

    private func isCurrentMonth() -> Bool {
        let today = Date()
        return calendar.component(.month, from: today) == displayedMonth
            && calendar.component(.year, from: today) == displayedYear
    }

    private func colorForDay(_ day: Int) -> Color {
        let today = Date()
        let currentDay = calendar.component(.day, from: today)

        if hasMediaForDay(day) {
            return Color.primary
        } else if isCurrentMonth() && day == currentDay {
            return Color.primary
        } else {
            return .gray
        }
    }

    private func hasMediaForDay(_ day: Int) -> Bool {
        let dateComponents = DateComponents(
            year: displayedYear,
            month: displayedMonth,
            day: day
        )
        if let date = calendar.date(from: dateComponents) {
            return media.contains {
                calendar.isDate($0.2.dateValue(), inSameDayAs: date)
            }
        }
        return false
    }

    private func selectDay(_ day: Int) {
        let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
        impactFeedback.impactOccurred()

        let dateComponents = DateComponents(
            year: displayedYear,
            month: displayedMonth,
            day: day
        )
        if let date = calendar.date(from: dateComponents) {
            selectedDate = date

            filterMedia(selectedDate)
        }
    }

    private var formattedYear: String {
        return yearFormatter.string(from: NSNumber(value: displayedYear))
            ?? "\(displayedYear)"
    }
}

struct Profile_Previews: PreviewProvider {
    static var previews: some View {
        Profile(
            isImageExpanded: .constant(false),
            isShowingSetting: .constant(false),
            selectedImage: .constant(nil),
            homeProfileScale: .constant(1.0)
        )
    }
}
