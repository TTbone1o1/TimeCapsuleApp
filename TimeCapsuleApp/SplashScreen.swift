import SwiftUI
import FirebaseAuth
import FirebaseFirestore

struct SplashScreen: View {

    @State private var nextScreen: NextScreen? = nil
    @State private var imagesAppeared = false

    enum NextScreen {
        case home
        case login
    }

    var body: some View {
        ZStack {

            // Existing splash UI
            VStack {
                Spacer()

                Text("TimeCap")
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                    .padding(.bottom, 30)

                HStack {
                    Spacer()
                    HStack {
                        Image("1")
                            .resizable()
                            .frame(width: 82.37, height: 120.26)
                            .cornerRadius(19)
                            .overlay(RoundedRectangle(cornerRadius: 19).stroke(Color.white, lineWidth: 4))
                            .rotationEffect(.degrees(-16))
                            .offset(x: 25, y: 15)
                            .shadow(radius: 24, x: 0, y: 14)
                            .scaleEffect(imagesAppeared ? 1 : 0)
                            .animation(.interpolatingSpring(stiffness: 60, damping: 7).delay(0.1), value: imagesAppeared)

                        Image("2")
                            .resizable()
                            .frame(width: 82.37, height: 120.26)
                            .cornerRadius(19)
                            .overlay(RoundedRectangle(cornerRadius: 19).stroke(Color.white, lineWidth: 4))
                            .rotationEffect(.degrees(-2))
                            .shadow(radius: 24, x: 0, y: 14)
                            .scaleEffect(imagesAppeared ? 1 : 0)
                            .animation(.interpolatingSpring(stiffness: 60, damping: 7).delay(0.2), value: imagesAppeared)

                        Image("3")
                            .resizable()
                            .frame(width: 82.37, height: 120.26)
                            .cornerRadius(19)
                            .overlay(RoundedRectangle(cornerRadius: 19).stroke(Color.white, lineWidth: 4))
                            .rotationEffect(.degrees(17))
                            .shadow(radius: 24, x: 0, y: 14)
                            .offset(x: -33, y: 15)
                            .scaleEffect(imagesAppeared ? 1 : 0)
                            .animation(.interpolatingSpring(stiffness: 60, damping: 7).delay(0.3), value: imagesAppeared)
                    }
                    Spacer()
                }

                Spacer()
            }

            // Custom transition to next screen
            if nextScreen == .home {
                Home()
                    .transition(.opacity) // fade
            }

            if nextScreen == .login {
                Timecap()
                    .transition(.opacity) // slide up
            }

        }
        .animation(.easeInOut(duration: 0.45), value: nextScreen)
        .onAppear {
            animateImages()
            checkLoginStatus()
        }
    }

    private func animateImages() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            imagesAppeared = true
        }
    }

    private func checkLoginStatus() {
        if let user = Auth.auth().currentUser {
            Firestore.firestore().collection("users").document(user.uid).getDocument { doc, _ in
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    nextScreen = doc?.exists == true ? .home : .login
                }
            }
        } else {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                nextScreen = .login
            }
        }
    }
}
