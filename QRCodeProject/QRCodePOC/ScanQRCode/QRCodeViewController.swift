//
//  ViewController.swift
//  QRCodePOC
//
//  Created by Rodrigo Noronha on 01/10/18.
//  Copyright © 2018 Rodrigo Noronha. All rights reserved.
//

import UIKit

class QRCodeViewController: UIViewController {

    @IBOutlet weak var scanButton: UIButton!
    @IBOutlet weak var answerLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func scanAction(_ sender: UIButton) {
        performSegue(withIdentifier: "scanSegue", sender: self)
    }
}
