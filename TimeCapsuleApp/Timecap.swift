//
//  Timecap.swift
//  TimeCapsuleApp
//
//  Created by Abraham May on 8/2/24.
//

import SwiftUI

struct Timecap: View {
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
                HStack(spacing: -50){
                    
                    Image("1")
                        .resizable()
                        .frame(width: 116, height: 169.35)
                        .cornerRadius(19)
                        .zIndex(3)
                        .rotationEffect(Angle(degrees: -16))
                        .offset(y: 10)
                    
                    Image("2")
                        .resizable()
                        .frame(width: 116, height: 169.35)
                        .cornerRadius(19)
                        .zIndex(2)
                        .rotationEffect(Angle(degrees: -2))
                    
                    Image("3")
                        .resizable()
                        .frame(width: 116, height: 169.35)
                        .cornerRadius(19)
                        .zIndex(1)
                        .rotationEffect(Angle(degrees: 17))
                        .offset(y: 10)
                    
                }
                .frame(maxHeight: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/, alignment: .top)
                .padding(.top, 118)
                
                Spacer()
            }
        }
        .frame(maxHeight: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/, alignment: .top)
        .padding(.top, 134)
        
        ZStack{
            Rectangle()
                .frame(width: 291, height: 62)
                .cornerRadius(40)
                .foregroundColor(.black)
            
            Text("Sign in with Apple")
                .foregroundColor(.white)
                .font(.system(size: 16, weight: .semibold))
        }
        .padding(.bottom, 20)
    }
}

#Preview {
    Timecap()
}
