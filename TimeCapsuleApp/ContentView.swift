//
//  ContentView.swift
//  TimeCapsuleApp
//
//  Created by Abraham May on 8/1/24.
//

import SwiftUI

struct ContentView: View {
    
    @State var selection: String = "Most Recent"
    let filterOptions: [String] = [
    "Journal Entries", "Capsule"
    ]
        
    
    init() {
        UISegmentedControl.appearance().selectedSegmentTintColor = UIColor.white
        
        let attributes: [NSAttributedString.Key:Any] = [
            .foregroundColor: UIColor.black
        ]
        let normal : [NSAttributedString.Key:Any] = [
            .foregroundColor: UIColor.white
        ]
        
        UISegmentedControl.appearance().setTitleTextAttributes(attributes, for: .selected)
        UISegmentedControl.appearance().setTitleTextAttributes(normal, for: .normal)
    }
    
    var body: some View {
        VStack() {
            Rectangle()
                .frame(width: 361, height: 410)
                .foregroundColor(/*@START_MENU_TOKEN@*/.blue/*@END_MENU_TOKEN@*/)
                .cornerRadius(40)
            
            Picker(
                selection: $selection,
                label: Text("Picker"),
                content: {
                    ForEach(filterOptions.indices) { index in
                        Text(filterOptions[index])
                            .tag(filterOptions[index])
                    }
            })
            .pickerStyle(SegmentedPickerStyle())
            .frame(width: 325, height: 62)
            .background(Color.black)
            .cornerRadius(51)
            
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
                    .shadow(radius: 24, x: 13, y: 7)
            }
            
            HStack{
                Rectangle()
                    .frame(width: 140, height: 140)
                    .foregroundColor(.white)
                    .cornerRadius(6)
                    .shadow(radius: 24, x: 0, y: 17)
                
                Rectangle()
                    .frame(width: 140, height: 140)
                    .foregroundColor(.white)
                    .cornerRadius(6)
                    .shadow(radius: 24, x: 13, y: 7)
            }
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
