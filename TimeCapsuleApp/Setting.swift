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
                // Back button
                HStack {
                    Button(action: {
                        self.presentationMode.wrappedValue.dismiss()
                    }) {
                        Image(systemName: "chevron.left")
                            .foregroundColor(.black)
                            .imageScale(.large)
                        Text("Back")
                            .foregroundColor(.black)
                    }
                    .padding(.leading, 16)
                    .padding(.top, 16)
                    
                    Spacer()
                }
                
                Spacer()
                
                // Your existing sign out button
                Rectangle()
                    .frame(width: 291, height: 62)
                    .cornerRadius(40)
                    .foregroundColor(.red)
                    .shadow(radius: 24, x: 0, y: 14)
                    .overlay(
                        Text("Sign Out")
                            .foregroundColor(.white)
                            .font(.system(size: 16, weight: .bold, design: .rounded))
                    )
                    .onTapGesture {
                        signOut()
                    }
                
                Spacer()
            }
        }
        .gesture(
            DragGesture()
                .onChanged { gesture in
                    self.dragOffset = gesture.translation.width
                }
                .onEnded { gesture in
                    if gesture.translation.width > 100 {
                        self.presentationMode.wrappedValue.dismiss()
                    }
                    self.dragOffset = 0
                }
        )
        .navigationBarHidden(true)
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
