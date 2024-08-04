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
    @State private var userInput: String = ""

    var body: some View {
        VStack {
            ZStack {
                Rectangle()
                    .frame(width: 250, height: 65)
                    .cornerRadius(11)
                    .foregroundColor(.gray)
                    .shadow(radius: 24, x: 0, y: 14)
                
                HStack {
                    ZStack(alignment: .leading) {
                        if username.isEmpty {
                            Text("Create a username")
                                .foregroundColor(.white)
                                .font(.system(size: 16, weight: .semibold))
                                .padding(.leading, 50)
                        }
                        TextField("", text: $username)
                            .foregroundColor(.white)
                            .font(.system(size: 16, weight: .semibold))
                            .padding(.leading, 10)
                    }
                }
            }
            .frame(maxHeight: .infinity, alignment: .top)
            .padding(.top, 311)
            .padding(.horizontal, 200)
            
            if !keyboardObserver.isKeyboardVisible {
                Button(action: {
                    showModal = true
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
                .fullScreenCover(isPresented: $showModal) {
                    ZStack {
                        CameraViewControllerRepresentable()
                            .edgesIgnoringSafeArea(.all)
                        
                        Modal(
                            showModal: $showModal,
                            username: username,
                            userInput: $userInput,
                            onSubmit: {
                                showModal = false
                                // Here you could also add logic to handle userInput before closing the modal
                            }
                        )
                        
                    }
                }
            }
        }
    }
}

#Preview {
    Create()
}
