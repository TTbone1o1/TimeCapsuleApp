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
                HStack(){
                    
                    Image("1")
                        .resizable()
                        .frame(width: 116, height: 169.35)
                        .cornerRadius(19)
                        .overlay(
                            RoundedRectangle(cornerRadius: 19)
                                .stroke(Color.white, lineWidth: 4))
                        .rotationEffect(Angle(degrees: -16))
                        .offset(x: 25, y: 15)
                        .shadow(radius: 24, x: 0, y: 14)
                        .zIndex(3)
                    
                    Image("2")
                        .resizable()
                        .frame(width: 116, height: 169.35)
                        .cornerRadius(19)
                        .overlay(
                            RoundedRectangle(cornerRadius: 19)
                                .stroke(Color.white, lineWidth: 4))
                        .zIndex(2)
                        .rotationEffect(Angle(degrees: -2))
                        .shadow(radius: 24, x: 0, y: 14)
                    
                    Image("3")
                        .resizable()
                        .frame(width: 116, height: 169.35)
                        .cornerRadius(19)
                        .overlay(
                            RoundedRectangle(cornerRadius: 19)
                                .stroke(Color.white, lineWidth: 4))
                        .zIndex(1)
                        .rotationEffect(Angle(degrees: 17))
                        .shadow(radius: 24, x: 0, y: 14)
                        .offset(x: -33, y: 15)
                    
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
