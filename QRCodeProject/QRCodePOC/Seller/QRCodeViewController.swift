import UIKit

class QRCodeViewController: UIViewController {

    @IBOutlet weak var qrCodeImage: UIImageView!

    var qrCodeText: String?

    override func viewDidLoad() {
        super.viewDidLoad()

        if let qrCodeText = self.qrCodeText {
            qrCodeImage.image = generateQRCode(from: qrCodeText)
        }
    }
    
    @IBAction func scanAction(_ sender: UIButton) {
        performSegue(withIdentifier: "scanSegue", sender: self)
    }
    
    @IBAction func didTouchShare(_ sender: UIButton) {
        guard let image = takeScreenshot(in: qrCodeImage) else { return }
        let activityViewController = UIActivityViewController(activityItems: [image], applicationActivities: nil)
        activityViewController.popoverPresentationController?.sourceView = self.view
        self.present(activityViewController, animated: true, completion: nil)
    }
    
    private func takeScreenshot(in view: UIView) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(view.bounds.size, view.isOpaque, 0)
        view.drawHierarchy(in: view.bounds, afterScreenUpdates: false)
        let snapshotImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return snapshotImage
    }

    /// Generates a QR Code from a string.
    /// - Parameter string: Input String, responsible for generating an UIImage QR Code.
    /// - Returns: A QR Code image.
    private func generateQRCode(from string: String) -> UIImage? {
        let data = string.data(using: String.Encoding.ascii, allowLossyConversion: false)

        guard let filter = CIFilter(name: "CIQRCodeGenerator") else {
            return nil
        }

        filter.setValue(data, forKey: "inputMessage")

        guard let ciImage = filter.outputImage else {
            return nil
        }

        // Rescale the generated qrCodeCIImage in order to be in a good resolution in the UIImage
        let scaleX = qrCodeImage.frame.size.width / ciImage.extent.size.width
        let scaleY = qrCodeImage.frame.size.height / ciImage.extent.size.height
        let transformedImage = ciImage.transformed(by: CGAffineTransform(scaleX: scaleX, y: scaleY))

        return UIImage(ciImage: transformedImage)
    }

    /// Loads data from a JSON file.
    /// - Returns: Read Data.
    private func loadDataFromJSON() -> Data? {
        let fileName = "Data"
        let fileExtension = "json"
        guard let url = Bundle.main.url(forResource: fileName, withExtension: fileExtension) else {
            return nil
        }
        let data = try? Data(contentsOf: url)
        return data
    }
}
