import SwiftUI
import UIKit
import Firebase
import FirebaseAuth
import FirebaseCore
import FirebaseFirestore
import AuthenticationServices

struct Timecap: View {
    @State private var imagesAppeared = false
    @State private var isSignedIn = false
    @State private var authError: String?
    @State private var navigateToHome = false
    @State private var isLoading = true // Added loading state
    let db = Firestore.firestore() // Firestore reference

    var body: some View {
        if isLoading {
            VStack {
                // Nothing inside, or you can add a placeholder UI element if needed
            }
            .onAppear {
                checkUserStatus()
            }
        } else {
            NavigationView {
                VStack {
                    Text("TimeCap")
                        .font(.system(size: 39, weight: .bold, design: .rounded))
                        .foregroundColor(.black)
                    
                    Text("only one photo a day.")
                        .font(.system(size: 22, weight: .bold, design: .rounded))
                        .foregroundColor(.gray)

                    HStack {
                        Spacer()
                        HStack {
                            Image("1")
                                .resizable()
                                .frame(width: 116, height: 169.35)
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
                                .animation(.interpolatingSpring(stiffness: 60, damping: 6).delay(0.1), value: imagesAppeared)
                                .onAppear {
                                    if imagesAppeared {
                                        triggerHaptic()
                                    }
                                }

                            Image("2")
                                .resizable()
                                .frame(width: 116, height: 169.35)
                                .cornerRadius(19)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 19)
                                        .stroke(Color.white, lineWidth: 4)
                                )
                                .zIndex(2)
                                .rotationEffect(Angle(degrees: -2))
                                .shadow(radius: 24, x: 0, y: 14)
                                .scaleEffect(imagesAppeared ? 1 : 0)
                                .animation(.interpolatingSpring(stiffness: 60, damping: 6).delay(0.2), value: imagesAppeared)
                                .onAppear {
                                    if imagesAppeared {
                                        triggerHaptic()
                                    }
                                }

                            Image("3")
                                .resizable()
                                .frame(width: 116, height: 169.35)
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
                                .animation(.interpolatingSpring(stiffness: 60, damping: 6).delay(0.3), value: imagesAppeared)
                                .onAppear {
                                    if imagesAppeared {
                                        triggerHaptic()
                                    }
                                }
                        }
                        .frame(maxHeight: .infinity, alignment: .top)
                        .padding(.top, 118)

                        Spacer()
                    }

                    // Sign in button
                    SignInWithAppleButton { request in
                        request.requestedScopes = [.fullName, .email]
                    } onCompletion: { result in
                        switch result {
                        case .success(let authResults):
                            switch authResults.credential {
                            case let appleIDCredential as ASAuthorizationAppleIDCredential:
                                // Extract the token and authenticate with Firebase
                                guard let identityToken = appleIDCredential.identityToken else {
                                    print("Unable to fetch identity token")
                                    return
                                }
                                let tokenString = String(data: identityToken, encoding: .utf8) ?? ""
                                let firebaseCredential = OAuthProvider.credential(withProviderID: "apple.com", idToken: tokenString, rawNonce: "")

                                Auth.auth().signIn(with: firebaseCredential) { authResult, error in
                                    if let error = error {
                                        print("Firebase sign in error: \(error.localizedDescription)")
                                        self.authError = error.localizedDescription
                                        return
                                    }
                                    // User is signed in
                                    if let user = authResult?.user {
                                        checkUserInFirestore(uid: user.uid) { exists in
                                            if exists {
                                                self.navigateToHome = true
                                            } else {
                                                saveUserToFirestore(user: user) { success in
                                                    self.isSignedIn = success
                                                }
                                            }
                                        }
                                    }
                                }

                            default:
                                break
                            }
                        case .failure(let error):
                            authError = error.localizedDescription
                            print("Authorization failed: \(error.localizedDescription)")
                        }
                    }
                    .signInWithAppleButtonStyle(.black)
                    .frame(width: 291, height: 62)
                    .cornerRadius(40)
                    .shadow(radius: 24, x: 0, y: 14)
                    .padding(.bottom, 20)
                    // End sign in button

                    if let authError = authError {
                    }
                    
                    // Hidden NavigationLink to handle navigation
                    NavigationLink(destination: Photoinfo().navigationBarBackButtonHidden(true), isActive: $isSignedIn) {
                        EmptyView()
                    }
                    .isDetailLink(false) // Prevent unintended navigation behavior

                    // Hidden NavigationLink to Home
                    NavigationLink(destination: Home().navigationBarBackButtonHidden(true), isActive: $navigateToHome) {
                        EmptyView()
                    }
                    .isDetailLink(false) // Prevent unintended navigation behavior
                }
                .frame(maxHeight: .infinity, alignment: .top)
                .padding(.top, 134)
                .background(Color.white)
                .onAppear {
                    imagesAppeared = true
                    triggerHaptic()
                }
                .onDisappear {
                    imagesAppeared = false
                }
            }
            .navigationViewStyle(StackNavigationViewStyle())
        }
    }

    private func triggerHaptic() {
        let generator = UINotificationFeedbackGenerator()
        generator.prepare()
        generator.notificationOccurred(.success)
    }

    private func saveUserToFirestore(user: User, completion: @escaping (Bool) -> Void) {
        let db = Firestore.firestore()
        let usersRef = db.collection("users")

        let userData: [String: Any] = [
            "uid": user.uid,
            "email": user.email ?? "",
            "fullName": user.displayName ?? ""
        ]

        usersRef.document(user.uid).setData(userData) { error in
            if let error = error {
                print("Error saving user to Firestore: \(error.localizedDescription)")
                completion(false)
            } else {
                print("User successfully saved to Firestore")
                completion(true)
            }
        }
    }
    
    private func checkUserInFirestore(uid: String, completion: @escaping (Bool) -> Void) {
        let usersRef = db.collection("users").document(uid)
        usersRef.getDocument { document, error in
            if let document = document, document.exists {
                completion(true)
            } else {
                completion(false)
            }
        }
    }

    private func checkUserStatus() {
        if let currentUser = Auth.auth().currentUser {
            checkUserInFirestore(uid: currentUser.uid) { exists in
                self.navigateToHome = exists
                self.isLoading = false // Set loading to false once status is checked
            }
        } else {
            self.isLoading = false // Set loading to false if no user is signed in
        }
    }
}

#Preview {
    Timecap()
}
