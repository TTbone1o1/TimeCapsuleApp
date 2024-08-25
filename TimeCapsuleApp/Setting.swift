import SwiftUI
import FirebaseAuth

struct Setting: View {
    @Binding var isSignedOut: Bool
    @Environment(\.presentationMode) var presentationMode
    @State private var dragOffset: CGFloat = 0
    
    var body: some View {
        ZStack {
            Color.white.edgesIgnoringSafeArea(.all)
            
            VStack {
                //Text("Drag offset: \(dragOffset)")
                
                Rectangle()
                    .frame(width: 291, height: 62)
                    .cornerRadius(40)
                    .foregroundColor(.red)
                    .shadow(radius: 24, x: 0, y: 14)
                    .overlay(
                        Text("Sign Out")
                            .foregroundColor(.white)
                            .font(.system(size: 16, weight: .semibold))
                    )
                    .onTapGesture {
                        signOut()
                    }
            }
        }
        .gesture(
            DragGesture()
                .onChanged { gesture in
                    self.dragOffset = gesture.translation.width
                }
                .onEnded { gesture in
                    if gesture.translation.width > 100 {
                        print("Attempting to dismiss")
                        self.presentationMode.wrappedValue.dismiss()
                    }
                    self.dragOffset = 0
                }
        )
        .navigationBarBackButtonHidden(true)
    }
    
    private func signOut() {
        do {
            try Auth.auth().signOut()
            isSignedOut = true
        } catch let signOutError as NSError {
            print("Error signing out: %@", signOutError)
        }
    }
}

#Preview {
    Setting(isSignedOut: .constant(false))
}
