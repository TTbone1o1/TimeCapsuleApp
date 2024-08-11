import SwiftUI

struct HomeButton: View {
    
    @State private var username: String = ""
    @State private var navigateToHome = false
    
    var body: some View {
        VStack {
            Spacer()
            
            HStack {
                    ZStack {
                        Circle()
                            .stroke(Color.white, lineWidth: 3)
                            .frame(width: 24, height: 24)
                        
                        Circle()
                            .frame(width: 13, height: 13)
                            .foregroundColor(.white)
                    }
                
                Spacer()
                    .frame(width: 72)
                
                NavigationLink(destination: Home().navigationBarBackButtonHidden(true),
                    isActive: $navigateToHome,
                    label: {
                    Image("Notebook")
                        .renderingMode(.template)
                        .foregroundColor(.white)
                        .opacity(0.4)
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
               
