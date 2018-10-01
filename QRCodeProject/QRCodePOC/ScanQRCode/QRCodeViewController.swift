import UIKit

class QRCodeViewController: UIViewController {

    @IBOutlet weak var scanButton: UIButton!
    @IBOutlet weak var qrCodeImage: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        qrCodeImage.image = generateQRCode(from: "https://www.appcoda.com")
    }
    
    @IBAction func scanAction(_ sender: UIButton) {
        performSegue(withIdentifier: "scanSegue", sender: self)
    }

    private func generateQRCode(from string: String) -> UIImage? {
//        let data = string.data(using: String.Encoding.ascii)
        let data = string.data(using: String.Encoding.isoLatin1, allowLossyConversion: false)

        guard let filter = CIFilter(name: "CIQRCodeGenerator") else {
            return nil
        }

        filter.setValue(data, forKey: "inputMessage")
        filter.setValue("Q", forKey: "inputCorrectionLevel")

        guard let ciImage = filter.outputImage else {
            return nil
        }

        // Rescale the generated qrCodeCIImage in order to be in a good resolution in the UIImage
        let scaleX = qrCodeImage.frame.size.width / ciImage.extent.size.width
        let scaleY = qrCodeImage.frame.size.height / ciImage.extent.size.height
        let transformedImage = ciImage.transformed(by: CGAffineTransform(scaleX: scaleX, y: scaleY))

        return UIImage(ciImage: transformedImage)
    }
}
