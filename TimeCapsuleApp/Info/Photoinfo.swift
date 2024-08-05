import SwiftUI

struct Photoinfo: View {
    var body: some View {
        VStack {
            Spacer()
                .frame(height: 130) // Pushes the content down by 130 points from the top

            Text("Take one photo daily")
                .font(.system(size: 24))
                .fontWeight(.semibold)

            Spacer() // Pushes the button towards the bottom

            Button(action: {
                // for now it's just a button
            }) {
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
            }
            .padding(.bottom, 20) // Adds some space at the bottom of the screen
        }
        .frame(maxHeight: .infinity) // Ensures the VStack takes the full height of the screen
    }
}

#Preview {
    Photoinfo()
}
