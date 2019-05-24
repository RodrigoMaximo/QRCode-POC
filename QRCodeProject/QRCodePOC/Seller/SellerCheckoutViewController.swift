import UIKit

class SellerCheckoutViewController: UIViewController {

    @IBOutlet weak var checkoutTextField: UITextField!
    @IBOutlet weak var generateQRButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let destination = segue.destination as? QRCodeViewController else {
            return
        }
        guard let qrCodeText = sender as? String else {
            return
        }
        destination.qrCodeText = qrCodeText
    }

    @IBAction func generateQRAction(_ sender: UIButton) {
        guard let text = checkoutTextField.text else {
            return
        }
        performSegue(withIdentifier: "qrSegue", sender: text)
    }
}
