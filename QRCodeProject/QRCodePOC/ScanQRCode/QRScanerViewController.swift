//
//  ScanViewController.swift
//  QRCodePOC
//
//  Created by Rodrigo Noronha on 01/10/18.
//  Copyright © 2018 Rodrigo Noronha. All rights reserved.
//

import AVFoundation
import UIKit

class QRScanerViewController: UIViewController {

    @IBOutlet weak var messageLabel: UILabel!
    
    var captureSession = AVCaptureSession()
    var videoPreviewLayer: AVCaptureVideoPreviewLayer?
    var qrCodeFrameView: UIView?

    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }

    private func setup() {
        setupScan()
        performScan()
        highlightDetectedQRCode()
    }

    @available(iOS 10.0, *)
    private func getPossibledeviceTypes() -> [AVCaptureDevice.DeviceType] {
        var deviceTypes: [AVCaptureDevice.DeviceType] = []
        deviceTypes.append(.builtInWideAngleCamera)
        deviceTypes.append(.builtInTelephotoCamera)

        if #available(iOS 10.2, *) {
            deviceTypes.append(.builtInDualCamera)
        }
        if #available(iOS 11.1, *) {
            deviceTypes.append(.builtInTrueDepthCamera)
        }
        return deviceTypes
    }

    private func setupScan() {
        var captureDevice: AVCaptureDevice!
        if #available(iOS 10.0, *) {
            // Get the back-facing camera for capturing videos. Find all available capture devices matching a specific device type.
            let deviceTypes: [AVCaptureDevice.DeviceType] = getPossibledeviceTypes()
            print(deviceTypes)
            let deviceDiscoverySession = AVCaptureDevice.DiscoverySession(deviceTypes: deviceTypes, mediaType: AVMediaType.video, position: .back)

            guard let firstCaptureDevice = deviceDiscoverySession.devices.first else {
                print("Failed to get the camera device")
                return
            }
            captureDevice = firstCaptureDevice
        } else {
            // Get an instance of the AVCaptureDevice class to initialize a device object and provide the video
            // as the media type parameter.
            captureDevice = AVCaptureDevice.default(for: AVMediaType.video)
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
    }

    private func performScan() {
        // Initialize the video preview layer and add it as a sublayer to the viewPreview view's layer.
        videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        guard let unwrappedVideoPreviewLayer = videoPreviewLayer else {
            fatalError("VideoPreviewLayer is not defined")
        }
        unwrappedVideoPreviewLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
        unwrappedVideoPreviewLayer.frame = view.layer.bounds
        view.layer.addSublayer(unwrappedVideoPreviewLayer)

        // Start video capture.
        captureSession.startRunning()

        // Move the message label and top bar to the front
        view.bringSubviewToFront(messageLabel)
    }

    private func highlightDetectedQRCode() {
        // Initialize QR Code Frame to highlight the QR code
        qrCodeFrameView = UIView()

        if let qrCodeFrameView = qrCodeFrameView {
            qrCodeFrameView.layer.borderColor = UIColor.green.cgColor
            qrCodeFrameView.layer.borderWidth = 2
            view.addSubview(qrCodeFrameView)
            view.bringSubviewToFront(qrCodeFrameView)
        }
    }
}

extension QRScanerViewController: AVCaptureMetadataOutputObjectsDelegate {
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        // Check if the metadataObjects array is not nil and it contains at least one object.
        if metadataObjects.count == 0 {
            renderFailInScan()
            return
        }

        // Get the metadata object.
        guard let metadataObj = metadataObjects[0] as? AVMetadataMachineReadableCodeObject else {
            renderFailInScan()
            return
        }

        // If the found metadata is equal to the QR code metadata
        if metadataObj.type == AVMetadataObject.ObjectType.qr {
            guard let barCodeObject = videoPreviewLayer?.transformedMetadataObject(for: metadataObj) else {
                renderFailInScan()
                return
            }

            // highlight detected QR Code
            qrCodeFrameView?.frame = barCodeObject.bounds

            // detected text
            if metadataObj.stringValue != nil {
                messageLabel.text = metadataObj.stringValue
            }
        }
    }
    private func renderFailInScan() {
        qrCodeFrameView?.frame = CGRect.zero
        messageLabel.text = "No QR code is detected"
    }
}
