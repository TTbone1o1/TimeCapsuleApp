import SwiftUI

struct Home: View {
    var body: some View {
        VStack {
                
            Spacer()
            
            Text("TimeCap")
                .font(.system(size: 39))
                .fontWeight(.semibold) // Adjust this padding to position the text as needed
            HStack {
                Spacer()
                
                HStack {
                    Image("1")
                        .resizable()
                        .frame(width: 116, height: 169.35)
                        .cornerRadius(19)
                        .overlay(
                            RoundedRectangle(cornerRadius: 19)
                                .stroke(Color.white, lineWidth: 4)
                        )
                        .rotationEffect(Angle(degrees: -16))
                        .offset(x: 25, y: 15)
                        .shadow(radius: 24, x: 0, y: 14)
                        .zIndex(3)
                    
                    Image("2")
                        .resizable()
                        .frame(width: 116, height: 169.35)
                        .cornerRadius(19)
                        .overlay(
                            RoundedRectangle(cornerRadius: 19)
                                .stroke(Color.white, lineWidth: 4)
                        )
                        .zIndex(2)
                        .rotationEffect(Angle(degrees: -2))
                        .shadow(radius: 24, x: 0, y: 14)
                    
                    Image("3")
                        .resizable()
                        .frame(width: 116, height: 169.35)
                        .cornerRadius(19)
                        .overlay(
                            RoundedRectangle(cornerRadius: 19)
                                .stroke(Color.white, lineWidth: 4)
                        )
                        .zIndex(1)
                        .rotationEffect(Angle(degrees: 17))
                        .shadow(radius: 24, x: 0, y: 14)
                        .offset(x: -33, y: 15)
                }
                Spacer()
            }
            
            Spacer()
        }
        .padding() // Optional: Adds padding around the VStack
        .frame(maxHeight: .infinity) // Ensure VStack takes full height of the screen
    }
}


#Preview(){
    Home()
}
