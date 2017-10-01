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
    
    @IBOutlet weak var mapView: MKMapView!
  
   

    var userLocation: CLLocation? = nil
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.requestLocation()
        self.locationManager.requestAlwaysAuthorization()

        print(mapView.userLocation.coordinate)
        

    }
    
    
    
    func getDirections(){
        selectedMapItem = Event(title: locationTitle, address: address!)
        self.performSegue(withIdentifier: "back", sender: self)
    }
    @IBAction func logoutPressed(_ sender: Any) {
        let keychainResult = KeychainWrapper.standard.removeObject(forKey: KEY_UID)//removeObjectForKey
        print("Umer: ID removed from keychain \(keychainResult)")
        FBSDKLoginManager().logOut()
        try! Auth.auth().signOut()
        performSegue(withIdentifier: "logout", sender: self)
    }
    override func viewDidAppear(_ animated: Bool) {
        print("View did appear happened")

        
    }
}
extension MainView : CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse {
            locationManager.requestLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard var location = locations.last else { return }
        userLocation = location
        let span = MKCoordinateSpanMake(0.04, 0.04)
        var region = MKCoordinateRegion(center: location.coordinate, span: span)
        mapView.setRegion(region, animated:false)
        
        let request = MKLocalSearchRequest()
        request.naturalLanguageQuery = "bars"
        request.region = mapView.region
        let search = MKLocalSearch(request: request)
        search.start { response, error in
            guard let response = response else {
                print("There was an error searching for: \(request.naturalLanguageQuery) error: \(error)")
                return
            }
            
            for item in response.mapItems {
                // Display the received items
                let annotation = MKPointAnnotation()
                annotation.title = item.name
                annotation.subtitle = "Wave Intensity: 1"
                annotation.coordinate = item.placemark.coordinate
                print(item.placemark.coordinate)
                self.mapView.addAnnotation(annotation)
                
            }
            
        }

        
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
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKPinAnnotationView
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
        }
        
        pinView?.pinTintColor = UIColor.orange
        pinView?.canShowCallout = true
        let smallSquare = CGSize(width: 30, height: 30)
        let button = UIButton(frame: CGRect(origin: CGPoint.zero, size: smallSquare))
        button.setBackgroundImage(UIImage(named: "Blue_circle"), for: UIControlState())
        button.addTarget(self, action: #selector(MainView.getDirections), for: .touchUpInside)
        pinView?.leftCalloutAccessoryView = button
        let geofireRef = Database.database().reference()

        let geoFire = GeoFire(firebaseRef: geofireRef)

        let center = CLLocation(latitude: annotation.coordinate.latitude, longitude: annotation.coordinate.longitude)

        // Query locations at [37.7832889, -122.4056973] with a radius of 600 meters
        geoFire?.query(at: center, withRadius: 0.3).observe(.keyEntered, with: { (key: String!, location: CLLocation!) in
            
            geofireRef.child("Wave").childByAutoId().setValue(["title": annotation.title, "location":"NaN"])
            

            print("Key '\(key)' entered the search area and is at location '\(location)'")
        })
        return pinView
    }

}
