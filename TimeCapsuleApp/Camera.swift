import SwiftUI

struct Camera: View {
    @State private var showCamera = false
    @State private var capturedImage: Image? = nil

    var body: some View {
        VStack {
            capturedImage?
                .resizable()
                .scaledToFit()
                .frame(width: 300, height: 300)

            Button(action: {
                self.showCamera = true
            }) {
                ZStack {
                    Rectangle()
                        .frame(width: 291, height: 62)
                        .cornerRadius(40)
                        .foregroundColor(.black)
                        .shadow(radius: 24, x: 0, y: 14)
                    
                    HStack {
                        Text("Take a photo")
                            .foregroundColor(.white)
                            .font(.system(size: 16, weight: .semibold))
                    }
                }
            }
            .sheet(isPresented: $showCamera) {
            }
        }
    }
}

#Preview {
    Camera()
}
