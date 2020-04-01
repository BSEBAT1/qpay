//
//  LoginViewController.swift
//  Qpay
//
//  Created by Berkay Sebat on 3/31/20.
//  Copyright © 2020 QPAY. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var loginButton: UIButton!
    @IBOutlet var signUpButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        Utilities.styleHollowButton(loginButton)
        Utilities.styleFilledButton(signUpButton)
    }
    
    override func viewDidAppear(_ animated: Bool) {
//        self.dismiss(animated: false) {
//            self.performSegue(withIdentifier: "showTabs", sender: nil)
//        }
    }
}
