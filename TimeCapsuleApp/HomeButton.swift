import SwiftUI

struct HomeButton: View {
    var body: some View {
        VStack {
            Spacer()
            
            HStack {
                NavigationLink(destination: Home(username: "YourUsername")) {
                    ZStack {
                        Circle()
                            .stroke(Color.gray, lineWidth: 3)
                            .frame(width: 24, height: 24)
                        
                        Circle()
                            .frame(width: 13, height: 13)
                            .foregroundColor(.gray)
                    }
                }
                
                Spacer()
                    .frame(width: 72)
                
                NavigationLink(destination: Home(username: "YourUsername")) {
                    Image("Notebook")
                        .renderingMode(.template)
                        .foregroundColor(.white)
                }
            }
            .padding(.bottom, 20) // Adjust as needed for safe area or design requirements
        }
    }
}

struct HomeButton_Previews: PreviewProvider {
    static var previews: some View {
        HomeButton()
    }
}
