//
//  SignUpViewController.swift
//  Qpay
//
//  Created by Berkay Sebat on 3/31/20.
//  Copyright © 2020 QPAY. All rights reserved.
//

import UIKit
import FirebaseAuth
import Firebase

class SignUpViewController: UIViewController {
    @IBOutlet var userNameLabel: UILabel!
    @IBOutlet var userNameTextField: UITextField!
    @IBOutlet var passWordLabel: UILabel!
    @IBOutlet var passWordTextField: UITextField!
    @IBOutlet var SignUpButton: UIButton!
    @IBOutlet var errorLabel: UILabel!
    let userDefaults = UserDefaults.standard
        
    override func viewDidLoad() {
        super.viewDidLoad()
        Utilities.styleTextField(userNameTextField)
        Utilities.styleTextField(passWordTextField)
        Utilities.styleFilledButton(SignUpButton)
        view.backgroundColor = UIColor(red:0.14, green:0.58, blue:0.97, alpha:1.00)
        passWordTextField.textColor = UIColor.white
        userNameTextField.textColor = UIColor.white
    }
    

    @IBAction func signUpPressed(_ sender: Any) {
        
        if passWordTextField.text?.count == 0 || userNameTextField.text?.count == 0 {
            
             handleError(errorDesc:"Password or Email cannot be empty")
            return
        }
        if let input = passWordTextField.text?.count, input < 5 {
            
           handleError(errorDesc:"Password must be at least 5 characters")
            return
        }
        
        guard let email = userNameTextField.text else {
            handleError(errorDesc:"Password or Email cannot be empty")
                      return
        }
        guard let password = passWordTextField.text else {
            handleError(errorDesc:"Password or Email cannot be empty")
                                 return
        }
        
        Auth.auth().createUser(withEmail:email , password: password) {[weak self] (result, error) in
            if let error = error {
                self?.handleError(errorDesc: error.localizedDescription)
                return
            }
            let db = Firestore.firestore()
            
            guard let uid = result?.user.uid else {
                
                self?.handleError(errorDesc:"invalid credentials")
                return
            }
            
            db.collection("users").addDocument(data: [email:email,"uid":uid,"password":password]) { (error) in
                if let error = error {
                    self?.handleError(errorDesc: error.localizedDescription)
                } else {
                    self?.userDefaults.set(email, forKey: "email")
                    self?.userDefaults.set(password, forKey: "password")
                    self?.userDefaults.set(true, forKey: "isSignedIn")
                    DispatchQueue.main.async {
                        self?.dismiss(animated: true, completion: {
                            self?.performSegue(withIdentifier: "showTabs", sender: nil)
                           
                        })
                    }
                }
            }
        }
    }
    
    @IBAction func closePressed(_ sender: Any) {
        self.dismiss(animated: true, completion:nil)
    }
    
    private func handleError(errorDesc:String) {
        DispatchQueue.main.async {
            self.errorLabel.isHidden = false
            self.errorLabel.text = errorDesc
        }
       }
}
