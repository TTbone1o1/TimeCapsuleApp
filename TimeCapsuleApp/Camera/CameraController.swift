import SwiftUI
import Firebase
import FirebaseAuth
import FirebaseFirestore
import FirebaseStorage

struct CameraView: UIViewControllerRepresentable {
    @Binding var isShowingMessage: Bool
    @Binding var isPresented: Bool
    @Binding var isPhotoTaken: Bool

    func makeUIViewController(context: Context) -> Camera {
        let camera = Camera()
        camera.delegate = context.coordinator // Set the delegate to the Coordinator
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

        // Delegate method to handle when a photo is taken
        func didTakePhoto() {
            DispatchQueue.main.async {
                self.parent.isPhotoTaken = true // Mark the photo as taken
            }
        }

        // Delegate method to show the message button if the user has already posted today
        func showMessageButton() {
            DispatchQueue.main.async {
                print("Showing MessageButton")
                self.parent.isShowingMessage = true // Trigger showing the MessageButton
            }
        }
    }
}

struct CameraController: View {
    @Binding var isPresented: Bool
    @State private var isShowingMessage = false
    @State private var isPhotoTaken = false
    @State private var navigateToHome = false


    var body: some View {
        NavigationView {
            ZStack {
                CameraView(isShowingMessage: $isShowingMessage, isPresented: $isPresented, isPhotoTaken: $isPhotoTaken)
                
                if isShowingMessage {
                    MessageButton(isShowing: $isShowingMessage)
                        .transition(.opacity) // Transition for the message button appearance
                        .animation(.linear(duration: 0.05)) // Fast animation
                }
                
                if !isPhotoTaken {
                    Button(action: {
                        withAnimation {
                            // Set the navigation to home instead of just dismissing the current view
                            navigateToHome = true
                        }
                    }) {
                        Image(systemName: "arrowshape.backward.fill")
                            .resizable()
                            .frame(width: 20, height: 20)
                            .foregroundColor(.white)
                            .padding()
                    }
                    .position(x: 40, y: 80)
                }
                
                // Add the hidden NavigationLink here
                NavigationLink(destination: Home().navigationBarBackButtonHidden(true), isActive: $navigateToHome) {
                    EmptyView() // Hidden NavigationLink
                }
            }
            .navigationBarHidden(true)
            .edgesIgnoringSafeArea(.all)

        }
    }
}

struct CameraController_Previews: PreviewProvider {
    static var previews: some View {
        CameraController(isPresented: .constant(true))
    }
}
