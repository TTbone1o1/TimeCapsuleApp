import SwiftUI

struct Home: View {
    var username: String // Added username property
    @State private var imagesAppeared = false
    
    var body: some View {
        VStack {
            HStack {
                Text(username.isEmpty ? "No Username" : username) // Display the username
                    .font(.system(size: 18))
                    .fontWeight(.bold)
                    .padding()
                
                VStack(spacing: 2) {
                    ForEach(0..<3) { _ in
                        Rectangle()
                            .frame(width: 16, height: 3)
                            .cornerRadius(20)
                            .foregroundColor(.black) // Change color as needed
                    }
                }
                .padding(.leading, 130)
                
                Spacer()
            }

            Spacer()
            
            Text("Take a photo to start")
                .font(.system(size: 18))
                .padding(.bottom, 30)
                .fontWeight(.bold)
            
            HStack {
                Spacer()
                
                HStack {
                    Image("1")
                        .resizable()
                        .frame(width: 82.37, height: 120.26)
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
                        .animation(.interpolatingSpring(stiffness: 60, damping: 7).delay(0.1), value: imagesAppeared)
                        .onAppear {
                            if imagesAppeared {
                                triggerHaptic()
                            }
                        }
                    
                    Image("2")
                        .resizable()
                        .frame(width: 82.37, height: 120.26)
                        .cornerRadius(19)
                        .overlay(
                            RoundedRectangle(cornerRadius: 19)
                                .stroke(Color.white, lineWidth: 4)
                        )
                        .zIndex(2)
                        .rotationEffect(Angle(degrees: -2))
                        .shadow(radius: 24, x: 0, y: 14)
                        .scaleEffect(imagesAppeared ? 1 : 0)
                        .animation(.interpolatingSpring(stiffness: 60, damping: 7).delay(0.2), value: imagesAppeared)
                        .onAppear {
                            if imagesAppeared {
                                triggerHaptic()
                            }
                        }
                    
                    Image("3")
                        .resizable()
                        .frame(width: 82.37, height: 120.26)
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
                        .animation(.interpolatingSpring(stiffness: 60, damping: 7).delay(0.3), value: imagesAppeared)
                        .onAppear {
                            if imagesAppeared {
                                triggerHaptic()
                            }
                        }
                }
                Spacer()
            }
            
            Spacer()
        }
        .padding() // Optional: Adds padding around the VStack
        .frame(maxHeight: .infinity) // Ensure VStack takes full height of the screen
        .onAppear {
            // Start the animation when the view appears
            imagesAppeared = true
            // Trigger haptic feedback when the view first appears
            triggerHaptic()
        }
        .onDisappear {
            // Reset the animation state if necessary
            imagesAppeared = false
        }
    }
}

private func triggerHaptic() {
    let generator = UINotificationFeedbackGenerator()
    generator.prepare()
    generator.notificationOccurred(.success)
}

#Preview {
    Home(username: "Sample Username") // Provide a sample username for preview
}
