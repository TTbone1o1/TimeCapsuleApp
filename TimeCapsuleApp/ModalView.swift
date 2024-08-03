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
                Button(action: {
                    onSubmit()
                }) {
                    Text("Submit")
                        .bold()
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                        .padding(.horizontal, 20)
                        .padding(.bottom, 20)
                }
            }
            .background(Color.white)
            .cornerRadius(20)
            .shadow(radius: 10)
            .frame(height: 315)
        }
        .edgesIgnoringSafeArea(.all)
    }
}
