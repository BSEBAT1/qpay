//
//  LoginViewController.swift
//  Qpay
//
//  Created by Berkay Sebat on 3/31/20.
//  Copyright © 2020 QPAY. All rights reserved.
//

import UIKit
import FirebaseAuth
import FBSDKLoginKit
import AVKit


class LoginViewController: UIViewController {
    
    @IBOutlet var bottomConstraint: NSLayoutConstraint!
    @IBOutlet var errorLabel: UILabel!
    @IBOutlet var fbSignInButton: UIButton!
    @IBOutlet var loginButton: UIButton!
    @IBOutlet var signUpButton: UIButton!
    @IBOutlet var stackView: UIStackView!
    @IBOutlet var emailTextField: UITextField!
    @IBOutlet var passWordTextfield: UITextField!
    let userDefaults = UserDefaults.standard
    var videoPlayer:AVPlayer?
    var videoPlayerLayer:AVPlayerLayer?
    var keyboardshown = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        Utilities.styleFilledButton(loginButton)
        Utilities.styleHollowButton(signUpButton)
        fbSignInButton.layer.cornerRadius = 25
        Utilities.styleTextField(emailTextField)
        Utilities.styleTextField(passWordTextfield)
       NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(sender:)), name: UIResponder.keyboardWillShowNotification, object: nil);
        self.hideKeyboardWhenTappedAround()
        emailTextField.textColor = UIColor.white
        passWordTextfield.textColor = UIColor.white
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if userDefaults.bool(forKey: "isSignedIn"){
            performSegue(withIdentifier: "showTabs", sender: nil)
        }
    }
    
    
   
    
    override func viewDidAppear(_ animated: Bool) {

        setUpVideo()
        view.backgroundColor = UIColor(red:0.14, green:0.58, blue:0.97, alpha:1.00)
    }
    
    @IBAction func loginButtonPressed(_ sender: Any) {
       guard let email = emailTextField.text else {
                  handleError(errorDesc: "Email or Password cannot be blank")
                  return
              }
              guard let password = passWordTextfield.text else {
                  handleError(errorDesc: "Email or Password cannot be blank")
                  return
              }
             
              Auth.auth().signIn(withEmail: email, password: password) {[weak self] (result, error) in
                  if let error = error {
                      self?.handleError(errorDesc: error.localizedDescription)
                  } else {
                      self?.userDefaults.set(email, forKey: "email")
                      self?.userDefaults.set(password, forKey: "password")
                      self?.userDefaults.set(true, forKey: "isSignedIn")
                    self?.dismiss(animated: true) {
                    self?.performSegue(withIdentifier: "showTabs", sender: nil)
                            }
                  }
              }
    }
    
    func setUpVideo() {
           
           // Get the path to the resource in the bundle
           let bundlePath = Bundle.main.path(forResource: "login", ofType: "mp4")
           
           guard bundlePath != nil else {
               return
           }
           
           // Create a URL from it
           let url = URL(fileURLWithPath: bundlePath!)
           
           // Create the video player item
           let item = AVPlayerItem(url: url)
           
           // Create the player
           videoPlayer = AVPlayer(playerItem: item)
           
           // Create the layer
           videoPlayerLayer = AVPlayerLayer(player: videoPlayer!)
           
           // Adjust the size and frame
           videoPlayerLayer?.frame = CGRect(x: -self.view.frame.size.width*1.5, y: 0, width: self.view.frame.size.width*4, height: self.view.frame.size.height)
           
           view.layer.insertSublayer(videoPlayerLayer!, at: 0)
           
           // Add it to the view and play it
           videoPlayer?.playImmediately(atRate:1)
       }
    
    @IBAction func fbLoginPressed(_ sender: Any) {
        let loginManager = LoginManager()
               loginManager.logIn(permissions: [], from: self) { (result, erorr) in
                   if let error = erorr {
                    self.handleError(errorDesc: error.localizedDescription)
                    print("facebook error was \(error.localizedDescription)")
                   } else {
                    guard let acessToken = result?.token?.tokenString else {
                        self.handleError(errorDesc: "failed to connect to Facebook")
                       return
                    }
                       let credential = FacebookAuthProvider.credential(withAccessToken:acessToken)
                       self.loginWithToken(credential: credential)
                       self.userDefaults.set(true, forKey: "isSignedIn")
                       self.userDefaults.set("fbcred", forKey:acessToken)
                   }
               }
    }
    
    private func handleError(errorDesc:String) {
           DispatchQueue.main.async {
               self.errorLabel.isHidden = false
               self.errorLabel.text = errorDesc
           }
          }
    
    private func loginWithToken(credential:AuthCredential) {
        Auth.auth().signIn(with: credential) { (authResult, error) in
          if let error = error {
            self.handleError(errorDesc: error.localizedDescription)
          } else {
            self.dismiss(animated: true) {
            self.performSegue(withIdentifier: "showTabs", sender: nil)
                    }
            }
        }
    }
    
    @objc func keyboardWillShow(sender: NSNotification) {
         let info = sender.userInfo!
         let keyboardFrame: CGRect = (info[UIResponder.keyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        self.videoPlayerLayer?.isHidden = true
         UIView.animate(withDuration: 0.1, animations: { () -> Void in
             self.bottomConstraint.constant = keyboardFrame.size.height + 10
         })
    }
}

extension UIViewController {
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }

    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}
