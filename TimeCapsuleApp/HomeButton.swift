import SwiftUI

struct HomeButton: View {
    
    @State private var username: String = ""
    @State private var navigateToHome = false
    
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
                
                NavigationLink(destination: Home(username: username).navigationBarBackButtonHidden(true),
                    isActive: $navigateToHome,
                    label: {
                    Image("Notebook")
                        .renderingMode(.template)
                        .foregroundColor(.white)
                    }
                )
                .simultaneousGesture(TapGesture().onEnded {
                    navigateToHome = true
                })
            }
            .padding(.bottom, 20)
        }
    }
}

struct HomeButton_Previews: PreviewProvider {
    static var previews: some View {
        HomeButton()
    }
}
               
