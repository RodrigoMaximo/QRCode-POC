import AVFoundation
import UIKit

protocol QRScannerViewControllerDelegate: class {
    func checkoutDidDetected(checkout: Checkout)
}

class QRScanerViewController: UIViewController {

    @IBOutlet weak var messageLabel: UILabel!

    weak var delegate: QRScannerViewControllerDelegate?

    private var captureSession = AVCaptureSession()
    private var videoPreviewLayer: AVCaptureVideoPreviewLayer?

    /// View to highlight the detected QR Code image.
    private var qrCodeFrameView: UIView?

    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }

    private func setup() {
        setupScan(detectedQRshouldHighlight: true)
        performScan()
    }

    /// Setup AVCaptureSession in order to be able to detect a QR Code.
    /// - Parameter detectedQRshouldHighlight: Determines if the QR Code should be highlighted when recognized.
    private func setupScan(detectedQRshouldHighlight: Bool) {
        guard let captureDevice = getCaptureDevice() else {
            print("Failed to get the camera device")
            return
        }

        do {
            // Get an instance of the AVCaptureDeviceInput class using the previous device object.
            let input = try AVCaptureDeviceInput(device: captureDevice)

            // Set the input device on the capture session.
            captureSession.addInput(input)

            // Initialize a AVCaptureMetadataOutput object and set it as the output device to the capture session.
            let captureMetadataOutput = AVCaptureMetadataOutput()
            captureSession.addOutput(captureMetadataOutput)

            // Set delegate and use the default dispatch queue to execute the call back
            captureMetadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            captureMetadataOutput.metadataObjectTypes = [AVMetadataObject.ObjectType.qr]
        } catch {
            // If any error occurs, simply print it out and don't continue any more.
            print(error)
            return
        }

        if detectedQRshouldHighlight {
            setupHighlightInDetectedQRCode()
        }
    }

    /// Starts to get video from camera, always trying to recognize a QR Code image.
    private func performScan() {
        // Initialize the video preview layer and add it as a sublayer to the viewPreview view's layer.
        videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        guard let videoPreviewLayer = self.videoPreviewLayer else {
            fatalError("VideoPreviewLayer is not defined")
        }
        videoPreviewLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
        videoPreviewLayer.frame = view.layer.bounds
        view.layer.addSublayer(videoPreviewLayer)

        // Start video capture.
        captureSession.startRunning()

        // Move the message label and top bar to the front
        view.bringSubviewToFront(messageLabel)
        messageLabel.isHidden = true
    }

    /// Returns the capture device
    private func getCaptureDevice() -> AVCaptureDevice? {
        var captureDevice: AVCaptureDevice?
        if #available(iOS 10.0, *) {
            // Get the back-facing camera for capturing videos. Find all available capture devices matching a specific device type.
            let deviceTypes: [AVCaptureDevice.DeviceType] = getPossibledeviceTypes()
            let deviceDiscoverySession = AVCaptureDevice.DiscoverySession(deviceTypes: deviceTypes, mediaType: AVMediaType.video, position: .back)

            guard let firstCaptureDevice = deviceDiscoverySession.devices.first else {
                return nil
            }
            captureDevice = firstCaptureDevice
        } else {
            // capture device to ios 9.0
            captureDevice = AVCaptureDevice.default(for: AVMediaType.video)
        }
        return captureDevice
    }

    @available(iOS 10.0, *)
    private func getPossibledeviceTypes() -> [AVCaptureDevice.DeviceType] {
        var deviceTypes: [AVCaptureDevice.DeviceType] = []
        if #available(iOS 11.1, *) {
            deviceTypes.append(.builtInTrueDepthCamera)
        }
        if #available(iOS 10.2, *) {
            deviceTypes.append(.builtInDualCamera)
        }
        deviceTypes.append(.builtInTelephotoCamera)
        deviceTypes.append(.builtInWideAngleCamera)

        return deviceTypes
    }

    /// Setup a view to highlight the detected QRCode.
    private func setupHighlightInDetectedQRCode() {
        // Initialize QR Code Frame to highlight the QR code
        qrCodeFrameView = UIView()

        if let qrCodeFrameView = qrCodeFrameView {
            qrCodeFrameView.layer.borderColor = UIColor.green.cgColor
            qrCodeFrameView.layer.borderWidth = 2
            view.addSubview(qrCodeFrameView)
            view.bringSubviewToFront(qrCodeFrameView)
        }
    }

    /// Deserialize a JSON data to a Codable object.
    /// - Parameters:
    ///   - objectType: Object that implements Codable protocol, in which the JSON data will be deserialized.
    ///   - jsonData: JSON data that will be deserialized.
    /// - Returns: An optional object, if deserialization was accomplished.
    private func deserializeJSON<T: Codable>(to objectType: T.Type, jsonData: Data?) -> T? {
        guard let jsonData = jsonData else {
            return nil
        }
        let jsonDecoder = JSONDecoder()
        let object = try? jsonDecoder.decode(objectType.self, from: jsonData)
        return object
    }
}

extension QRScanerViewController: AVCaptureMetadataOutputObjectsDelegate {
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        // Check if the metadataObjects array is not nil and it contains at least one object.
        if metadataObjects.count == 0 {
            renderFailScanning()
            return
        }

        // Get the metadata object.
        guard let metadataObj = metadataObjects[0] as? AVMetadataMachineReadableCodeObject else {
            renderFailScanning()
            return
        }

        // If the found metadata is equal to the QR code metadata
        if metadataObj.type == AVMetadataObject.ObjectType.qr {
            guard let barCodeObject = videoPreviewLayer?.transformedMetadataObject(for: metadataObj) else {
                renderFailScanning()
                return
            }

            // highlight detected QR Code and hide no detection label
            qrCodeFrameView?.frame = barCodeObject.bounds
            messageLabel.isHidden = true

            guard let detectedCheckout: Checkout = checkoutFromQRString(metadataObjStringValue: metadataObj.stringValue) else {
                renderFailScanning()
                return
            }
            delegate?.checkoutDidDetected(checkout: detectedCheckout)
            navigationController?.popViewController(animated: true)
        }
    }

    private func checkoutFromQRString<T: Codable>(metadataObjStringValue: String?) -> T? {
        guard let metadataObjStringValue = metadataObjStringValue else {
            return nil
        }
        let jsonData = metadataObjStringValue.data(using: .utf8)
        let detectedCheckout = deserializeJSON(to: T.self, jsonData: jsonData)
        return detectedCheckout
    }

    /// Render view information when fail in recognize a QR Code image.
    private func renderFailScanning() {
        messageLabel.isHidden = false
        qrCodeFrameView?.frame = CGRect.zero
        messageLabel.text = "No QR code is detected"
    }
}
