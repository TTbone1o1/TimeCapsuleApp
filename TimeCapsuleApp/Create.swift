//
//  Create.swift
//  TimeCapsuleApp
//
//  Created by Abraham May on 8/2/24.
//

import SwiftUI

struct Create: View {
    
    @State private var username: String = ""
    
    var body: some View {
        VStack {
            ZStack{
                Rectangle()
                    .frame(width: 250, height: 65)
                    .cornerRadius(11)
                    .foregroundColor(.gray)
                    .shadow(radius: 24, x: 0, y: 14)
                
                HStack {
                    ZStack(alignment: .leading) {
                        if username.isEmpty {
                            Text("Create a username")
                                .foregroundColor(.white)
                                .font(.system(size: 16, weight: .semibold))
                                .padding(.leading, 50)
                        }
                        TextField("", text: $username)
                            .foregroundColor(.white)
                            .font(.system(size: 16, weight: .semibold))
                            .padding(.leading, 10)
                    }
                }
            }
        }
        .frame(maxHeight: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/, alignment: .top)
        .padding(.top, 311)
        .padding(.horizontal, 200)
        
        
        //NavigationLink links you to a different page
        NavigationLink(destination: Camera()) {
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

#Preview {
    Create()
}
