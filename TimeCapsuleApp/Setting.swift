import SwiftUI
import FirebaseAuth
import FirebaseFirestore
import FirebaseStorage

struct Setting: View {
    @Environment(\.presentationMode) var presentationMode
    @Binding var isShowing: Bool
    @Binding var isSignedOut: Bool
    @Environment(\.colorScheme) var colorScheme
    var onChangeProfilePicture: (() -> Void)?

    @State private var showDeleteConfirmation = false // Confirmation dialog state
    @State private var navigateToTimecap = false // State to trigger navigation to Timecap

    var body: some View {
        ZStack(alignment: .bottom) {
            Color.black
                .opacity(0.3)
                .ignoresSafeArea()
                .onTapGesture {
                    let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
                    impactFeedback.impactOccurred()
                    isShowing = false
                }

            mainView
                .transition(.move(edge: .bottom))
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
        .ignoresSafeArea()
        .animation(.easeInOut, value: isShowing)
        .navigationViewStyle(.stack) // Ensure navigation behaves in stack mode
    }

    var mainView: some View {
        VStack {
            ZStack {
                Capsule()
                    .foregroundColor(.gray)
                    .opacity(0.4)
                    .frame(width: 40, height: 6)
            }
            .frame(height: 40)
            .frame(maxWidth: .infinity)
            .offset(y: 5)

            VStack {
                Spacer()

                ZStack {
                    Rectangle()
                        .frame(width: 291, height: 62)
                        .cornerRadius(40)
                        .foregroundColor(colorScheme == .dark ? .white : .black)
                        .shadow(radius: 24, x: 0, y: 14)
                        .overlay(
                            Text("Change profile picture")
                                .foregroundColor(colorScheme == .dark ? .black : .white)
                                .font(.system(size: 16, weight: .bold, design: .rounded))
                        )
                        .onTapGesture {
                            onChangeProfilePicture?()
                        }
                }

                Spacer().frame(height: 20)

                // Button to log out with custom UIAlert
                Button(action: {
                    showLogoutAlert() // Call custom alert for logout confirmation
                }) {
                    Text("Log out")
                        .foregroundColor(.gray)
                        .font(.system(size: 16, weight: .bold, design: .rounded))
                        .padding()
                }

                // Button to delete account with confirmation dialog
                Button(action: {
                    showDeleteConfirmation = true
                }) {
                    Text("Delete Account")
                        .foregroundColor(.red)
                        .font(.system(size: 16, weight: .bold, design: .rounded))
                        .padding()
                }
                .confirmationDialog("Are you sure you want to delete your account?", isPresented: $showDeleteConfirmation) {
                    Button("Delete", role: .destructive) {
                        Task {
                            await deleteUserData()
                        }
                    }
                    Button("Cancel", role: .cancel) {}
                }

                // Navigation link to Timecap after deletion or sign out
                NavigationLink(destination: Timecap().navigationBarBackButtonHidden(true), isActive: $navigateToTimecap) {
                    EmptyView()
                }
            }
            .padding(.horizontal, 30)
            .padding(.bottom, 55)
        }
        .frame(height: 261)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 30)
                .foregroundColor(colorScheme == .dark ? .black : .white)
        )
    }

    // MARK: - Custom UIAlert for Logout
    private func showLogoutAlert() {
        guard let window = UIApplication.shared.windows.first else { return }

        let alert = UIAlertController(
            title: "Log out",
            message: "Are you sure you want to log out?",
            preferredStyle: .alert
        )

        alert.addAction(UIAlertAction(title: "No", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Yes", style: .destructive, handler: { _ in
            Task {
                await handleSignOut() // Log the user out and navigate to Timecap
            }
        }))

        window.rootViewController?.present(alert, animated: true, completion: nil)
    }

    // Async function to handle sign-out and trigger navigation
    private func handleSignOut() async {
        do {
            try Auth.auth().signOut()
            isSignedOut = true
            navigateToTimecap = true // Trigger navigation to Timecap after signing out
        } catch let signOutError as NSError {
            print("Error signing out: \(signOutError)")
        }
    }

    // Function to delete user data
    private func deleteUserData() async {
        guard let user = Auth.auth().currentUser else {
            print("No user is currently logged in")
            return
        }

        let uid = user.uid
        let db = Firestore.firestore()
        let storage = Storage.storage()

        // Reference to the user document
        let userRef = db.collection("users").document(uid)

        // Delete Firestore data and subcollections
        await deleteSubcollectionsAndDocument(documentRef: userRef)

        // Delete the user from Firebase Storage (Assuming images are stored under `users/{uid}/`)
        let storageRef = storage.reference().child("users/\(uid)")
        await deleteStorageFiles(storageRef)

        // Finally delete the user's Firebase Authentication account
        deleteUserAuthentication(user: user)
    }

    // Helper function to delete Firebase Storage folder contents
    private func deleteStorageFiles(_ storageRef: StorageReference) async {
        storageRef.listAll { result, error in
            if let error = error {
                print("Error listing storage files: \(error.localizedDescription)")
                return
            }

            guard let result = result else {
                print("Failed to get storage result")
                return
            }

            let dispatchGroup = DispatchGroup()

            // Delete all files
            for item in result.items {
                dispatchGroup.enter()
                item.delete { error in
                    if let error = error {
                        print("Error deleting file: \(error.localizedDescription)")
                    } else {
                        print("Successfully deleted storage file: \(item.fullPath)")
                    }
                    dispatchGroup.leave()
                }
            }

            // Delete any subfolders
            for folder in result.prefixes {
                dispatchGroup.enter()
                deleteFolderContents(folder) {
                    dispatchGroup.leave()
                }
            }

            dispatchGroup.notify(queue: .main) {
                print("All storage files deleted")
            }
        }
    }

    // Helper function to delete all folder contents in Firebase Storage
    private func deleteFolderContents(_ folderRef: StorageReference, completion: @escaping () -> Void) {
        folderRef.listAll { result, error in
            if let error = error {
                print("Error listing folder contents: \(error.localizedDescription)")
                completion()
                return
            }

            guard let result = result else {
                print("Failed to get folder result")
                completion()
                return
            }

            let dispatchGroup = DispatchGroup()

            // Delete files inside the folder
            for fileRef in result.items {
                dispatchGroup.enter()
                fileRef.delete { error in
                    if let error = error {
                        print("Error deleting file in folder: \(error.localizedDescription)")
                    } else {
                        print("Successfully deleted file in folder: \(fileRef.fullPath)")
                    }
                    dispatchGroup.leave()
                }
            }

            // Recursively delete subfolders
            for subfolder in result.prefixes {
                dispatchGroup.enter()
                deleteFolderContents(subfolder) {
                    dispatchGroup.leave()
                }
            }

            dispatchGroup.notify(queue: .main) {
                completion()
            }
        }
    }

    // Helper function to delete Firestore subcollections and the document itself
    private func deleteSubcollectionsAndDocument(documentRef: DocumentReference) async {
        let subcollections = ["photos", "username"]
        let batch = Firestore.firestore().batch()

        for subcollection in subcollections {
            let collectionRef = documentRef.collection(subcollection)
            let documents = try? await collectionRef.getDocuments()

            documents?.documents.forEach { document in
                batch.deleteDocument(document.reference)
            }
        }

        batch.deleteDocument(documentRef)
        do {
            try await batch.commit()
            print("Firestore data deleted")
        } catch {
            print("Error deleting Firestore data: \(error.localizedDescription)")
        }
    }

    // Helper function to delete Firebase Authentication user
    private func deleteUserAuthentication(user: User) {
        user.delete { error in
            if let error = error {
                print("Error deleting user: \(error.localizedDescription)")
            } else {
                navigateToTimecap = true // After deletion, navigate to Timecap
            }
        }
    }
}

struct Setting_Previews: PreviewProvider {
    @State static var isShowing = true
    @State static var isSignedOut = false

    static var previews: some View {
        Setting(isShowing: $isShowing, isSignedOut: $isSignedOut, onChangeProfilePicture: {})
            .previewLayout(.sizeThatFits)
            .padding()
    }
}
