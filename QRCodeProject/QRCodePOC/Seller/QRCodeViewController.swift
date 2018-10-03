import UIKit

class QRCodeViewController: UIViewController {

    @IBOutlet weak var qrCodeImage: UIImageView!

    var qrCodeCheckout: Checkout?

    override func viewDidLoad() {
        super.viewDidLoad()

        if let checkoutJSON = serializeToJSON(object: qrCodeCheckout) {
            qrCodeImage.image = generateQRCode(from: checkoutJSON)
        }
    }

    @IBAction func scanAction(_ sender: UIButton) {
        performSegue(withIdentifier: "scanSegue", sender: self)
    }

    /// Serialize a Codable object to a JSON. This JSON is places in a String.
    /// - Parameter object: Object that will be serialized.
    /// - Returns: Serialized JSON in a String format.
    private func serializeToJSON<T: Codable>(object: T) -> String? {
        let jsonEncoder = JSONEncoder()

        jsonEncoder.outputFormatting = .prettyPrinted
        guard let encodedData = try? jsonEncoder.encode(object) else { return nil }
        let objectJSON = String(data: encodedData, encoding: .utf8)
        return objectJSON
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
