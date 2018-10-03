import UIKit

class CustomerCheckoutViewController: UIViewController {

    @IBOutlet weak var checkoutValueLabel: UILabel!
    @IBOutlet weak var scanButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let destination = segue.destination as? QRScanerViewController else {
            return
        }
        destination.delegate = self
    }

    private func setup() {
        setupCheckOutValueLabel()
    }

    private func setupCheckOutValueLabel() {
        checkoutValueLabel.text = ""
    }

    @IBAction func scanAction(_ sender: UIButton) {
        performSegue(withIdentifier: "scanSegue", sender: self)
    }
}

extension CustomerCheckoutViewController: QRScannerViewControllerDelegate {
    func checkoutDidDetected(checkout: Checkout) {
        let formattedPrice = String(format: "%.2f", checkout.value)
        checkoutValueLabel.text = "$\(formattedPrice)"
    }
}
