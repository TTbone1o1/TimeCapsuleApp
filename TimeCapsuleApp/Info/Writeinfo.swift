//
//  Writeinfo.swift
//  TimeCapsuleApp
//
//  Created by Abraham May on 8/5/24.
//

import SwiftUI

struct Writeinfo: View {
    var body: some View {
        VStack {
            Spacer()
                .frame(height: 100) // Pushes the content down by 130 points from the top

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
                            RoundedRectangle(cornerRadius: 19)
                                .fill(Color.white.opacity(0.35))
                                .blur(radius: 0.9)
                                .frame(width: 152, height: 17)
                                .shadow(color: Color.black, radius: 2, x: 4, y: 4)
                                .offset(x: -13, y: 70)
                                
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 19)
                                .fill(Color.white.opacity(0.35))
                                .frame(width: 105, height: 17)
                                .shadow(color: Color.black, radius: 2, x: 4, y: 4)
                                .offset(x: -37, y: 100)

                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 19)
                                .fill(Color.white.opacity(0.35))
                                .frame(width: 58, height: 17)
                                .shadow(color: Color.black, radius: 2, x: 4, y: 4)
                                .offset(x: -60, y: 130)
                                 
                        )

                }
            }
            
            Spacer() // Pushes the button towards the bottom

            Button(action: {
                // for now it's just a button
            }) {
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
        .frame(maxHeight: .infinity)
    }
}

#Preview {
    Writeinfo()
}
