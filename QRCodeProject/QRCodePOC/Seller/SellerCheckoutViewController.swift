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
        guard let qrCodeCheckout = sender as? Checkout else {
            return
        }
        destination.qrCodeCheckout = qrCodeCheckout
    }

    @IBAction func generateQRAction(_ sender: UIButton) {
        guard let checkOutText = checkoutTextField.text else {
            return
        }
        guard let checkoutValue = Double(checkOutText) else {
            return
        }
        let checkout = Checkout(userName: "Rodrigo", age: 22, value: checkoutValue)
        performSegue(withIdentifier: "qrSegue", sender: checkout)
    }
}
