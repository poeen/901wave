//
//  MainView.swift
//  901wave
//
//  Created by Umer Khan on 9/22/17.
//  Copyright © 2017 Poeen. All rights reserved.
//

import Foundation
import UIKit
import SwiftKeychainWrapper
import FBSDKCoreKit
import FBSDKLoginKit
import Firebase
import MapKit
import GeoFire

protocol HandleMapSearch: class {
    func dropPinZoomIn(_ placemark:MKPlacemark)
}


class MainView: UIViewController {
    var selectedMapItem =  (Event)()
    var selectedPin: MKPlacemark?
    var resultSearchController: UISearchController!
    var category = ""
    var locationTitle = (String)()
    var address: String?
    let locationManager = CLLocationManager()
    var userLocation = (CLLocation)()
    var gotLocation = false
    
    //added by Naim
    //these are the buttons for the map view
    @IBOutlet weak var userProfileButton: UIButton!
    @IBOutlet weak var sideMenuButton: UIButton!
    @IBOutlet weak var joinWaveButton: UIButton!
    @IBOutlet weak var logoutButton: UIButton!
    //search bar
    @IBOutlet weak var searchBar: UISearchBar!
    //just the simple graphic
    @IBOutlet weak var mapBaseRectangle: UIImageView!
    @IBOutlet weak var mapView: MKMapView!
  
   

    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.requestLocation()
        self.locationManager.requestAlwaysAuthorization()
        
        //Queries the Wave object
      /*  var ref = Database.database().reference()
        ref = ref.child("Wave")
        let geofireRef = Database.database().reference().child("WaveSpots")
        let geoFire = GeoFire(firebaseRef: geofireRef)
        geoFire?.query(at: locationManager.location, withRadius: 1.0).observe(.keyEntered, with: { (key: String!, location: CLLocation!) in
            
            
            print("Key '\(key)' entered the search area and is at location '\(location)'")
            
            var ref = Database.database().reference()
            ref = ref.child("Wave").child(key)
            ref.observeSingleEvent(of: .value, with: { snapshot in
                let value = snapshot.value as? NSDictionary
                let title = value?["title"] as? String
                
                let annotation = MKPointAnnotation()
                annotation.coordinate = location.coordinate
                annotation.title = title
                self.mapView.addAnnotation(annotation)
                //Increase the count
            })
            
        })*/

        
        
