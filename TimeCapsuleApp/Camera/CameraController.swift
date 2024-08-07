import SwiftUI

struct CameraView: UIViewControllerRepresentable {
    @Binding var navigateToHome: Bool

    func makeUIViewController(context: Context) -> Camera {
        let camera = Camera()
        return camera
    }

    func updateUIViewController(_ uiViewController: Camera, context: Context) {
        // Update the view controller if needed
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject {
        var parent: CameraView

        init(_ parent: CameraView) {
            self.parent = parent
        }
    }
}

struct CameraController: View {
    @State private var navigateToHome = false

    var body: some View {
        ZStack {
            CameraView(navigateToHome: $navigateToHome)
                .edgesIgnoringSafeArea(.all)
            
            VStack {
                Spacer()
                HomeButton()
                    .padding(.bottom, 30) // Adjust as needed
            }
        }
        .navigationBarHidden(true) // Hide the navigation bar if somehow it's still shown
    }
}

struct CameraController_Previews: PreviewProvider {
    static var previews: some View {
        CameraController()
    }
}
