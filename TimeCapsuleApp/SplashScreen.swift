//
//  SplashScreen.swift
//  TimeCapsuleApp
//
//  Created by Abraham May on 9/14/24.
//

import SwiftUI

struct SplashScreen: View {
    @State private var isActive = false
    @State private var size = 0.8
    @State private var opacity = 0.5
    @State private var imagesAppeared = false // State to control image animation
    
    var body: some View {
        if isActive {
            Home() // Replace with your actual home view
        } else {
            VStack {
                Spacer() // Push content down to center vertically

                Text("TimeCap")  // Changed text to "TimeCap"
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                    .fontWeight(.bold)
                    .padding(.bottom, 30)

                // HStack for the three images (1, 2, 3)
                HStack {
                    Spacer() // Push the images to the center horizontally

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

                    Spacer() // Push the images to the center horizontally
                }

                Spacer() // Push content up to center vertically
            }
            .onAppear {
                // Trigger image animation when the splash screen appears
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    imagesAppeared = true
                }
                // Delay to move to the main view
                DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                    withAnimation {
                        self.isActive = true
                    }
                }
            }
        }
    }

    // Simple function to trigger haptic feedback when the image appears
    func triggerHaptic() {
        let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
        impactFeedback.impactOccurred()
    }
}

struct SplashScreen_Previews: PreviewProvider {
    static var previews: some View {
        SplashScreen()
    }
}
