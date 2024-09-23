import SwiftUI

struct Writeinfo: View {
    @State private var isAnimating: Bool = false
    @Environment(\.horizontalSizeClass) var sizeClass // Detect the size class (compact for iPhones, regular for iPads)

    var body: some View {
        NavigationView {
            if sizeClass == .compact {
                // iPhone Layout (Compact size class)
                VStack {
                    Spacer()
                        .navigationBarBackButtonHidden(true) // Hides back button for this view
                        .frame(height: 100) // Pushes the content down by 100 points from the top
                    
                    Text("Write about that day")
                        .font(.system(size: 24, weight: .bold, design: .rounded))
                        .fontWeight(.bold)
                    
                    Text("40 words only!")
                        .font(.system(size: 18, weight: .bold, design: .rounded))
                        .fontWeight(.medium)
                        .foregroundColor(.gray)
                    
                    Spacer()
                    
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
                                RoundedRectangle(cornerRadius: 19)
                                    .fill(Color.white.opacity(0.35))
                                    .frame(width: 152, height: 17, alignment: .leading)
                                    .scaleEffect(x: isAnimating ? 1.05 : 0, y: 1, anchor: .leading)
                                    .shadow(color: Color.black, radius: 2, x: 4, y: 4)
                                    .offset(x: -13, y: 70)
                                    .animation(.spring(response: 0.5, dampingFraction: 0.6, blendDuration: 0.1).delay(0.0), value: isAnimating)
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 19)
                                    .fill(Color.white.opacity(0.35))
                                    .frame(width: 105, height: 17, alignment: .leading)
                                    .scaleEffect(x: isAnimating ? 1.05 : 0, y: 1, anchor: .leading)
                                    .shadow(color: Color.black, radius: 2, x: 4, y: 4)
                                    .offset(x: -37, y: 100)
                                    .animation(.spring(response: 0.5, dampingFraction: 0.6, blendDuration: 0.1).delay(0.5), value: isAnimating)
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 19)
                                    .fill(Color.white.opacity(0.35))
                                    .frame(width: 58, height: 17, alignment: .leading)
                                    .scaleEffect(x: isAnimating ? 1.05 : 0, y: 1, anchor: .leading)
                                    .shadow(color: Color.black, radius: 2, x: 4, y: 4)
                                    .offset(x: -60, y: 130)
                                    .animation(.spring(response: 0.5, dampingFraction: 0.6, blendDuration: 0.1).delay(1.0), value: isAnimating)
                            )
                    }
                    
                    Spacer() // Pushes the button towards the bottom
                    
                    NavigationLink(destination: Create().navigationBarBackButtonHidden(true)) {
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
                .onAppear {
                    withAnimation {
                        isAnimating = true
                    }
                }
                .navigationBarBackButtonHidden(true) // Hides back button for this view
            } else {
                // iPad Layout (Regular size class)
                VStack {
                    Spacer()
                        .navigationBarBackButtonHidden(true) // Hides back button for this view
                        .frame(height: 150) // Pushes the content down more on iPads
                    
                    Text("Write about that day")
                        .font(.system(size: 36, weight: .bold, design: .rounded)) // Larger font size for iPads
                        .fontWeight(.bold)
                    
                    Text("40 words only!")
                        .font(.system(size: 24, weight: .bold, design: .rounded)) // Larger font size for iPads
                        .fontWeight(.medium)
                        .foregroundColor(.gray)
                    
                    Spacer()
                    
                    HStack {
                        Image("2")
                            .resizable()
                            .frame(width: 350, height: 500) // Larger size for iPads
                            .cornerRadius(19)
                            .overlay(
                                RoundedRectangle(cornerRadius: 19)
                                    .stroke(Color.white, lineWidth: 4)
                            )
                            .shadow(radius: 24, x: 0, y: 14)
                            .overlay(
                                RoundedRectangle(cornerRadius: 19)
                                    .fill(Color.white.opacity(0.35))
                                    .frame(width: 250, height: 25, alignment: .leading) // Larger size for iPads
                                    .scaleEffect(x: isAnimating ? 1.05 : 0, y: 1, anchor: .leading)
                                    .shadow(color: Color.black, radius: 2, x: 4, y: 4)
                                    .offset(x: -20, y: 110) // Adjusted offset for iPads
                                    .animation(.spring(response: 0.5, dampingFraction: 0.6, blendDuration: 0.1).delay(0.0), value: isAnimating)
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 19)
                                    .fill(Color.white.opacity(0.35))
                                    .frame(width: 180, height: 25, alignment: .leading) // Larger size for iPads
                                    .scaleEffect(x: isAnimating ? 1.05 : 0, y: 1, anchor: .leading)
                                    .shadow(color: Color.black, radius: 2, x: 4, y: 4)
                                    .offset(x: -55, y: 160) // Adjusted offset for iPads
                                    .animation(.spring(response: 0.5, dampingFraction: 0.6, blendDuration: 0.1).delay(0.5), value: isAnimating)
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 19)
                                    .fill(Color.white.opacity(0.35))
                                    .frame(width: 100, height: 25, alignment: .leading) // Larger size for iPads
                                    .scaleEffect(x: isAnimating ? 1.05 : 0, y: 1, anchor: .leading)
                                    .shadow(color: Color.black, radius: 2, x: 4, y: 4)
                                    .offset(x: -95, y: 210) // Adjusted offset for iPads
                                    .animation(.spring(response: 0.5, dampingFraction: 0.6, blendDuration: 0.1).delay(1.0), value: isAnimating)
                            )
                    }
                    
                    Spacer() // Pushes the button towards the bottom
                    
                    NavigationLink(destination: Create().navigationBarBackButtonHidden(true)) {
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
                .onAppear {
                    withAnimation {
                        isAnimating = true
                    }
                }
                .navigationBarBackButtonHidden(true) // Hides back button for this view
            }
        }
        .frame(maxHeight: .infinity)
        .navigationBarBackButtonHidden(true) // Hides back button for this view
        .navigationViewStyle(StackNavigationViewStyle()) // Prevents split view on iPads
    }
}

#Preview {
    Writeinfo()
}