        print("emply")
        print(mapView.userLocation.coordinate )



    }
    
    func createWaves()  {
        let request = MKLocalSearchRequest()
        request.naturalLanguageQuery = "bars"
        request.region = mapView.region
        var currentBars = [MKMapItem]()
        //Searches for bars and clubs around you
        let search = MKLocalSearch(request: request)
        search.start { response, error in
            guard let response = response else {
                print("There was an error searching for: \(request.naturalLanguageQuery) error: \(error)")
                return
            }
            
            
            
            for item in response.mapItems {
                // Display the received items
             currentBars.append(item)
                
                var ref = Database.database().reference()
                ref = ref.child("Wave")
                if item.name != "" {
                    ref.queryOrdered(byChild: "title").queryEqual(toValue: item.name).observe(.value, with: { snapshot in
                        print(snapshot)
                        print()
                        print("space")
                        if snapshot.exists(){
                            print("Object already exists")
                            
                        } else{
                            var ref = Database.database().reference()
                            ref = ref.child("Wave")
                            ref.childByAutoId().setValue(["title":item.name, "address":item.placemark.title, "phone number":item.phoneNumber,  "count":0] )
                            //ref = (ref.parent?.child("WaveSpots"))!
                            let geofireRef = Database.database().reference().child("WaveSpots")
                            let geoFire = GeoFire(firebaseRef: geofireRef)
                            
                            geofireRef.childByAutoId().setValue(["title": item.name, "count": 0]) { (error, snapshot) in
                                
                                geoFire?.setLocation(CLLocation(latitude: item.placemark.coordinate.latitude, longitude: item.placemark.coordinate.longitude), forKey: snapshot.key)
                                
                            }
                            
                        }
                    
                    })
                }
                

            }
            
        }
        
    }
    
    
    
    func getDirections(){
        selectedMapItem = Event(title: locationTitle, address: address!)
        self.performSegue(withIdentifier: "back", sender: self)
    }
    @IBAction func logoutPressed(_ sender: Any) {
       // let keychainResult = KeychainWrapper.standard.removeObject(forKey: KEY_UID)//removeObjectForKey
        //print("Umer: ID removed from keychain \(keychainResult)")
        //FBSDKLoginManager().logOut()
       // try! Auth.auth().signOut()*/
        createWaves()
 
        
        let geofireRef = Database.database().reference().child("WaveSpots")
        let geoFire = GeoFire(firebaseRef: geofireRef)
        geoFire?.query(at: userLocation, withRadius: 100.0).observe(.keyEntered, with: { (key: String!, location: CLLocation!) in
            
            
            print("Key '\(key)' entered the search area and is at location '\(location)'")
            
            var ref = Database.database().reference()
            ref = ref.child("Wave").child(key)
            ref.child("title").observeSingleEvent(of: .value, with: { snapshot in
                
               
                let value = snapshot.value as? NSDictionary
                let title = value?["title"] as? String
                let count = value?["count"] as? Int
                let annotation = MKPointAnnotation()
                annotation.coordinate = location.coordinate
                annotation.title = title
                annotation.subtitle = String(describing: count)
                self.mapView.addAnnotation(annotation)
                
            })
            
        })
        
        
     
    }

    /*
     ADDED By Naim: This allows for the popup after they've joined the wave
    */
    @IBAction func showPopUp(_ sender: Any) {
        let popOverMapView = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "JoinedWavePopUp") as! PopUpViewController
        self.addChildViewController(popOverMapView)
        popOverMapView.view.frame = self.view.frame
        self.view.addSubview(popOverMapView.view)
        popOverMapView.didMove(toParentViewController: self)
    }
    
}
extension MainView : CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse {
            locationManager.requestLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        userLocation = location
        let span = MKCoordinateSpanMake(0.04, 0.04)
        let region = MKCoordinateRegion(center: location.coordinate, span: span)
        mapView.setRegion(region, animated:false)
    }
    
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("error:: \(error)")
    }

}

extension MainView: HandleMapSearch {
    
    func dropPinZoomIn(_ placemark: MKPlacemark){
        // cache the pin
        selectedPin = placemark
        // clear existing pins
        mapView.removeAnnotations(mapView.annotations)
        let annotation = MKPointAnnotation()
        annotation.coordinate = placemark.coordinate
        annotation.title = placemark.name
        
        
        if let city = placemark.locality,
            let state = placemark.administrativeArea {
            annotation.subtitle = "\(city) \(state)"
        }
        
        mapView.addAnnotation(annotation)
        let span = MKCoordinateSpanMake(0.05, 0.05)
        let region = MKCoordinateRegionMake(placemark.coordinate, span)
        mapView.setRegion(region, animated: true)
    }
    
}
extension MainView : MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView?{
 
        guard !(annotation is MKUserLocation) else { return nil }
        let reuseId = "pin"
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId)
        if pinView == nil {
            pinView = MKAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView?.canShowCallout = true

        } else {
            pinView?.annotation = annotation
        }
        
        
        let smallSquare = CGSize(width: 200, height: 200)
        let button = UIButton(frame: CGRect(origin: CGPoint.zero, size: smallSquare))
        button.setBackgroundImage(UIImage(named: "Blue_circle"), for: UIControlState())
        button.addTarget(self, action: #selector(MainView.getDirections), for: .touchUpInside)
        pinView?.leftCalloutAccessoryView = button

        // Creates the wave object when placing the annotation onto map
        let k = arc4random_uniform(200)
        pinView?.image = generateWaveImage(count: Int(k))
        
        /*geofireRef.childByAutoId().setValue(["title": annotation.title, "count": 0]) { (error, snapshot) in
            
            let geofireRef = Database.database().reference().child("WaveSpots")
            let geoFire = GeoFire(firebaseRef: geofireRef)
            //geoFire?.setLocation(CLLocation(latitude: annotation.coordinate.latitude, longitude: annotation.coordinate.longitude), forKey: snapshot.key)
          }*/
            
        

        

        return pinView
    }
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        print("fef")
    }

}
