import SwiftUI
import UIKit

struct Timecap: View {
    @State private var imagesAppeared = false

    var body: some View {
        VStack {
            Text("Timecap")
                .font(.system(size: 39))
                .fontWeight(.semibold)
            
            Text("only one photo a day.")
                .font(.system(size: 22))
                .foregroundColor(.gray)
            
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
                        .scaleEffect(imagesAppeared ? 1 : 0)
                        .animation(.interpolatingSpring(stiffness: 60, damping: 6).delay(0.1), value: imagesAppeared)
                        .onAppear {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                                if imagesAppeared {
                                    triggerHaptic()
                                }
                            }
                        }
                    
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
                        .scaleEffect(imagesAppeared ? 1 : 0)
                        .animation(.interpolatingSpring(stiffness: 60, damping: 6).delay(0.2), value: imagesAppeared)
                        .onAppear {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                                if imagesAppeared {
                                    triggerHaptic()
                                }
                            }
                        }
                    
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
                        .scaleEffect(imagesAppeared ? 1 : 0)
                        .animation(.interpolatingSpring(stiffness: 60, damping: 6).delay(0.3), value: imagesAppeared)
                        .onAppear {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                                if imagesAppeared {
                                    triggerHaptic()
                                }
                            }
                        }
                }
                .frame(maxHeight: .infinity, alignment: .top)
                .padding(.top, 118)
                
                Spacer()
            }
        }
        .frame(maxHeight: .infinity, alignment: .top)
        .padding(.top, 134)
        .onAppear {
            imagesAppeared = true
        }
        
        Button(action: {
            //action for button
            print("hi")
        }, label: {
            ZStack{
                Rectangle()
                    .frame(width: 291, height: 62)
                    .cornerRadius(40)
                    .foregroundColor(.black)
                    .shadow(radius: 24, x: 0, y: 14)
                
                HStack {
                    Text("Sign in with Apple")
                        .foregroundColor(.white)
                        .font(.system(size: 16, weight: .semibold))
                    
                    Image(systemName: "apple.logo")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 20, height: 20)
                        .foregroundColor(.white)
                }
            }
        })
        .padding(.bottom, 20)
    }
    
    private func triggerHaptic() {
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
    }
}

#Preview {
    Timecap()
}
