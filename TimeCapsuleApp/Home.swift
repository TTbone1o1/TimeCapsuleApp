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
                    .background(Color.white) // Ensure background color for clarity
                    .autocapitalization(.none) // Prevent automatic capitalization if not needed
                    .disableAutocorrection(true) // Disable autocorrection if not needed

                Button(action: {
                    onSubmit()
                    showModal = false // Dismiss the modal
                }) {
                    ZStack {
                        Rectangle()
                            .frame(width: 291, height: 62)
                            .cornerRadius(40)
                            .foregroundColor(.black)
                            .shadow(radius: 24, x: 0, y: 14)
                        
                        HStack {
                            Text("Submit")
                                .foregroundColor(.white)
                                .font(.system(size: 16, weight: .semibold))
                        }
                    }
                }
                .padding(.bottom, 20)
            }
            .background(Color.white)
            .cornerRadius(20)
            .shadow(radius: 10)
            .frame(height: 300)
            .padding(.horizontal, 20)
            .padding(.bottom, 20)
        }
        .edgesIgnoringSafeArea(.bottom) // Adjust to ensure keyboard visibility
        .background(Color.black.opacity(0.5)) // Dim background for focus on modal
    }
}

#Preview {
    Modal(showModal: .constant(true), username: "User", userInput: .constant("")) {
        // Handle submit action here
    }
}
