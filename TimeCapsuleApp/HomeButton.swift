//
//  HomeButton.swift
//  TimeCapsuleApp
//
//  Created by Abraham May on 8/7/24.
//

import SwiftUI

struct HomeButton: View {
    var body: some View {
        VStack {
            Spacer()

            HStack {
                Button(action: {
                    
                }, label: {
                    ZStack {
                        Circle()
                            .stroke(Color.gray, lineWidth: 3)
                            .frame(width: 24, height: 24)
                        
                        Circle()
                            .frame(width: 13, height: 13)
                            .foregroundColor(.gray)
                    }
                })
                
                
                Spacer()
                    .frame(width: 72)

                Button(action: {
                    
                }) {
                    Image("Notebook")
                        .renderingMode(.template) // Use template rendering mode
                        .foregroundColor(.red)
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
