import UIKit

class QRCodeViewController: UIViewController {

    @IBOutlet weak var scanButton: UIButton!
    @IBOutlet weak var qrCodeImage: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        qrCodeImage.image = generateQRCode(from: "| Anything to Test ~ ")

        let jsonDecoder = JSONDecoder()
        let jsonEncoder = JSONEncoder()

        if let jsonData = loadDataFromJSON() {
            if let checkout = try? jsonDecoder.decode(Checkout.self, from: jsonData) {
                print(checkout)
            }
        }

        let checkoutObject = Checkout(userName: "Rodrigo", age: 22, value: 40.0)
        jsonEncoder.outputFormatting = .prettyPrinted
        guard let encodedData = try? jsonEncoder.encode(checkoutObject) else { return }
        guard let jsonString = String(data: encodedData, encoding: .utf8) else { return }
        print(jsonString)
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
    
    @IBAction func scanAction(_ sender: UIButton) {
        performSegue(withIdentifier: "scanSegue", sender: self)
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
}
