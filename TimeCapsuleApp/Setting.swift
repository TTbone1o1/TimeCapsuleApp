import SwiftUI
import FirebaseAuth

struct Setting: View {
    @Environment(\.presentationMode) var presentationMode
    @Binding var isShowing: Bool
    @Binding var isSignedOut: Bool
    @State private var curHeight: CGFloat = 400

    let minHeight: CGFloat = 400
    let maxHeight: CGFloat = 700

    var body: some View {
        ZStack(alignment: .bottom) {
            Color.black
                .opacity(0.3)
                .ignoresSafeArea()
                .onTapGesture {
                    isShowing = false
                }
            mainView
            .transition(.move(edge: .bottom))
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
        .ignoresSafeArea()
        .animation(.easeInOut)
    }

    var mainView: some View {
        VStack {
            ZStack {
                Capsule()
                    .foregroundColor(.gray)
                    .opacity(0.4)
                    .frame(width: 40, height: 6)
            }
            .frame(height: 40)
            .frame(maxWidth: .infinity)
            .background(Color.white.opacity(0.00001))

            ZStack {
                VStack {
                    Spacer()

                    ZStack {
                        Rectangle()
                            .frame(width: 291, height: 62)
                            .cornerRadius(40)
                            .foregroundColor(.black)
                            .shadow(radius: 24, x: 0, y: 14)
                            .overlay(
                                Text("Change profile picture")
                                    .foregroundColor(.white)
                                    .font(.system(size: 16, weight: .bold, design: .rounded))
                            )
                            .onTapGesture {
                                // Add action for changing profile picture here
                            }
                    }

                    Spacer()
                        .frame(height: 20)

                    Button(action: {
                        signOut()
                    }) {
                        Text("Log out")
                            .foregroundColor(.gray)
                            .font(.system(size: 16, weight: .bold, design: .rounded))
                            .padding()
                    }
                }
                .padding(.horizontal, 30)
            }
            .frame(maxHeight: .infinity)
            .padding(.bottom, 55)
        }
        .frame(height: 261)
        .frame(maxWidth: .infinity)
        .background(
            ZStack {
                RoundedRectangle(cornerRadius: 30)
                Rectangle()
                    .frame(height: curHeight / 2)
            }
            .foregroundColor(.white))
    }

    private func signOut() {
        do {
            try Auth.auth().signOut()
            isSignedOut = true
            isShowing = false
        } catch let signOutError as NSError {
            print("Error signing out: %@", signOutError)
        }
    }
}

struct Setting_Previews: PreviewProvider {
    @State static var isShowing = true
    @State static var isSignedOut = false
    
    static var previews: some View {
        Setting(isShowing: $isShowing, isSignedOut: $isSignedOut)
            .previewLayout(.sizeThatFits)
            .padding()
    }
}
