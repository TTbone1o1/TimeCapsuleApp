import SwiftUI
import Combine

// KeyboardObserver class to handle keyboard events
class KeyboardObserver: ObservableObject {
    @Published var isKeyboardVisible: Bool = false
    
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        NotificationCenter.default.publisher(for: UIResponder.keyboardWillShowNotification)
            .map { _ in true }
            .merge(with: NotificationCenter.default.publisher(for: UIResponder.keyboardWillHideNotification)
                .map { _ in false })
            .assign(to: \.isKeyboardVisible, on: self)
            .store(in: &cancellables)
    }
}

struct Create: View {
    @State private var username: String = ""
    @ObservedObject private var keyboardObserver = KeyboardObserver()
    @State private var showModal: Bool = false
    @State private var showCamera: Bool = false
    @State private var userInput: String = ""

    var body: some View {
        VStack {
            Spacer()
                .frame(height: 100) // Pushes the content down by 130 points from the top

            Text("Create your username")
                .font(.system(size: 24))
                .fontWeight(.bold)

            Spacer()
            
            ZStack {
                Rectangle()
                    .frame(width: 250, height: 65)
                    .cornerRadius(11)
                    .foregroundColor(.gray)
                    .shadow(radius: 24, x: 0, y: 14)
                
                HStack {
                    ZStack(alignment: .leading) {
                        if username.isEmpty {
                            Text("@username")
                                .foregroundColor(.white)
                                .font(.system(size: 16, weight: .semibold))
                                .padding(.leading, 80)
                        }
                        TextField("", text: $username)
                            .foregroundColor(.white)
                            .font(.system(size: 16, weight: .semibold))
                            .padding(.leading, 10)
                    }
                }
            }
            .frame(maxHeight: .infinity, alignment: .top)
            .padding(.top, 200)
            .padding(.horizontal, 200)
            
            if !keyboardObserver.isKeyboardVisible {
                Button(action: {
//                    presentCamera()
                }) {
                    ZStack {
                        Rectangle()
                            .frame(width: 291, height: 62)
                            .cornerRadius(40)
                            .foregroundColor(.black)
                            .shadow(radius: 24, x: 0, y: 14)
                        
                        HStack {
                            Text("Continue")
                                .foregroundColor(.white)
                                .font(.system(size: 16, weight: .semibold))
                        }
                    }
                }
                .padding(.bottom, 20)
            }
        }
    }

//    private func presentCamera() {
//        if let window = UIApplication.shared.windows.first {
//            let cameraViewController = Camera()
//            cameraViewController.modalPresentationStyle = .fullScreen
//            window.rootViewController?.present(cameraViewController, animated: true, completion: nil)
//        }
//    }
}

#Preview {
    Create()
}
