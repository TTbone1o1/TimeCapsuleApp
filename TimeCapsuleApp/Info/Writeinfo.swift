import SwiftUI

struct Writeinfo: View {
    
    @Environment(\.presentationMode) private var presentationMode: Binding<PresentationMode>
    
    @State private var isAnimating: Bool = false

    var body: some View {
        VStack {
            Spacer()
                .navigationBarBackButtonHidden(true)
                .frame(height: 100) // Pushes the content down by 100 points from the top

            Text("Write about that day")
                .font(.system(size: 24))
                .fontWeight(.bold)
            
            Text("40 words only!")
                .font(.system(size: 18))
                .fontWeight(.medium)
                .foregroundColor(.gray)
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
                            .frame(width: 152, height: 17, alignment: .leading)
                            .scaleEffect(x: isAnimating ? 1.05 : 0, y: 1, anchor: .leading)
                            .shadow(color: Color.black, radius: 2, x: 4, y: 4)
                            .offset(x: -13, y: 70)
                            .animation(.spring(response: 0.5, dampingFraction: 0.6, blendDuration: 0.1).delay(0.0), value: isAnimating)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 19)
                            .fill(Color.white.opacity(0.35))
                            .frame(width: 105, height: 17, alignment: .leading)
                            .scaleEffect(x: isAnimating ? 1.05 : 0, y: 1, anchor: .leading)
                            .shadow(color: Color.black, radius: 2, x: 4, y: 4)
                            .offset(x: -37, y: 100)
                            .animation(.spring(response: 0.5, dampingFraction: 0.6, blendDuration: 0.1).delay(0.5), value: isAnimating)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 19)
                            .fill(Color.white.opacity(0.35))
                            .frame(width: 58, height: 17, alignment: .leading)
                            .scaleEffect(x: isAnimating ? 1.05 : 0, y: 1, anchor: .leading)
                            .shadow(color: Color.black, radius: 2, x: 4, y: 4)
                            .offset(x: -60, y: 130)
                            .animation(.spring(response: 0.5, dampingFraction: 0.6, blendDuration: 0.1).delay(1.0), value: isAnimating)
                    )
            }
            
            Spacer() // Pushes the button towards the bottom

            Button(action: {
                // Add navigation action here if needed
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
            withAnimation {
                isAnimating = true
            }
        }
    }
}

#Preview {
    Writeinfo()
}
