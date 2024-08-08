import SwiftUI

struct CameraView: UIViewControllerRepresentable {
    @Binding var navigateToHome: Bool
    var cameraDelegate: CameraDelegate?

    func makeUIViewController(context: Context) -> Camera {
        let camera = Camera()
        camera.delegate = cameraDelegate
        return camera
    }

    func updateUIViewController(_ uiViewController: Camera, context: Context) {
        // Update the view controller if needed
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, CameraDelegate {
        var parent: CameraView

        init(_ parent: CameraView) {
            self.parent = parent
        }

        func didTakePhoto() {
            // Handle the photo taken event
            parent.navigateToHome = true
        }
    }
}

struct CameraController: View {
    @State private var navigateToHome = false

    var body: some View {
        ZStack {
            CameraView(navigateToHome: $navigateToHome, cameraDelegate: CameraController.Coordinator(self))
                .edgesIgnoringSafeArea(.all)
            
            if !navigateToHome {
                VStack {
                    Spacer()
                    HomeButton()
                        .padding(.bottom, 30) // Adjust as needed
                }
            }
        }
        .navigationBarHidden(true) // Hide the navigation bar if somehow it's still shown
    }
    
    class Coordinator: NSObject, CameraDelegate {
        var parent: CameraController

        init(_ parent: CameraController) {
            self.parent = parent
        }

        func didTakePhoto() {
            // Handle the photo taken event
            DispatchQueue.main.async {
                self.parent.navigateToHome = true
            }
        }
    }
}


//struct PostButton: View {
//    var body: some View {
//        Button(action: {
//            // Define the action for posting the photo
//            print("Post Button tapped!")
//        }) {
//            Text("Post")
//                .font(.title)
//                .padding()
//                .background(Color.blue)
//                .foregroundColor(.white)
//                .cornerRadius(10)
//        }
//    }
//}

struct CameraController_Previews: PreviewProvider {
    static var previews: some View {
        CameraController()
    }
}
