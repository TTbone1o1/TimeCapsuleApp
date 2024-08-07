import AVFoundation
import UIKit

class Camera: UIViewController {
    // Capture Session
    var session: AVCaptureSession?
    // Photo Output
    let output = AVCapturePhotoOutput()
    // Video Preview
    let previewLayer = AVCaptureVideoPreviewLayer()
    
    // Shutter button
    private let shutterButton: UIButton = {
        let outerCircle = UIButton(frame: CGRect(x: 0, y: 0, width: 75, height: 75))
        outerCircle.layer.cornerRadius = 37.5
        outerCircle.layer.borderWidth = 2
        outerCircle.layer.borderColor = UIColor.white.cgColor
        outerCircle.backgroundColor = .clear

        let innerCircle = UIView(frame: CGRect(x: 5, y: 5, width: 65, height: 65))
        innerCircle.layer.cornerRadius = 32.5
        innerCircle.backgroundColor = .white

        outerCircle.addSubview(innerCircle)
        return outerCircle
    }()
    
    // whitbutton image button
    private let whiteButton: UIButton = {
        let button = UIButton(type: .custom)
        let outerCircle = UIView(frame: CGRect(x: 0, y: 0, width: 24, height: 24))
        outerCircle.layer.cornerRadius = 12
        outerCircle.layer.borderWidth = 3
        outerCircle.layer.borderColor = UIColor.gray.cgColor
        outerCircle.backgroundColor = .clear

        let innerCircle = UIView(frame: CGRect(x: 5.5, y: 5.5, width: 13, height: 13))
        innerCircle.layer.cornerRadius = 6.5
        innerCircle.backgroundColor = .gray

        outerCircle.addSubview(innerCircle)
        button.addSubview(outerCircle)
        button.frame = CGRect(x: 0, y: 0, width: 24, height: 24)
        return button
    }()
    
    private let noteBookButton: UIButton = {
        let button = UIButton(type: .custom)
        button.frame = CGRect(x: 0, y: 0, width: 24, height: 24)
        
        // Set the NoteBook image
        let image = UIImage(named: "Notebook")?.withRenderingMode(.alwaysTemplate)
        button.setImage(image, for: .normal)
        button.imageView?.contentMode = .scaleAspectFit

        button.tintColor = .white // Change this to your desired color
        return button
    }()



    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black // Set background color to black to better see the preview
        view.layer.addSublayer(previewLayer) // Ensure the previewLayer is added to the view's layer
        view.addSubview(shutterButton)
        view.addSubview(whiteButton)
        view.addSubview(noteBookButton) // Add the noteBookButton to the view
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
        let shutterButtonY = view.frame.size.height - safeAreaInsets.bottom - 75 / 2
        shutterButton.center = CGPoint(x: view.frame.size.width / 2, y: shutterButtonY)
        
        // Position the whiteButton to the right of the shutterButton
        let whiteButtonX = shutterButton.frame.minX - 40
        whiteButton.center = CGPoint(x: whiteButtonX, y: shutterButtonY)
        
        // Position the noteBookButton to the right of the whiteButton
        let noteBookButtonX = whiteButton.frame.maxX + 140 // Adjust spacing as needed
        noteBookButton.center = CGPoint(x: noteBookButtonX, y: shutterButtonY)
        
        view.bringSubviewToFront(shutterButton)
        view.bringSubviewToFront(whiteButton)
        view.bringSubviewToFront(noteBookButton) // Ensure the noteBookButton is on top
    }


    private func checkCameraPermissions() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .notDetermined:
            // Request
            AVCaptureDevice.requestAccess(for: .video) { [weak self] granted in
                guard granted else { return }
                DispatchQueue.main.async {
                    self?.setupCamera()
                }
            }
        case .restricted, .denied:
            // Handle restricted/denied case
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
                view.layer.addSublayer(previewLayer) // Ensure the previewLayer is added to the view's layer

                session.startRunning()
                self.session = session
            } catch {
                print(error)
            }
        }
    }

    @objc private func didTapTakePhoto() {
        // Add enhanced bouncing animation
        UIView.animate(withDuration: 0.1, // Initial scale down duration
                       animations: {
                           self.shutterButton.transform = CGAffineTransform(scaleX: 0.6, y: 0.6)
                       },
                       completion: { _ in
                           UIView.animate(withDuration: 0.2, // Bounce up duration
                                          delay: 0,
                                          usingSpringWithDamping: 0.5,
                                          initialSpringVelocity: 1.5,
                                          options: .allowUserInteraction,
                                          animations: {
                                              self.shutterButton.transform = CGAffineTransform(scaleX: 1.1, y: 1.1)
                                          },
                                          completion: { _ in
                                              UIView.animate(withDuration: 0.1, // Return to normal size duration
                                                             animations: {
                                                                 self.shutterButton.transform = CGAffineTransform.identity
                                                                 self.shutterButton.alpha = 0
                                                             },
                                                             completion: { _ in
                                                                 self.shutterButton.isHidden = true // Hide the shutter button after animation
                                                             })
                                          })
                       })

        output.capturePhoto(with: AVCapturePhotoSettings(), delegate: self)
    }
}

extension Camera: AVCapturePhotoCaptureDelegate {
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        guard let data = photo.fileDataRepresentation(), let image = UIImage(data: data) else {
            return
        }
        session?.stopRunning() // Stop the camera session

        // Display captured image in imageView
        let imageView = UIImageView(image: image)
        imageView.frame = view.bounds
        imageView.contentMode = .scaleAspectFill
        imageView.backgroundColor = .black // Optional: Set background color for visibility
        imageView.isUserInteractionEnabled = true // Enable user interaction
        view.addSubview(imageView)
        
        // Add tap gesture recognizer to imageView
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(didTapImageView))
        imageView.addGestureRecognizer(tapGesture)
        
        // Hide the shutter button
        shutterButton.isHidden = true
    }

    @objc private func didTapImageView() {
        // Remove the image view
        if let imageView = view.subviews.last as? UIImageView {
            imageView.removeFromSuperview()
        }
        // Restart the camera session
        session?.startRunning()
        // Show the shutter button again
        shutterButton.isHidden = false
        UIView.animate(withDuration: 0.3) {
            self.shutterButton.alpha = 1
        }
    }
}
