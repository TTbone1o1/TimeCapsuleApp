import SwiftUI
import Firebase
import FirebaseStorage
import FirebaseFirestore
import FirebaseAuth

struct Profile: View {
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
    @State private var isLoading = true // State to track loading status
    @State private var username: String = "" // State variable for username

    private var userID: String {
        return Auth.auth().currentUser?.uid ?? ""
    }

    var body: some View {
        NavigationView {
            ZStack {
                GeometryReader { geometry in
                    VStack {
                        Spacer()
                            .frame(height: 128)

                        ZStack {
                            // Outer circle with stroke
                            Circle()
                                .stroke(Color(.systemGray6), lineWidth: 6)
                                .frame(width: 148, height: 148)

                            // Inner circle with either image or placeholder
                            if isLoading {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle())
                                    .frame(width: 125, height: 125)
                            } else if let image = selectedImage {
                                Image(uiImage: image)
                                    .resizable()
                                    .clipShape(Circle())
                                    .frame(width: 125, height: 125)
                            } else {
                                Circle()
                                    .foregroundColor(.black)
                                    .frame(width: 125, height: 125)
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

                        CalendarView(currentDate: $currentDate, selectedDate: $selectedDate, displayedMonth: $displayedMonth, displayedYear: $displayedYear)

                        Spacer()
                    }
                    .edgesIgnoringSafeArea(.top)
                    .gesture(
                        DragGesture()
                            .onChanged { value in
                                print("Gesture in progress: \(value.translation.width)")
                            }
                            .onEnded { value in
                                print("Gesture ended: \(value.translation.width)")
                                if value.translation.width > 100 {
                                    self.presentationMode.wrappedValue.dismiss()
                                }
                            }
                    )
                    .onTapGesture {
                        self.presentationMode.wrappedValue.dismiss()
                    }
                    .background(Color.clear)
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
                loadProfileImage()
                fetchUsername() // Fetch the username when the view appears
            }
            .sheet(isPresented: $showingImagePicker) {
                ImagePicker(image: $selectedImage) {
                    self.showingImagePicker = false
                    uploadProfileImage()
                }
            }
        }
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
}


struct CalendarView: View {
    @Binding var currentDate: Date
    @Binding var selectedDate: Date
    @Binding var displayedMonth: Int
    @Binding var displayedYear: Int

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
                        
                        // We don't need to update currentDate or selectedDate anymore
                        // as we only want to highlight the current day in the current month
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
                    }
                }
    
            private var formattedYear: String {
                    return yearFormatter.string(from: NSNumber(value: displayedYear)) ?? "\(displayedYear)"
                }
            }

            #Preview {
                Profile()
            }
