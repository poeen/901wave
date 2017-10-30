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
    //just the simple graphic
    @IBOutlet weak var mapBaseRectangle: UIImageView!
    @IBOutlet weak var mapView: MKMapView!
    
    @IBOutlet weak var profilePic: UIButton!
  
   var memphisWaves = [Wave]()
    var memWaves = (String)()

    
    override func viewDidLoad() {
        super.viewDidLoad()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.requestLocation()
        self.locationManager.requestAlwaysAuthorization()
        locationManager.startMonitoringSignificantLocationChanges()
        getFacebookUserInfo()
        getProfilePic()
        profilePic.layer.borderWidth = 1
        profilePic.layer.masksToBounds = true
        profilePic.layer.cornerRadius = profilePic.frame.height/2
        profilePic.clipsToBounds = true
        profilePic.layer.borderColor = UIColor.clear.cgColor
        searchBarSetup()

    }
    
    
    func searchBarSetup(){
        let locationSearchTable = storyboard!.instantiateViewController(withIdentifier: "LocationSearchTable") as! LocationSearchTable
        resultSearchController = UISearchController(searchResultsController: locationSearchTable)
        resultSearchController.searchResultsUpdater = locationSearchTable
        let searchBar = resultSearchController!.searchBar
        searchBar.sizeToFit()
        searchBar.placeholder = "Search for places"
        navigationItem.titleView = resultSearchController?.searchBar
        resultSearchController.hidesNavigationBarDuringPresentation = false
        resultSearchController.dimsBackgroundDuringPresentation = true
        definesPresentationContext = true
        locationSearchTable.mapView = mapView
        locationSearchTable.handleMapSearchDelegate = self
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
    
    func getProfilePic(){
        if(FBSDKAccessToken.current() != nil)
        {
            //print permissions, such as public_profile
            print("Umer The permissions are \(FBSDKAccessToken.current().permissions)")
            let graphRequest = FBSDKGraphRequest(graphPath: "me", parameters: ["fields" : "id, name, email, about, location, gender"])
            let connection = FBSDKGraphRequestConnection()
            
            connection.add(graphRequest, completionHandler: { (connection, result, error) -> Void in
                
                let data = result as! [String : AnyObject]
                
                let FBid = data["id"] as? String
                
                
                
                
                
                let url = NSURL(string: "https://graph.facebook.com/\(FBid!)/picture?type=large&return_ssl_resources=1")
                self.profilePic.setImage(UIImage(data: NSData(contentsOf: url! as URL)! as Data), for: .normal)
            })
            connection.start()
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
                        if wave.count! >= 0 {
                           // print(wave.location)
                            let annotation = WaveAnnotation()
                            if wave.location?.coordinate != nil {
                                annotation.key = wave.key
                                annotation.coordinate = (wave.location?.coordinate)!
                                annotation.title = wave.title
                                annotation.subtitle = wave.phoneNumber
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
            
    
    func parseAddress(selectedItem:MKPlacemark) -> String {
        
        // put a space between "4" and "Melrose Place"
        let firstSpace = (selectedItem.subThoroughfare != nil &&
            selectedItem.thoroughfare != nil) ? " " : ""
        
        // put a comma between street and city/state
        let comma = (selectedItem.subThoroughfare != nil || selectedItem.thoroughfare != nil) &&
            (selectedItem.subAdministrativeArea != nil || selectedItem.administrativeArea != nil) ? ", " : ""
        
        // put a space between "Washington" and "DC"
        let secondSpace = (selectedItem.subAdministrativeArea != nil &&
            selectedItem.administrativeArea != nil) ? " " : ""
        
        let addressLine = String(
            format:"%@%@%@%@%@%@%@",
            // street number
            selectedItem.subThoroughfare ?? "",
            firstSpace,
            // street name
            selectedItem.thoroughfare ?? "",
            comma,
            // city
            selectedItem.locality ?? "",
            secondSpace,
            // state
            selectedItem.administrativeArea ?? ""
        )
        
        return addressLine
    }
    

    func createWaves()  {
        let request = MKLocalSearchRequest()
        request.naturalLanguageQuery = "restaurants"
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
                            newID.setValue(["title":item.name, "address":self.parseAddress(selectedItem: item.placemark), "phone number":item.phoneNumber,  "count":0] )
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
        //selectedMapItem = Event(title: locationTitle, address: address!)
        self.performSegue(withIdentifier: "venue", sender: self)
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
        self.performSegue(withIdentifier: "toAboutOne", sender: self)
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
        counter()
    }
    
    
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("error:: \(error)")
    }

}

extension MainView: HandleMapSearch {
    
    func dropPinZoomIn(_ placemark: MKPlacemark){
        print("hello im clicked")
        // cache the pin
        // clear existing pins
        let span = MKCoordinateSpanMake(0.01, 0.01)
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
        let smallSquare = CGSize(width: 40, height: 40)
        let button = UIButton(frame: CGRect(origin: CGPoint.zero, size: smallSquare))
        button.setBackgroundImage(UIImage(named:"Join Wave_"), for: UIControlState())
        button.addTarget(self, action: #selector(MainView.getDirections), for: .touchUpInside)
        annotationView?.leftCalloutAccessoryView = button
        return annotationView
    }
    
    
    
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "venue" {
    
            if let detailVC = segue.destination as? DetailedVenue {
                        detailVC.key = memWaves
                        detailVC.latitude = userLocation.coordinate.latitude
                        detailVC.longitude = userLocation.coordinate.longitude
                

        }
        }
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        let waveAnnotation = view.annotation as! WaveAnnotation
        memWaves = waveAnnotation.key
       //performSegue(withIdentifier: "venue", sender: self)

    }

}

