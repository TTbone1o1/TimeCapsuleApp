import SwiftUI
import FirebaseAuth

struct Setting: View {
    @Binding var isSignedOut: Bool
    
    var body: some View {
        ZStack {
            Rectangle()
                .frame(width: 291, height: 62)
                .cornerRadius(40)
                .foregroundColor(.red)
                .shadow(radius: 24, x: 0, y: 14)
            
            HStack {
                Text("Sign Out")
                    .foregroundColor(.white)
                    .font(.system(size: 16, weight: .semibold))
            }
            .onTapGesture {
                signOut()
            }
        }
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
