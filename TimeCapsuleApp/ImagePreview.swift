//
//  ImagePreview.swift
//  TimeCapsuleApp
//
//  Created by Abraham May on 8/12/24.
//

import SwiftUI

struct ImagePreview: View {
    @Namespace private var previewSmoothly
    @State private var preview = false
    @State private var selectedImage: String?
    
    var body: some View {
        ZStack {
            if preview{
                if let selectedImage = selectedImage {
                    image(selectedImage)
                        .ignoresSafeArea()
                }
            } else {
                Grid{
                    GridRow {
                        image("1")
                        image("2")
                    }
                    GridRow {
                        image("3")
                        image("4")
                    }
                }
                .padding(10)
            }
        }
    }
    
    func image(_ imageName: String) -> some View {
        Image(imageName)
            .resizable()
            .matchedGeometryEffect(id: imageName, in: previewSmoothly)
            .zIndex(selectedImage == imageName ? 1 : 0)
            .onTapGesture {
                withAnimation(Animation.easeInOut(duration: 0.3)){
                    selectedImage = imageName
                    preview.toggle()
                }
            }
    }
}

#Preview {
    ImagePreview()
}
