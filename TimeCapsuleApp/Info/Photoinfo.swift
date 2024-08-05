//
//  Photoinfo.swift
//  TimeCapsuleApp
//
//  Created by Abraham May on 8/5/24.
//

import SwiftUI

struct Photoinfo: View {
    var body: some View {
        VStack {
            Text("Take one photo daily")
                .font(.system(size: 24))
                .fontWeight(.semibold)
            
                    Button(action: {
                        // for now its just a button
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
                    .padding(.bottom, 20)
        }

    }
}

#Preview {
    Photoinfo()
}
