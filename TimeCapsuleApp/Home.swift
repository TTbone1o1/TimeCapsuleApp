import SwiftUI
import Firebase
import FirebaseAuth

import FirebaseFirestore
import AuthenticationServices

struct Home: View {
    @State private var username: String = ""
    @State private var imagesAppeared = false
    
    var body: some View {
        NavigationView {
            VStack {
                HStack {
                    Text(username.isEmpty ? "No Username" : username) // Display the username
                        .font(.system(size: 18))
                        .fontWeight(.bold)
                        .padding()
                    
                    Spacer()
                    
                    Button(action: {
                        // Action for button
                    }, label: {
                        VStack(spacing: 2) {
                            ForEach(0..<3) { _ in
                                Rectangle()
                                    .frame(width: 16, height: 3)
                                    .cornerRadius(20)
                                    .foregroundColor(.black)
                            }
                        }
                        .padding(.trailing)
                    })
                }
                
                Spacer()
                
                Text("Take a photo to start")
                    .font(.system(size: 18))
                    .padding(.bottom, 30)
                    .fontWeight(.bold)
                
                HStack {
                    Spacer()
                    
                    HStack {
                        Image("1")
                            .resizable()
                            .frame(width: 82.37, height: 120.26)
                            .cornerRadius(19)
                            .overlay(
                                RoundedRectangle(cornerRadius: 19)
                                    .stroke(Color.white, lineWidth: 4)
                            )
                            .rotationEffect(Angle(degrees: -16))
                            .offset(x: 25, y: 15)
                            .shadow(radius: 24, x: 0, y: 14)
                            .zIndex(3)
                            .scaleEffect(imagesAppeared ? 1 : 0)
                            .animation(.interpolatingSpring(stiffness: 60, damping: 7).delay(0.1), value: imagesAppeared)
                            .onAppear {
                                if imagesAppeared {
                                    triggerHaptic()
                                }
                            }
                        
                        Image("2")
                            .resizable()
                            .frame(width: 82.37, height: 120.26)
                            .cornerRadius(19)
                            .overlay(
                                RoundedRectangle(cornerRadius: 19)
                                    .stroke(Color.white, lineWidth: 4)
                            )
                            .zIndex(2)
                            .rotationEffect(Angle(degrees: -2))
                            .shadow(radius: 24, x: 0, y: 14)
                            .scaleEffect(imagesAppeared ? 1 : 0)
                            .animation(.interpolatingSpring(stiffness: 60, damping: 7).delay(0.2), value: imagesAppeared)
                            .onAppear {
                                if imagesAppeared {
                                    triggerHaptic()
                                }
                            }
                        
                        Image("3")
                            .resizable()
                            .frame(width: 82.37, height: 120.26)
                            .cornerRadius(19)
                            .overlay(
                                RoundedRectangle(cornerRadius: 19)
                                    .stroke(Color.white, lineWidth: 4)
                            )
                            .zIndex(1)
                            .rotationEffect(Angle(degrees: 17))
                            .shadow(radius: 24, x: 0, y: 14)
                            .offset(x: -33, y: 15)
                            .scaleEffect(imagesAppeared ? 1 : 0)
                            .animation(.interpolatingSpring(stiffness: 60, damping: 7).delay(0.3), value: imagesAppeared)
                            .onAppear {
                                if imagesAppeared {
                                    triggerHaptic()
                                }
                            }
                    }
                    Spacer()
                }
                
                Spacer()
                
                HStack {
                    NavigationLink(destination: CameraController()
                        .edgesIgnoringSafeArea(.all)
                    ) {
                        ZStack {
                            Circle()
                                .stroke(Color.gray, lineWidth: 3)
                                .frame(width: 24, height: 24)
                            
                            Circle()
                                .frame(width: 13, height: 13)
                                .foregroundColor(.gray)
                        }
                    }
                    
                    Spacer()
                        .frame(width: 72)
                    Button(action: {
                        // Action for button
                    }, label: {
                        Image("Notebook")
                    })
                }
            }
            .padding()
            .frame(maxHeight: .infinity)
            .onAppear {
                fetchUsername()
                imagesAppeared = true
                triggerHaptic()
            }
            .onDisappear {
                imagesAppeared = false
            }
        }
    }
    
    private func fetchUsername() {
        guard let user = Auth.auth().currentUser else { return }
        let db = Firestore.firestore()
        let usernameDocRef = db.collection("users").document(user.uid).collection("username").document("info")
        
        usernameDocRef.getDocument { document, error in
            if let document = document, document.exists {
                let username = document.data()?["username"] as? String
                self.username = username ?? ""
            } else {
                print("Username not found in Firestore")
                self.username = "No Username"
            }
        }
    }
    
    
    private func triggerHaptic() {
        let generator = UINotificationFeedbackGenerator()
        generator.prepare()
        generator.notificationOccurred(.success)
    }
}

#Preview {
    Home()
}
