import SwiftUI

struct Writeinfo: View {
    @State private var animateBars: Bool = false

    var body: some View {
        VStack {
            Spacer()
                .frame(height: 100) // Pushes the content down by 130 points from the top

            Text("Write about that day")
                .font(.system(size: 24))
                .fontWeight(.bold)
            
            Spacer()
                .frame(height: 10)
            Text("40 words only!")
                .foregroundColor(.gray)
                .font(.system(size: 18))
                .fontWeight(.medium)

            Spacer()
            
            HStack {
                Image("2")
                    .resizable()
                    .frame(width: 217, height: 328)
                    .cornerRadius(19)
                    .overlay(
                        RoundedRectangle(cornerRadius: 19)
                            .stroke(Color.white, lineWidth: 4)
                    )
                    .shadow(radius: 24, x: 0, y: 14)
                    
                    .overlay(
                        RoundedRectangle(cornerRadius: 19)
                            .fill(Color.white.opacity(0.35))
                            .blur(radius: 0.9)
                            .frame(width: 152, height: 17)
                            .shadow(color: Color.black, radius: 2, x: 4, y: 4)
                            .offset(x: animateBars ? -10 : -300, y: 70)
                            .animation(Animation.linear(duration: 1).delay(0.2), value: animateBars)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 19)
                            .fill(Color.white.opacity(0.35))
                            .frame(width: 105, height: 17)
                            .shadow(color: Color.black, radius: 2, x: 4, y: 4)
                            .offset(x: animateBars ? -30 : -300, y: 100)
                            .animation(Animation.linear(duration: 1).delay(0.4), value: animateBars)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 19)
                            .fill(Color.white.opacity(0.35))
                            .frame(width: 58, height: 17)
                            .shadow(color: Color.black, radius: 2, x: 4, y: 4)
                            .offset(x: animateBars ? -50 : -300, y: 130)
                            .animation(Animation.linear(duration: 1).delay(0.6), value: animateBars)
                    )
            }
            .offset(y: -22)
            
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
        .frame(maxHeight: .infinity)
        .onAppear {
            // Start the animation when the view appears
            withAnimation {
                animateBars.toggle()
            }
        }
    }
}

#Preview {
    Writeinfo()
}
