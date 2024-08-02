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
                HStack(spacing: 10){
                    
                    Rectangle()
                        .frame(width: 116, height: 169.35)
                        .cornerRadius(19)
                    
                    Rectangle()
                        .frame(width: 116, height: 169.35)
                        .cornerRadius(19)
                    
                    Rectangle()
                        .frame(width: 116, height: 169.35)
                        .cornerRadius(19)
                    
                }
                .frame(maxHeight: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/, alignment: .top)
                .padding(.top, 118)
                
                Spacer()
            }
        }
        .frame(maxHeight: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/, alignment: .top)
        .padding(.top, 134)
        
    }
}

#Preview {
    Timecap()
}
