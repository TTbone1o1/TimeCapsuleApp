import SwiftUI
import Combine
import Firebase
import FirebaseAuth
import FirebaseCore
import FirebaseFirestore
import AuthenticationServices

// KeyboardObserver class to handle keyboard events
class KeyboardObserver: ObservableObject {
    @Published var isKeyboardVisible: Bool = false
    
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        NotificationCenter.default.publisher(for: UIResponder.keyboardWillShowNotification)
            .map { _ in true }
            .merge(with: NotificationCenter.default.publisher(for: UIResponder.keyboardWillHideNotification)
                .map { _ in false })
            .assign(to: \.isKeyboardVisible, on: self)
            .store(in: &cancellables)
    }
}

struct Create: View {
    @State private var username: String = ""
    @ObservedObject private var keyboardObserver = KeyboardObserver()
    @State private var navigateToHome = false
    @Environment(\.horizontalSizeClass) var sizeClass // To detect the device's size class

    var body: some View {
        VStack {
            Spacer()
                .navigationBarBackButtonHidden(true)
                .frame(height: 100)

            Text("Create your username")
                .font(.system(size: 24))
                .fontWeight(.bold)

            Spacer()
            
            ZStack {
                Rectangle()
                    .fill(Color(hex: "#EDEDED"))
                    .frame(width: sizeClass == .compact ? 270 : 400, height: 80) // Adjust width for iPad
                    .cornerRadius(20)
                
                HStack {
                    ZStack(alignment: .leading) {
                        if username.isEmpty {
                            Text("@username")
                                .foregroundColor(.gray)
                                .frame(width: sizeClass == .compact ? 270 : 400, height: 60) // Adjust width for iPad
                                .cornerRadius(20)
                                .font(.system(size: 24, weight: .bold))
                                .offset(x: sizeClass == .regular ? 190 : 0, y: 0)
                        }
                        TextField("", text: $username)
                            .foregroundColor(.gray)
                            .font(.system(size: 24, weight: .bold))
                            .frame(maxWidth: .infinity)
                            .textFieldStyle(PlainTextFieldStyle())
                            .multilineTextAlignment(.center)
                    }
                    .padding(.horizontal, sizeClass == .compact ? 90 : 120) // Adjust padding for iPad
                }
            }
            .frame(maxHeight: .infinity, alignment: .top)
            .padding(.top, sizeClass == .compact ? 200 : 300) // Adjust padding for iPad
            
            if !keyboardObserver.isKeyboardVisible {
                NavigationLink(destination: Home().navigationBarBackButtonHidden(true),
                               isActive: $navigateToHome) {
                    ZStack {
                        Rectangle()
                            .frame(width: sizeClass == .compact ? 291 : 400, height: sizeClass == .compact ? 62 : 70) // Adjusted width and height for iPad
                            .cornerRadius(sizeClass == .compact ? 40 : 50) // Larger corner radius for iPad
                            .foregroundColor(.black)
                            .shadow(radius: 24, x: 0, y: 14)
                        
                        HStack {
                            Text("Continue")
                                .foregroundColor(.white)
                                .font(.system(size: sizeClass == .compact ? 16 : 20, weight: .semibold)) // Larger font size for iPad
                        }
                    }
                }
                .padding(.bottom, sizeClass == .compact ? 20 : 30) // Add more padding at the bottom for iPads
                .simultaneousGesture(TapGesture().onEnded {
                    if let user = Auth.auth().currentUser {
                        saveUsernameToFirestore(user: user, username: username) { success in
                            if success {
                                navigateToHome = true
                            }
                        }
                    }
                })
            }

        }
        .onAppear {
            if let user = Auth.auth().currentUser {
                loadUsernameFromFirestore(user: user) { savedUsername in
                    if let savedUsername = savedUsername {
                        self.username = savedUsername
                    }
                }
            }
        }
    }
}


extension Color {
    init(hex: String) {
        let scanner = Scanner(string: hex)
        scanner.scanLocation = 1 // Bypass the '#' character
        var rgb: UInt64 = 0
        scanner.scanHexInt64(&rgb)
        
        let red = Double((rgb >> 16) & 0xFF) / 255.0
        let green = Double((rgb >> 8) & 0xFF) / 255.0
        let blue = Double(rgb & 0xFF) / 255.0
        
        self.init(red: red, green: green, blue: blue)
    }
}

// Firestore functions
private func saveUsernameToFirestore(user: User, username: String, completion: @escaping (Bool) -> Void) {
    let db = Firestore.firestore()
    
    // Reference to the user's document
    let userDocRef = db.collection("users").document(user.uid)
    
    // Save the username in a sub-collection called "username"
    let usernameDocRef = userDocRef.collection("username").document("info")
    
    usernameDocRef.setData(["username": username]) { error in
        if let error = error {
            print("Error saving username to Firestore: \(error.localizedDescription)")
            completion(false)
        } else {
            print("Username successfully saved to Firestore")
            completion(true)
        }
    }
}

private func loadUsernameFromFirestore(user: User, completion: @escaping (String?) -> Void) {
    let db = Firestore.firestore()
    
    // Reference to the user's document
    let userDocRef = db.collection("users").document(user.uid)
    
    // Retrieve the username from the sub-collection "username"
    let usernameDocRef = userDocRef.collection("username").document("info")
    
    usernameDocRef.getDocument { document, error in
        if let document = document, document.exists {
            let username = document.data()?["username"] as? String
            completion(username)
        } else {
            print("Username not found in Firestore")
            completion(nil)
        }
    }
}

#Preview {
    Create()
}
