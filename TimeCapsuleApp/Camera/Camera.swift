import AVFoundation
import SwiftUI
import UIKit
import FirebaseAuth
import Firebase
import FirebaseFirestore

protocol CameraDelegate: AnyObject {
    func didTakePhoto()
    func showMessageButton() // Add this delegate function to show the message button when necessary
}

class Camera: UIViewController {
    // Capture Session
    var session: AVCaptureSession?
    // Photo Output
    let output = AVCapturePhotoOutput()
    // Video Preview
    let previewLayer = AVCaptureVideoPreviewLayer()

    weak var delegate: CameraDelegate?

    // Shutter button
    private let shutterButton: UIButton = {
        // Outer circle (stroked)
        let outerCircle = UIButton(frame: CGRect(x: 0, y: 0, width: 56, height: 56))
        outerCircle.layer.cornerRadius = 56 / 2 // Make it circular
        outerCircle.layer.borderWidth = 3 // Stroke width
        outerCircle.layer.borderColor = UIColor.white.withAlphaComponent(0.5).cgColor // Stroke color with opacity
        outerCircle.backgroundColor = .clear // Transparent background

        // Inner circle (filled)
        let innerCircle = UIView(frame: CGRect(x: 9.5, y: 9.5, width: 37, height: 37)) // Positioned inside the outer circle with padding
        innerCircle.layer.cornerRadius = 37 / 2 // Make it circular
        innerCircle.backgroundColor = UIColor.white // Fill color

        // Add innerCircle to outerCircle
        outerCircle.addSubview(innerCircle)

        return outerCircle
    }()

    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        view.layer.addSublayer(previewLayer)
        view.addSubview(shutterButton)
        checkCameraPermissions()

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(didTapTakePhoto))
        shutterButton.addGestureRecognizer(tapGesture)

        // Set edgesForExtendedLayout to none
        edgesForExtendedLayout = []
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        previewLayer.frame = view.bounds
        previewLayer.videoGravity = .resizeAspectFill

        let safeAreaInsets = view.safeAreaInsets
        let shutterButtonY = view.frame.size.height - safeAreaInsets.bottom - 65 / 2
        shutterButton.center = CGPoint(x: view.frame.size.width / 2, y: shutterButtonY)
        
        view.bringSubviewToFront(shutterButton)
    }

    private func checkCameraPermissions() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { [weak self] granted in
                guard granted else { return }
                DispatchQueue.main.async {
                    self?.setupCamera()
                }
            }
        case .restricted, .denied:
            break
        case .authorized:
            setupCamera()
        @unknown default:
            break
        }
    }

    private func setupCamera() {
        let session = AVCaptureSession()
        if let device = AVCaptureDevice.default(for: .video) {
            do {
                let input = try AVCaptureDeviceInput(device: device)
                if session.canAddInput(input) {
                    session.addInput(input)
                }

                if session.canAddOutput(output) {
                    session.addOutput(output)
                }

                previewLayer.videoGravity = .resizeAspectFill
                previewLayer.session = session
                view.layer.addSublayer(previewLayer)

                session.startRunning()
                self.session = session
            } catch {
                print(error)
            }
        }
    }

    @objc private func didTapTakePhoto() {
        // Check if the user has posted today before deciding what to do
        checkIfPostedToday { [weak self] hasPostedToday in
            guard let self = self else { return }
            
            if hasPostedToday {
                // User has already posted today, show the MessageButton instead of taking the photo
                print("User has posted today. Showing MessageButton instead of taking a photo.")
                self.delegate?.showMessageButton()
            } else {
                // User has not posted today, proceed with the photo-taking animation and capture
                self.animateShutterButton()

                self.output.capturePhoto(with: AVCapturePhotoSettings(), delegate: self)
            }
        }
    }

    private func animateShutterButton() {
        // Shutter button animation
        UIView.animate(withDuration: 0.1,
                       animations: {
                           self.shutterButton.transform = CGAffineTransform(scaleX: 0.6, y: 0.6)
                       },
                       completion: { _ in
                           UIView.animate(withDuration: 0.2,
                                          delay: 0,
                                          usingSpringWithDamping: 0.5,
                                          initialSpringVelocity: 1.5,
                                          options: .allowUserInteraction,
                                          animations: {
                                              self.shutterButton.transform = CGAffineTransform(scaleX: 1.1, y: 1.1)
                                          },
                                          completion: { _ in
                                              UIView.animate(withDuration: 0.1,
                                                             animations: {
                                                                 self.shutterButton.transform = CGAffineTransform.identity
                                                                 self.shutterButton.alpha = 0
                                                             },
                                                             completion: { _ in
                                                                 self.shutterButton.isHidden = true
                                                             })
                                          })
                       })
    }

    private func checkIfPostedToday(completion: @escaping (Bool) -> Void) {
        // This function checks Firestore to see if the user has posted today
        guard let user = Auth.auth().currentUser else {
            print("No user is currently authenticated.")
            completion(false)
            return
        }
        
        let db = Firestore.firestore()
        let photosCollectionRef = db.collection("users").document(user.uid).collection("photos")
        
        let today = Calendar.current.startOfDay(for: Date())
        let query = photosCollectionRef.whereField("timestamp", isGreaterThanOrEqualTo: today)
            .whereField("timestamp", isLessThan: Calendar.current.date(byAdding: .day, value: 1, to: today)!)
        
        query.getDocuments { snapshot, error in
            if let snapshot = snapshot {
                let hasPosted = !snapshot.isEmpty
                completion(hasPosted)
            } else {
                print("Error checking if posted today: \(error?.localizedDescription ?? "Unknown error")")
                completion(false)
            }
        }
    }

    private func showPostView(with image: UIImage) {
        let postView = PostView(selectedImage: image)
        let hostingController = UIHostingController(rootView: postView)
        addChild(hostingController)
        view.addSubview(hostingController.view)
        hostingController.didMove(toParent: self)

        // Position the PostView
        hostingController.view.translatesAutoresizingMaskIntoConstraints = false
        hostingController.view.backgroundColor = .clear

        NSLayoutConstraint.activate([
            hostingController.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            hostingController.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            hostingController.view.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            hostingController.view.topAnchor.constraint(equalTo: view.topAnchor)
        ])
    }

    private func removePostView() {
        for subview in view.subviews {
            if let hostingController = subview.next as? UIHostingController<AnyView> {
                hostingController.willMove(toParent: nil)
                hostingController.view.removeFromSuperview()
                hostingController.removeFromParent()
            }
        }
    }
}

extension Camera: AVCapturePhotoCaptureDelegate {
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        guard let data = photo.fileDataRepresentation(), let image = UIImage(data: data) else {
            return
        }
        session?.stopRunning()
        
        // Notify delegate that photo was taken
        delegate?.didTakePhoto()
        
        // Show the PostView
        showPostView(with: image)
        shutterButton.isHidden = true
    }
}
