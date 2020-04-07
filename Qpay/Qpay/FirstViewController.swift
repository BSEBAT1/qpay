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
import SCLAlertView

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
        if !(UserDefaults.standard.bool(forKey: "registered")){
            
//            kDefaultShadowOpacity: CGFloat = 0.7, kCircleTopPosition: CGFloat = 0.0, kCircleBackgroundTopPosition: CGFloat = 6.0, kCircleHeight: CGFloat = 56.0, kCircleIconHeight: CGFloat = 20.0, kTitleTop:CGFloat = 30.0, kTitleHeight:CGFloat = 25.0,  kWindowWidth: CGFloat = 240.0, kWindowHeight: CGFloat = 178.0, kTextHeight: CGFloat = 90.0, kTextFieldHeight: CGFloat = 45.0, kTextViewdHeight: CGFloat = 80.0, kButtonHeight: CGFloat = 45.0, kTitleFont: UIFont = UIFont.systemFont(ofSize: 20), kTitleMinimumScaleFactor: CGFloat = 1.0, kTextFont: UIFont = UIFont.systemFont(ofSize: 14), kButtonFont: UIFont = UIFont.boldSystemFont(ofSize: 14), showCloseButton: Bool = true, showCircularIcon: Bool = true, shouldAutoDismiss: Bool = true, contentViewCornerRadius: CGFloat = 5.0, fieldCornerRadius: CGFloat = 3.0, buttonCornerRadius: CGFloat = 3.0, hideWhenBackgroundViewIsTapped: Bool = false, circleBackgroundColor: UIColor = UIColor.white, contentViewColor: UIColor = UIColorFromRGB( ), contentViewBorderColor: UIColor = UIColorFromRGB(0xCCCCCC), titleColor: UIColor = UIColorFromRGB(0x4D4D4D), dynamicAnimatorActive: Bool = false, disableTapGesture: Bool = false, buttonsLayout: SCLAlertButtonLayout = .vertical, activityIndicatorStyle: UIActivityIndicatorViewStyle = .white
            
            let appearance = SCLAlertView.SCLAppearance(
                      kTitleFont: UIFont(name: "HelveticaNeue", size: 20)!,
                      kTextFont: UIFont(name: "HelveticaNeue", size: 14)!,
                      kButtonFont: UIFont(name: "HelveticaNeue-Bold", size: 14)!,
                      showCloseButton: false,
                      circleBackgroundColor: UIColor.white,
                      dynamicAnimatorActive: true,
                      buttonsLayout: .vertical
                  )
         
                  let alert = SCLAlertView(appearance: appearance)
                  _ = alert.addButton("Register", target:self, selector:#selector(FirstViewController.registerPressed))
                  _ = alert.addButton("Close") {
                    alert.dismiss(animated: true, completion: nil)
                    }
            
            guard let icon = UIImage(named:"map") else {
                return
            }
                  let color = UIColor(red:0.35, green:0.69, blue:1.00, alpha:1.00)

                  _ = alert.showCustom("Register", subTitle: "Link with our secure system to begin paying for gas at our discounted rate!", color: color, icon: icon)
        }
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
        
        let appearance = SCLAlertView.SCLAppearance(
            kTitleFont: UIFont(name: "HelveticaNeue", size: 20)!,
            kTextFont: UIFont(name: "HelveticaNeue", size: 14)!,
            kButtonFont: UIFont(name: "HelveticaNeue-Bold", size: 14)!,
            showCloseButton: false,
            dynamicAnimatorActive: true,
            buttonsLayout: .vertical
        )
        let alert = SCLAlertView(appearance: appearance)
        _ = alert.addButton("Open Settings") {
            guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else {
                return
            }
            if UIApplication.shared.canOpenURL(settingsUrl) {
                UIApplication.shared.open(settingsUrl, options: [:], completionHandler: nil)
            }
        }
        _ = alert.addButton("Close") {
          alert.dismiss(animated: true, completion: nil)
          }
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
    
    @objc func registerPressed() {
        let plaid = UIStoryboard(name: "Plaid", bundle: nil)
                                if let plaidView = plaid.instantiateViewController(withIdentifier: "plaid") as? ViewController {
                                    plaidView.modalPresentationStyle = .fullScreen
                                    self.present(plaidView, animated: false, completion: nil)
                                  plaidPresented = true
                                }
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
            annotationView.canShowCallout = false
            let pinImage = UIImage(named: "map")
            let size = CGSize(width: 50, height: 50)
            UIGraphicsBeginImageContext(size)
            pinImage!.draw(in: CGRect(x: 0, y: 0, width: size.width, height: size.height))
            let resizedImage = UIGraphicsGetImageFromCurrentImageContext()

            annotationView.image = resizedImage
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

