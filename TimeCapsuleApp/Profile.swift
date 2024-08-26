//
//  Profile.swift
//  TimeCapsuleApp
//
//  Created by Abraham May on 8/26/24.
//

import SwiftUI

struct Profile: View {
    var body: some View {
        VStack {
            Spacer()
                .frame(height: 128) // Create a spacer with a height of 128

            ZStack {
                Circle()
                    .stroke(Color(.systemGray6), lineWidth: 6) // Stroke with width of 6 and gray color
                    .frame(width: 148, height: 148)
                    
                Circle()
                    .frame(width: 125, height: 125)
            }
            Spacer()
                .frame(height: 20)
            Text("Abraham May")
                .font(.system(size: 32, weight: .bold, design: .rounded))
                .fontWeight(.bold)
                .padding(.leading)
                .foregroundColor(Color.primary)

            Spacer() // Optional: This will center the circle vertically if more space is available
        }
        .edgesIgnoringSafeArea(.top) // Ignore the safe area to ensure spacing from the very top of the screen
    }
}

#Preview {
    Profile()
}
