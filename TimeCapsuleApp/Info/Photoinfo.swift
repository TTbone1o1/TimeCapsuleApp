import SwiftUI

struct Photoinfo: View {
    var body: some View {
        NavigationView {
            VStack {
                Spacer()
                    .navigationBarBackButtonHidden(true)
                    .frame(height: 100) // Pushes the content down by 100 points from the top
                
                Text("Take one photo daily")
                    .font(.system(size: 24))
                    .fontWeight(.bold)
                Spacer()
                
                HStack {
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
                                Circle()
                                    .foregroundColor(.white)
                                    .frame(width: 38, height: 38)
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
