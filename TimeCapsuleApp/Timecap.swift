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
    @State private var userExists = false // To check if the user exists in Firestore
    let db = Firestore.firestore() // Firestore reference

    var body: some View {
        NavigationView {
            VStack {
                Text("TimeCap")
                    .font(.system(size: 39))
                    .fontWeight(.semibold)

                Text("only one photo a day.")
                    .font(.system(size: 22))
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
                                self.isSignedIn = true

                                if let user = authResult?.user {
                                    // Check if user exists in Firestore
                                    checkUserInFirestore(user: user)
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
                    Text("Authorization failed: \(authError)")
                        .foregroundColor(.red)
                }

                // Conditional NavigationLinks
                NavigationLink(destination: Create().navigationBarBackButtonHidden(true), isActive: $userExists) {
                    EmptyView()
                }
                
                NavigationLink(destination: EmptyView(), isActive: $isSignedIn) {
                    EmptyView()
                }
            }
            .frame(maxHeight: .infinity, alignment: .top)
            .padding(.top, 134)
            .onAppear {
                // Start the animation when the view appears
                imagesAppeared = true
                // Trigger haptic feedback when the view first appears
                triggerHaptic()
            }
            .onDisappear {
                // Reset the animation state if necessary
                imagesAppeared = false
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }

    private func triggerHaptic() {
        let generator = UINotificationFeedbackGenerator()
        generator.prepare()
        generator.notificationOccurred(.success)
    }

    private func checkUserInFirestore(user: User) {
        let usersRef = db.collection("users").document(user.uid)
        usersRef.getDocument { document, error in
            if let error = error {
                print("Error checking user existence: \(error.localizedDescription)")
                return
            }
            if let document = document, document.exists {
                self.userExists = true
                // The user exists in Firestore, so proceed to Create view
            } else {
                self.userExists = false
                // The user does not exist in Firestore, so sign up
                saveUserToFirestore(user: user)
            }
        }
    }

    private func saveUserToFirestore(user: User) {
        let usersRef = db.collection("users").document(user.uid)

        let userData: [String: Any] = [
            "uid": user.uid,
            "email": user.email ?? "",
            "fullName": user.displayName ?? ""
        ]

        usersRef.setData(userData) { error in
            if let error = error {
                print("Error saving user to Firestore: \(error.localizedDescription)")
            } else {
                print("User successfully saved to Firestore")
                self.userExists = true // Ensure userExists is true after saving
            }
        }
    }
}



#Preview {
    Timecap()
}
