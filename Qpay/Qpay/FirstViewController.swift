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
import MapKit

class FirstViewController: UIViewController {
    var plaidPresented = true
    var geoFireStoreRef: CollectionReference!
    var geoFirestore: GeoFirestore!
    var sfQuery: GFSQuery!
    @IBOutlet var customerMap: MKMapView!
    let locationManager = CLLocationManager()
    
    /** @var handle
        @brief The handler for the auth state listener, to allow cancelling later.
     */
    var handle: AuthStateDidChangeListenerHandle?

    override func viewDidLoad() {
        super.viewDidLoad()
        locations()
        self.locationManager.requestWhenInUseAuthorization()
        setupMap()
    }
    
    func setupMap() {
        if CLLocationManager.locationServicesEnabled() {
                          switch CLLocationManager.authorizationStatus() {
                              case .notDetermined, .denied:
                                 DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 9) {
                                        self.askLocation()
                                        }
                              case .authorizedAlways, .authorizedWhenInUse, .restricted:
                                 locationManager.delegate = self
                                 locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
                                 locationManager.startUpdatingLocation()
                                 self.customerMap.delegate = self
                                 self.customerMap.showsUserLocation = true
                                 customerMap.userTrackingMode = MKUserTrackingMode.follow
                              @unknown default:
                              break
                          }
                          } else {
                              print("Location services are not enabled")
                      }
    }
    
    func askLocation() {
               if CLLocationManager.locationServicesEnabled() {
                   
                   switch CLLocationManager.authorizationStatus() {
                       case .notDetermined, .denied:
                           showLocationsAlert()
                       case .authorizedAlways, .authorizedWhenInUse, .restricted:
                          locationManager.delegate = self
                          locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
                          locationManager.startUpdatingLocation()
                          self.customerMap.delegate = self
                          self.customerMap.showsUserLocation = true
                          customerMap.userTrackingMode = MKUserTrackingMode.follow
                       @unknown default:
                       break
                   }
                   } else {
                       print("Location services are not enabled")
               }
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
    func showLocationsAlert() {
        let alertController = UIAlertController (title:"Qpay Needs Your Permission", message:"We need location services to show you a map of gas stations in your area" , preferredStyle: .alert)

                   let settingsAction = UIAlertAction(title: NSLocalizedString("settings", comment: ""), style: .default) { (_) -> Void in
                       guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else {
                           return
                       }
                       if UIApplication.shared.canOpenURL(settingsUrl) {
                           UIApplication.shared.open(settingsUrl, options: [:], completionHandler: nil)
                       }
                   }
                   alertController.addAction(settingsAction)
                   let cancelAction = UIAlertAction(title: NSLocalizedString("cancel", comment: ""), style: .default, handler: nil)
                   alertController.addAction(cancelAction)

                   present(alertController, animated: true, completion: nil)
    }
}


extension FirstViewController : CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if locations.count > 0 {
//            self.customerMap.setRegion(MKCoordinateRegion(center: locations[0]
//                       .coordinate, span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)), animated: true)
        }
    }
}
extension FirstViewController: MKMapViewDelegate {
    
}

