import SwiftUI

struct Modal: View {
    @Binding var showModal: Bool
    let username: String
    @Binding var userInput: String
    var onSubmit: () -> Void

    var body: some View {
        VStack {
            Spacer()
            VStack(spacing: 16) {
                Text("Hello \(username), what did you do today?")
                    .font(.headline)
                    .padding(.top, 20)
                TextField("Enter your activity", text: $userInput)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(.horizontal, 20)
                    .padding(.vertical, 20)
                
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
                .padding(.bottom, 60) // Adjust as needed
            }
            .background(Color.white)
            .cornerRadius(20)
            .shadow(radius: 10)
            .frame(height: 100) // Increased height for the white box
            .padding(.bottom, 60) // Adjust if necessary
        }
        .edgesIgnoringSafeArea(.all)
    }
}

#Preview {
    Modal(showModal: .constant(true), username: "User", userInput: .constant("")) {
        // Handle submit action here
    }
}
