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
import Geofirestore
import CoreLocation

class FirstViewController: UIViewController {
    var plaidPresented = true
    var geoFireStoreRef: CollectionReference!
    var geoFirestore: GeoFirestore!
    var sfQuery: GFSQuery!
    
    /** @var handle
        @brief The handler for the auth state listener, to allow cancelling later.
     */
    var handle: AuthStateDidChangeListenerHandle?

    override func viewDidLoad() {
        super.viewDidLoad()
        locations()
    }
    
    func locations() {
    geoFireStoreRef = Firestore.firestore().collection("locations")
    geoFirestore = GeoFirestore(collectionRef: geoFireStoreRef)
                let center = CLLocation(latitude: 40.7009, longitude: 73.7129)
              
               sfQuery = geoFirestore.query(withCenter: center, radius: 500.6)
                let ans  = sfQuery.observe(.documentEntered, with: { (key, location) in
                    print("The document with documentID '\(key)' entered the search area and is at location '\(location)'")
                })
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

