//
//  ContentView.swift
//  TimeCapsuleApp
//
//  Created by Abraham May on 8/1/24.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        VStack() {
            Rectangle()
                .frame(width: 361, height: 410)
                .foregroundColor(/*@START_MENU_TOKEN@*/.blue/*@END_MENU_TOKEN@*/)
                .cornerRadius(40)
            
            Rectangle()
                .frame(width: 325, height: 62)
                .cornerRadius(50)
            
            HStack{
                Rectangle()
                    .frame(width: 140, height: 140)
                    .foregroundColor(.white)
                    .cornerRadius(6)
                    .shadow(radius: 24, x: 0, y: 7)
                
                Rectangle()
                    .frame(width: 140, height: 140)
                    .foregroundColor(.white)
                    .cornerRadius(6)
                    .shadow(radius: 24, x: 0, y: 7)
            }
            
            HStack{
                Rectangle()
                    .frame(width: 140, height: 140)
                    .foregroundColor(.white)
                    .cornerRadius(6)
                    .shadow(radius: 24, x: 0, y: 7)
                
                Rectangle()
                    .frame(width: 140, height: 140)
                    .foregroundColor(.white)
                    .cornerRadius(6)
                    .shadow(radius: 24, x: 0, y: 7)
            }
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
