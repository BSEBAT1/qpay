//
//  FirstViewController.swift
//  Qpay
//
//  Created by Berkay Sebat on 1/9/20.
//  Copyright © 2020 QPAY. All rights reserved.
//

import UIKit
import AuthenticationServices
import Firebase

class FirstViewController: UIViewController {
    var plaidPresented = true
    /** @var handle
        @brief The handler for the auth state listener, to allow cancelling later.
     */
    var handle: AuthStateDidChangeListenerHandle?

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if !plaidPresented {
            let plaid = UIStoryboard(name: "Plaid", bundle: nil)
                          if let plaidView = plaid.instantiateViewController(withIdentifier: "plaid") as? ViewController {
                              plaidView.modalPresentationStyle = .fullScreen
                              self.present(plaidView, animated: false, completion: nil)
                            plaidPresented = true
                          }
        }
        handle = Auth.auth().addStateDidChangeListener { (auth, user) in
         
        }
    }
    override func viewWillDisappear(_ animated: Bool) {
        Auth.auth().removeStateDidChangeListener(handle!)
    }
}

