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
  
   var memphisWaves = [Wave]()
    var memWaves : Wave!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.requestLocation()
        self.locationManager.requestAlwaysAuthorization()
        locationManager.startMonitoringSignificantLocationChanges()
        getFacebookUserInfo()
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

        
        //print("emply")
       // print(mapView.userLocation.coordinate )



    }
    
    
    
    func getFacebookUserInfo() {
        if(FBSDKAccessToken.current() != nil)
        {
            //print permissions, such as public_profile
            print("Umer The permissions are \(FBSDKAccessToken.current().permissions)")
            let graphRequest = FBSDKGraphRequest(graphPath: "me", parameters: ["fields" : "id, name, email"])
            let connection = FBSDKGraphRequestConnection()
            
            connection.add(graphRequest, completionHandler: { (connection, result, error) -> Void in
                
                let data = result as! [String : AnyObject]
                
                var name = data["name"] as? String
                
                DataService.ds.REF_USER_CURRENT.child("Name").observeSingleEvent(of: .value, with: { (snapshot) in
                    if snapshot.exists() {
                        
                    }
                    else{
                        DataService.ds.REF_USER_CURRENT.child("Name").setValue(name)
                    }
                })
                connection?.start()
            })
            
        }
    }
    
    
    
    
    override func viewDidAppear(_ animated: Bool) {
            self.queryWave()
            
        

    }
    func queryWave(){
        let waveReference = Database.database().reference().child("Wave").child("Memphis")
        waveReference.observeSingleEvent(of: .value, with: { snapshot in
            if let snapshot = snapshot.children.allObjects as? [DataSnapshot] {
                
                for snap in snapshot {
                    if let dictionary = snap.value as? Dictionary<String,AnyObject> {
                        let wave = Wave(key: snap.key, data: dictionary)
                        if wave.count! > 0 {
                           // print(wave.location)
                            let annotation = WaveAnnotation()
                            if wave.location?.coordinate != nil {
                                annotation.coordinate = (wave.location?.coordinate)!
                                annotation.title = wave.title
                                annotation.subtitle = String(describing: wave.count)
                                self.mapView.addAnnotation(annotation)
                                self.memphisWaves.append(wave)
                            }

                           // print(wave.location)
                        }
                    }
                }
            }
        })
    }
    
    
    
    
    func counter(){
        let ref = Database.database().reference().child("WaveSpots").child("Memphis")
        let geoFire = GeoFire(firebaseRef: ref)
        let waveRef = Database.database().reference().child("Wave").child("Memphis")
        
        
        geoFire?.query(at: userLocation, withRadius: 0.5).observe(.keyEntered, with: { (key: String!, location: CLLocation!) in
        print("someone entered")
            waveRef.child(key).child("count").observeSingleEvent(of: .value, with: { snapshot in
                if var number = snapshot.value as? Int{
                    number = number + 1
                    waveRef.child(key).child("count").setValue(number)
                    print(number)
                }

                
            })
        })
    }
        /*
            waveRef.child(key).child("count").runTransactionBlock({ (snap) -> TransactionResult in
                if let valueToBeAppended = snap.value as? Int{
                    snap.value = valueToBeAppended + 1
                    return TransactionResult.success(withValue: snap)
                }else{
                    return TransactionResult.success(withValue: snap)
                }
            }, andCompletionBlock: {(error,completion,snap) in
                print(error?.localizedDescription)
                print(completion)
                print(snap)
                
                if !completion {
                    print("The value wasn't able to Update")
                }else{
                    print("Value updated")
                }
            })
        

        
        })
    }
    
    
    */
            
    
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
            
            var ref = Database.database().reference()
            ref = ref.child("Wave").child("Memphis")
            
            for item in response.mapItems {
                // Display the received items
             currentBars.append(item)
                
                
     
                    ref.queryOrdered(byChild: "title").queryEqual(toValue: item.name).observe(.value, with: { snapshot in
                        //print(snapshot)
                        print()
                        //print("space")
                        if snapshot.exists(){
                            //print("Object already exists")
                            
                        } else{
                          var newID = ref.childByAutoId()
                            newID.setValue(["title":item.name, "address":item.placemark.title, "phone number":item.phoneNumber,  "count":0] )
                            //ref = (ref.parent?.child("WaveSpots"))!
                            
                            var geoFire = GeoFire(firebaseRef: newID)
                            
                    
                            
                                geoFire?.setLocation(CLLocation(latitude: item.placemark.coordinate.latitude, longitude: item.placemark.coordinate.longitude), forKey: snapshot.key)
                            let georef = Database.database().reference().child("WaveSpots").child("Memphis")
                            geoFire = GeoFire(firebaseRef: georef)
                            
                            
                            
                            geoFire?.setLocation(CLLocation(latitude: item.placemark.coordinate.latitude, longitude: item.placemark.coordinate.longitude), forKey: newID.key)
                            
                            
                            
                        }
                    
                    })
                
                

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
        
        createWaves()
        
        
        
     
        
        
        
        
        
        

        
        /*
         let geoFire = GeoFire(firebaseRef: geofireRef)
        geoFire?.query(at: userLocation, withRadius: 100.0).observe(.keyEntered, with: { (key: String!, location: CLLocation!) in
            
            
            print("Key '\(key)' entered the search area and is at location '\(location)'")
            
            var ref = Database.database().reference()
            ref = ref.child("Wave").child(key)
            ref.observeSingleEvent(of: .value, with: { snapshot in
                print("something actualyl happened")
                
                let value = snapshot.value as? NSDictionary
                let title =  "Example Bar" //value?["title"] as? String
                let count = 34//value?["count"] as? Int
                print()
                print(value)
                print()
                let annotation = WaveAnnotation()
                annotation.coordinate = location.coordinate
                annotation.title = title
                annotation.subtitle = String(describing: count)
                self.mapView.addAnnotation(annotation)
                
                
                
                
                
            })
            
        })

    }
    
    
}
 */
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
       
        
        let georef = Database.database().reference().child("UserLocations")
        var geoFire = GeoFire(firebaseRef: georef)
        
        
        
        geoFire?.setLocation(CLLocation(latitude:userLocation.coordinate.latitude , longitude: userLocation.coordinate.longitude), forKey: Auth.auth().currentUser?.uid)

        
        
        //get userid
        
        
        //check if firebase object exist
        
        //if not create user location object
        
        //if so update the firebase object with location
        counter()
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
        
        if !(annotation is WaveAnnotation) {
            return nil
        }
        
        let reuseId = "waveAnnotation"
        
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId)
        if annotationView == nil {
            annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            annotationView?.canShowCallout = true
        }
        else {
            annotationView?.annotation = annotation
        }
        
        let k = arc4random_uniform(130)

        let waveAnnotation = annotation as! WaveAnnotation
        annotationView?.image = generateWaveImage(count: Int(k))
        
        return annotationView
    }
    
    
    
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "venue" {
    
            if let detailVC = segue.destination as? DetailedVenue {
                let request = MKLocalSearchRequest()
                request.naturalLanguageQuery = "bars"
               // request.region = mapView.region
                var currentBars = [MKMapItem]()
                //Searches for bars and clubs around you
                let search = MKLocalSearch(request: request)
                search.start { response, error in
                    guard let response = response else {
                        print("There was an error searching for: \(request.naturalLanguageQuery) error: \(error)")
                        return
                    }
                    
                    for item in response.mapItems {
                            print(item.placemark.title)
                        
                        detailVC.address = item.placemark.title
                        detailVC.name = item.name
                        detailVC.contact = item.phoneNumber
                        //detailVC.descriptions = item.placemark.subtitle
                }
            }
        
        }
        }
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {

       performSegue(withIdentifier: "venue", sender: self)

    }

}
