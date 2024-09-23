import SwiftUI

struct Photoinfo: View {
    @State private var rex: Bool = false
    @Environment(\.horizontalSizeClass) var sizeClass // Detect the size class (compact or regular)

    var body: some View {
        NavigationView {
            if sizeClass == .compact {
                // iPhone Layout (Compact size class)
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
                                .foregroundColor(.primary)
                                .shadow(radius: 24, x: 0, y: 14)

                            HStack {
                                Text("Continue")
                                    .foregroundColor(Color(UIColor { traitCollection in
                                        return traitCollection.userInterfaceStyle == .dark ? UIColor.black : UIColor.white
                                    }))
                                    .font(.system(size: 16, weight: .bold, design: .rounded))
                            }
                        }
                    }
                    .padding(.bottom, 20) // Adds some space at the bottom of the screen
                }
                .navigationBarBackButtonHidden(true) // Hides back button for this view
            } else {
                // iPad Layout (Regular size class)
                VStack {
                    Spacer()
                        .navigationBarBackButtonHidden(true)
                        .frame(height: 150) // Pushes the content down more on iPads

                    Text("Take one photo daily")
                        .font(.system(size: 36, weight: .bold, design: .rounded)) // Larger font size for iPads
                        .fontWeight(.bold)
                    Spacer()

                    HStack {
                        HStack {
                            Image("2")
                                .resizable()
                                .frame(width: 350, height: 500) // Larger size for iPads
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
                                        .frame(width: 60, height: 60) // Larger circle on iPads
                                        .scaleEffect(rex ? 0.9 : 1.2) // Apply scale effect based on rex
                                        .offset(y: 200) // Adjusted offset for iPads
                                )
                        }
                    }

                    Spacer() // Pushes the button towards the bottom

                    NavigationLink(destination: Writeinfo().navigationBarBackButtonHidden(true)) {
                        ZStack {
                            Rectangle()
                                .frame(width: 400, height: 80) // Larger button size for iPads
                                .cornerRadius(40)
                                .foregroundColor(.primary)
                                .shadow(radius: 24, x: 0, y: 14)

                            HStack {
                                Text("Continue")
                                    .foregroundColor(Color(UIColor { traitCollection in
                                        return traitCollection.userInterfaceStyle == .dark ? UIColor.black : UIColor.white
                                    }))
                                    .font(.system(size: 20, weight: .bold, design: .rounded)) // Larger font size for iPads
                            }
                        }
                    }
                    .padding(.bottom, 30) // Adds more space at the bottom for iPads
                }
                .navigationBarBackButtonHidden(true) // Hides back button for this view
            }
        }
        .navigationViewStyle(StackNavigationViewStyle()) // Prevents split view on iPads
    }
}

#Preview {
    Photoinfo()
}
