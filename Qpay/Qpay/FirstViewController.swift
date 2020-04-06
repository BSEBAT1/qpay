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
    @IBOutlet var locationName: UILabel!
    @IBOutlet var distance: UILabel!
    @IBOutlet var buyGasButton: UIButton!
    @IBOutlet var getDirectionButton: UIButton!
    var loadedOnce = false
    var currentSelected:MKAnnotation?
    
    /** @var handle
        @brief The handler for the auth state listener, to allow cancelling later.
     */
    var handle: AuthStateDidChangeListenerHandle?

    override func viewDidLoad() {
        super.viewDidLoad()
        self.locationManager.requestWhenInUseAuthorization()
        setupMap()
        Utilities.styleFilledButton(buyGasButton)
        Utilities.styleFilledButton(getDirectionButton)
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
    @IBAction func buyGasPressed(_ sender: Any) {
    }
    @IBAction func GetDirectionPressed(_ sender: Any) {
        
        guard let selected = currentSelected else {
            return
        }
         let options = [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving]
        let placemark = MKPlacemark(coordinate: selected.coordinate, addressDictionary: nil)
         let mapItem = MKMapItem(placemark: placemark)
        mapItem.name = selected.title ?? "Gas Station" // Provide the name of the destination in the To: field
        mapItem.openInMaps(launchOptions: options)
    }
}


extension FirstViewController : CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if locations.count > 0,!loadedOnce {
           loadGasStations(locations[0])
            print(locations[0].coordinate)
            loadedOnce = true
        }
    }
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse || status == .authorizedAlways {
            loadedOnce = false
            setupMap()
        }
    }
}
extension FirstViewController: MKMapViewDelegate {
    
    func loadGasStations(_ center: CLLocation) {
       geoFireStoreRef = Firestore.firestore().collection("locations")
       geoFirestore = GeoFirestore(collectionRef: geoFireStoreRef)
                  sfQuery = geoFirestore.query(withCenter: center, radius: 80.0)
        
           _  = sfQuery.observe(.documentEntered, with: { (key, location) in
            if let location = location, let title = key {
                let annotation = MKPointAnnotation()
                annotation.coordinate = location.coordinate
                annotation.title = title
                self.customerMap.addAnnotation(annotation)
                
            }
            
                   })
       }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
    
        guard !(annotation is MKUserLocation) else {
            return nil
        }

        // Better to make this class property
        let annotationIdentifier = "AnnotationIdentifier"

        var annotationView: MKAnnotationView?
        if let dequeuedAnnotationView = mapView.dequeueReusableAnnotationView(withIdentifier: annotationIdentifier) {
            annotationView = dequeuedAnnotationView
            annotationView?.annotation = annotation
        }
        else {
            let av = MKAnnotationView(annotation: annotation, reuseIdentifier: annotationIdentifier)
            av.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
            annotationView = av
        }

        if let annotationView = annotationView {
            // Configure your annotation view here
            annotationView.canShowCallout = true
            
            annotationView.image = UIImage(named: "Button")
        }

        return annotationView
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        DispatchQueue.main.async {
            if let anno = view.annotation, let text = anno.title {
                self.locationName.text = text
                self.currentSelected = view.annotation
                guard let userLocation = self.locationManager.location?.coordinate else {
                    return
                }
                let loc1 = CLLocation.init(latitude:userLocation.latitude , longitude: userLocation.longitude)
                let loc2 = CLLocation.init(latitude: anno.coordinate.latitude, longitude: anno.coordinate.longitude
                )
                let distance = loc2.distance(from: loc1)
                let miles = distance * 0.00062137
                let doubleStr = String(format: "%.2f", miles)
                self.distance.text = "\(doubleStr) miles away"
            }
        }
    }
    
}

