import SwiftUI

struct Photoinfo: View {
    @State private var rex: Bool = false

    var body: some View {
        NavigationView {
            VStack {
                Spacer()
                    .navigationBarBackButtonHidden(true)
                    .frame(height: 100) // Pushes the content down by 100 points from the top

                Text("Take one photo daily")
                    .font(.system(size: 24, weight: .bold, design: .rounded))
                    .fontWeight(.bold)
                Spacer()

                HStack {
                    HStack {
                        Image("2")
                            .resizable()
                            .frame(width: 217, height: 328)
                            .cornerRadius(19)
                            .shadow(radius: 24, x: 0, y: 14)
                            .opacity(rex ? 0.5 : 1) // Apply flashing effect based on rex
                            .overlay(
                                RoundedRectangle(cornerRadius: 19)
                                    .stroke(Color.white, lineWidth: 4)
                            )
                            .shadow(radius: 24, x: 0, y: 14)
                            .onAppear {
                                // Start animations together
                                withAnimation(
                                    Animation.easeInOut(duration: 1.0)
                                        .repeatForever(autoreverses: true)
                                ) {
                                    rex = true
                                }
                            }
                            .overlay(
                                Circle()
                                    .foregroundColor(rex ? .gray : .white) // Apply color based on rex
                                    .frame(width: 38, height: 38)
                                    .scaleEffect(rex ? 0.9 : 1.2) // Apply scale effect based on rex
                                    .offset(y: 130)
                            )
                    }
                }

                Spacer() // Pushes the button towards the bottom

                NavigationLink(destination: Writeinfo().navigationBarBackButtonHidden(true)) {
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
            .navigationBarBackButtonHidden(true) // Hides back button for this view
        }
        .frame(maxHeight: .infinity) // Ensures the VStack takes the full height of the screen
    }
}

#Preview {
    Photoinfo()
}
