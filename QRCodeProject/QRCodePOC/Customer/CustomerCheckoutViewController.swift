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
    
    @IBAction func didTouchShareButton(_ sender: UIButton) {
        let text = checkoutValueLabel.text ?? "Nenhum qr code scaneado!" as Any
        let activityViewController = UIActivityViewController(activityItems: [text], applicationActivities: nil)
        activityViewController.popoverPresentationController?.sourceView = self.view
        self.present(activityViewController, animated: true, completion: nil)
    }
}

extension CustomerCheckoutViewController: QRScannerViewControllerDelegate {
    func checkoutDidDetected(string: String) {
        checkoutValueLabel.text = string
    }
}
