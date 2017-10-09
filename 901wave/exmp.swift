//
//  exmp.swift
//  Pods
//
//  Created by Kareem Dasilva on 10/6/17.
//
//

import Foundation

/*let geofireRef = Database.database().reference().child("WaveSpots")
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
    
})
geoFire?.query(at: locationManager.location, withRadius: 1.0).observe(.keyExited, with: { (key: String!, location: CLLocation!) in
    
    
    print("Key '\(key)' exitedƒ the search area and is at location '\(location)'")
    
    var ref = Database.database().reference()
    ref = ref.child("Wave").child(key)
    ref.observeSingleEvent(of: .value, with: { (snapshot) in
        print(snapshot)
        //Decrease the count
    })
    
})*/
