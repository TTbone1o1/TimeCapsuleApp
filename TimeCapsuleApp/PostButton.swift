//
//  PostView.swift
//  TimeCapsuleApp
//
//  Created by Abraham May on 8/7/24.
//

import SwiftUI
import Firebase

struct PostView: View {
    @State private var selectedImage: UIImage?
    @State private var caption: String = ""

    var body: some View {
        
        
        VStack {
            Spacer()
            
            ZStack(alignment: .leading) {
                           if caption.isEmpty {
                               Text("Say something about this day...")
                                   .foregroundColor(.black)
                                   .padding(.leading, 8)
                           }
                           TextField("", text: $caption)
                               .foregroundColor(.black)
                               .padding(8)
                       }
                       .padding()
            
            Spacer()
            
            ZStack {
                Rectangle()
                    .frame(width: 291, height: 62)
                    .cornerRadius(40)
                    .foregroundColor(.black)
                    .shadow(radius: 24, x: 0, y: 14)
                
                HStack {
                    Text("Post")
                        .foregroundColor(.white)
                        .font(.system(size: 16, weight: .semibold))
                }
            }
            .padding(.bottom, 20)
        }
    }

    private func postImageWithCaption() {
        guard let image = selectedImage else { return }
        
        // Here you can add code to upload the image and caption to Firebase
    }
}

#Preview {
    PostView()
}
