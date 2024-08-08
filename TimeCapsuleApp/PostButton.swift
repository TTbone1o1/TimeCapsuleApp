import SwiftUI

struct PostView: View {
    @ObservedObject private var keyboardObserver = KeyboardObserver()
    @State private var caption: String = ""
    @State private var username: String = ""
    @State private var navigateToHome = false
    var selectedImage: UIImage?

    var body: some View {
        VStack {
            Spacer()
            
            ZStack(alignment: .leading) {
                if caption.isEmpty {
                    Text("Say something about this day...")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(.white)
                        .frame(width: 300)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 24)
                }
                TextField("", text: $caption)
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(.white)
                    .frame(width: 300)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 24)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding()
            
            Spacer()
            
            if !keyboardObserver.isKeyboardVisible {
                NavigationLink(destination: Home(username: username).navigationBarBackButtonHidden(true),
                    isActive: $navigateToHome,
                    label: {
                    ZStack {
                        Rectangle()
                            .frame(width: 291, height: 62)
                            .cornerRadius(40)
                            .foregroundColor(.black)
                            .shadow(radius: 24, x: 0, y: 14)
                        
                        HStack {
                            Text("Post")
                                .foregroundColor(.white)
                                .font(.system(size: 16, weight: .semibold))
                        }
                    }
                       
                    }
                )
                .padding(.bottom, 20)
                .simultaneousGesture(TapGesture().onEnded {
                    navigateToHome = true
                })
            }
        }
        .background(Color.clear) // Ensure background is clear
    }
}

#Preview {
    PostView(selectedImage: UIImage(systemName: "photo")!) // For preview purposes
}
