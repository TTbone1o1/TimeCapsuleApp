import SwiftUI
import Combine

// KeyboardObserver class to handle keyboard events
class KeyboardObserver: ObservableObject {
    
    @Environment(\.presentationMode) private var presentationMode: Binding<PresentationMode>
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
    @State private var navigateToHome = false

    var body: some View {
        VStack {
            Spacer()
                .navigationBarBackButtonHidden(true)
                .frame(height: 100) // Pushes the content down by 100 points from the top

            Text("Create your username")
                .font(.system(size: 24))
                .fontWeight(.bold)

            Spacer()
            
            ZStack {
                Rectangle()
                    .fill(Color(hex: "#EDEDED"))
                    .frame(width: 270, height: 80) // Keep the original size for the box
                    .cornerRadius(20)
                
                HStack {
                    ZStack(alignment: .leading) {
                        if username.isEmpty {
                            Text("@username")
                                .foregroundColor(.gray) // Set the placeholder color here
                                .frame(width: 270, height: 60) // Same width and height as the box
                                .cornerRadius(20) // Rounded corners for the text field
                                .font(.system(size: 24, weight: .bold))
                        }
                        TextField("", text: $username)
                            .foregroundColor(.gray) // Set the text color here
                            .font(.system(size: 24, weight: .bold))
                            .frame(maxWidth: .infinity) // Expands to fill available width
                            .textFieldStyle(PlainTextFieldStyle())
                            .multilineTextAlignment(.center)
                    }
                    .padding(.horizontal, 90) // Adjust padding to center the text field
                }
            }
            .frame(maxHeight: .infinity, alignment: .top)
            .padding(.top, 200) // Adjust the top padding if needed
            
            if !keyboardObserver.isKeyboardVisible {
                NavigationLink(destination: Home(username: username).navigationBarBackButtonHidden(true),
                    isActive: $navigateToHome,
                    label: {
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
                )
                .padding(.bottom, 20)
                .simultaneousGesture(TapGesture().onEnded {
                    navigateToHome = true
                })
            }
        }
    }
}

extension Color {
    init(hex: String) {
        let scanner = Scanner(string: hex)
        scanner.scanLocation = 1 // Bypass the '#' character
        var rgb: UInt64 = 0
        scanner.scanHexInt64(&rgb)
        
        let red = Double((rgb >> 16) & 0xFF) / 255.0
        let green = Double((rgb >> 8) & 0xFF) / 255.0
        let blue = Double(rgb & 0xFF) / 255.0
        
        self.init(red: red, green: green, blue: blue)
    }
}

#Preview {
    Create()
}
