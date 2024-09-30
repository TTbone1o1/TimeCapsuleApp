import AVFoundation
import SwiftUI
import UIKit
import FirebaseAuth
import Firebase
import FirebaseFirestore

protocol CameraDelegate: AnyObject {
    func didTakePhoto()
    func showMessageButton()
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
        let outerCircle = UIButton(frame: CGRect(x: 0, y: 0, width: 56, height: 56))
        outerCircle.layer.cornerRadius = 56 / 2
        outerCircle.layer.borderWidth = 3
        outerCircle.layer.borderColor = UIColor.white.withAlphaComponent(0.5).cgColor
        outerCircle.backgroundColor = .clear

        let innerCircle = UIView(frame: CGRect(x: 9.5, y: 9.5, width: 37, height: 37))
        innerCircle.layer.cornerRadius = 37 / 2
        innerCircle.backgroundColor = UIColor.white

        outerCircle.addSubview(innerCircle)

        return outerCircle
    }()
    
    // Camera position (default is back camera)
    var currentCameraPosition: AVCaptureDevice.Position = .back
    // Timer duration (default is 0, meaning no timer)
    var selectedTimerDuration: Int = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        view.layer.addSublayer(previewLayer)
        view.addSubview(shutterButton)
        checkCameraPermissions()

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(didTapTakePhoto))
        shutterButton.addGestureRecognizer(tapGesture)

        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(didLongPressShutterButton))
        longPressGesture.minimumPressDuration = 0.3
        shutterButton.addGestureRecognizer(longPressGesture)

        let doubleTapGesture = UITapGestureRecognizer(target: self, action: #selector(didDoubleTapScreen))
        doubleTapGesture.numberOfTapsRequired = 2
        view.addGestureRecognizer(doubleTapGesture)

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

    @objc private func didTapTakePhoto() {
        let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
        impactFeedback.impactOccurred()

        checkIfPostedToday { [weak self] hasPostedToday in
            guard let self = self else { return }
            
            if hasPostedToday {
                self.delegate?.showMessageButton()
            } else {
                if self.selectedTimerDuration > 0 {
                    self.startCountdown()
                } else {
                    self.animateShutterButton()
                    self.output.capturePhoto(with: AVCapturePhotoSettings(), delegate: self)
                }
            }
        }
    }

    // Long press gesture to animate the shutter button
    @objc private func didLongPressShutterButton(_ gesture: UILongPressGestureRecognizer) {
        if gesture.state == .began {
            // Animate the button to become larger when the long press begins
            UIView.animate(withDuration: 0.2, animations: {
                self.shutterButton.transform = CGAffineTransform(scaleX: 1.5, y: 1.5)
            })
        } else if gesture.state == .ended || gesture.state == .cancelled {
            // Animate the button back to its original size when the long press ends
            UIView.animate(withDuration: 0.2, animations: {
                self.shutterButton.transform = CGAffineTransform.identity
            })
        }
    }

    // Double tap gesture to switch camera
    @objc private func didDoubleTapScreen() {
        toggleCamera()
    }

    // Toggle between front and back camera
    private func toggleCamera() {
        guard let session = session else { return }
        session.beginConfiguration()
        
        // Remove existing input
        if let currentInput = session.inputs.first as? AVCaptureDeviceInput {
            session.removeInput(currentInput)
        }
        
        // Toggle the camera
        currentCameraPosition = (currentCameraPosition == .back) ? .front : .back
        
        // Add new input for the selected camera
        guard let newDevice = camera(for: currentCameraPosition),
              let newInput = try? AVCaptureDeviceInput(device: newDevice),
              session.canAddInput(newInput) else {
            return
        }

        session.addInput(newInput)
        session.commitConfiguration()
    }

    // Helper function to get the camera for a given position
    private func camera(for position: AVCaptureDevice.Position) -> AVCaptureDevice? {
        let devices = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInWideAngleCamera], mediaType: .video, position: .unspecified).devices
        return devices.first(where: { $0.position == position })
    }

    // Start countdown before taking a photo
    private func startCountdown() {
        var countdown = selectedTimerDuration
        
        let countdownLabel = UILabel()
        countdownLabel.font = UIFont.systemFont(ofSize: 100, weight: .bold)
        countdownLabel.textColor = .white
        countdownLabel.textAlignment = .center
        countdownLabel.frame = view.bounds
        countdownLabel.alpha = 0
        view.addSubview(countdownLabel)
        
        func animateCountdown() {
            if countdown > 0 {
                countdownLabel.text = "\(countdown)"
                countdownLabel.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
                UIView.animate(withDuration: 0.5,
                               delay: 0,
                               usingSpringWithDamping: 0.5,
                               initialSpringVelocity: 1.5,
                               options: [],
                               animations: {
                                   countdownLabel.alpha = 1
                                   countdownLabel.transform = CGAffineTransform.identity
                               }, completion: { _ in
                                   UIView.animate(withDuration: 0.5, animations: {
                                       countdownLabel.alpha = 0
                                   }) { _ in
                                       countdown -= 1
                                       animateCountdown()
                                   }
                               })
            } else {
                countdownLabel.removeFromSuperview()
                self.animateShutterButton()
                self.output.capturePhoto(with: AVCapturePhotoSettings(), delegate: self)
            }
        }
        
        animateCountdown()
    }

    private func animateShutterButton() {
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
        if let device = camera(for: currentCameraPosition) {
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

    private func checkIfPostedToday(completion: @escaping (Bool) -> Void) {
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
        
        delegate?.didTakePhoto()
        
        showPostView(with: image)
        shutterButton.isHidden = true
    }
}
