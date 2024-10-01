import SwiftUI
import Firebase
import FirebaseAuth
import FirebaseFirestore
import FirebaseStorage

struct CameraView: UIViewControllerRepresentable {
    @Binding var isShowingMessage: Bool
    @Binding var isPresented: Bool
    @Binding var isPhotoTaken: Bool
    @Binding var isRecordingFinished: Bool // New state to track recording completion

    func makeUIViewController(context: Context) -> Camera {
        let camera = Camera()
        camera.delegate = context.coordinator
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
            DispatchQueue.main.async {
                self.parent.isPhotoTaken = true
            }
        }

        func showMessageButton() {
            DispatchQueue.main.async {
                self.parent.isShowingMessage = true
            }
        }

        func didFinishRecordingVideo() {
            DispatchQueue.main.async {
                self.parent.isRecordingFinished = true // Mark that recording finished
            }
        }
    }
}


struct CameraController: View {
    @Binding var isPresented: Bool
    @State private var isShowingMessage = false
    @State private var isPhotoTaken = false
    @State private var navigateToHome = false
    @State private var isRecordingFinished = false // Track recording state

    var body: some View {
        NavigationView {
            ZStack {
                CameraView(isShowingMessage: $isShowingMessage, isPresented: $isPresented, isPhotoTaken: $isPhotoTaken, isRecordingFinished: $isRecordingFinished)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color.black.edgesIgnoringSafeArea(.all))

                if isShowingMessage {
                    MessageButton(isShowing: $isShowingMessage)
                        .transition(.opacity)
                        .animation(.linear(duration: 0.05))
                }

                // Only show back button if recording is not finished and photo hasn't been taken
                if !isRecordingFinished && !isPhotoTaken {
                    Button(action: {
                        withAnimation {
                            let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
                            impactFeedback.impactOccurred()
                            navigateToHome = true
                        }
                    }) {
                        Image(systemName: "arrowshape.backward.fill")
                            .resizable()
                            .frame(width: 20, height: 20)
                            .foregroundColor(.white)
                            .padding()
                    }
                    .position(x: 40, y: 80) // Adjust position as needed
                }



                // Navigation link to home
                NavigationLink(destination: Home().navigationBarBackButtonHidden(true), isActive: $navigateToHome) {
                    EmptyView()
                }
            }
            .navigationBarHidden(true)
            .edgesIgnoringSafeArea(.all)
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
}


struct CameraController_Previews: PreviewProvider {
    static var previews: some View {
        CameraController(isPresented: .constant(true))
    }
}
