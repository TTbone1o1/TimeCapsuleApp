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
                    .frame(width: 270, height: 80)
                    .cornerRadius(20)
                
                HStack {
                    ZStack(alignment: .leading) {
                        if username.isEmpty {
                            Text("@username")
                                .foregroundColor(.gray)
                                .frame(width: 270, height: 60)
                                .cornerRadius(20)
                                .font(.system(size: 24, weight: .bold))
                        }
                        TextField("", text: $username)
                            .foregroundColor(.gray)
                            .font(.system(size: 24, weight: .bold))
                            .frame(maxWidth: .infinity)
                            .textFieldStyle(PlainTextFieldStyle())
                            .multilineTextAlignment(.center)
                    }
                    .padding(.horizontal, 90)
                }
            }
            .frame(maxHeight: .infinity, alignment: .top)
            .padding(.top, 200)
            
            if !keyboardObserver.isKeyboardVisible {
                NavigationLink(destination: Home().navigationBarBackButtonHidden(true),
                               isActive: $navigateToHome) {
                    ZStack {
                        Rectangle()
                            .frame(width: 291, height: 62)
                            .cornerRadius(40)
                            .foregroundColor(.black)
                            .shadow(radius: 24, x: 0, y: 14)
                        
                        HStack {
                            Text("Continue")
                                .foregroundColor(.white)
                                .font(.system(size: 16, weight: .semibold))
                        }
                    }
                }
                .padding(.bottom, 20)
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
