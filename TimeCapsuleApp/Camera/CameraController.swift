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
    @State private var isShowingMessage = false

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
            
            // Add your MessageButton here
            MessageButton(isShowing: $isShowingMessage)
        }
        .navigationBarHidden(true) // Hide the navigation bar if somehow it's still shown
        .onAppear {
            // Example: show the message button when the view appears
            isShowingMessage = true
        }
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

struct CameraController_Previews: PreviewProvider {
    static var previews: some View {
        CameraController()
    }
}
