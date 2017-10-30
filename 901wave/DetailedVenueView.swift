//
//  DetailedVenueView.swift
//  901wave
//
//  Created by Kareem Dasilva on 10/9/17.
//  Copyright © 2017 Poeen. All rights reserved.
//

import Foundation
import UIKit
import Firebase
import CoreLocation

class DetailedVenue: UIViewController{
    // image views, the rating circle will display the actualy wave rating.
    // venueBackground is just the plain gray background on the whole screen
    // line is just the line that separates the contact info from the venue description.
    @IBOutlet weak var venueImage: UIImageView!
    @IBOutlet weak var ratingCircle: UIImageView!
    @IBOutlet weak var venueBackground: UIImageView!
    @IBOutlet weak var line: UIImageView!
    // these are all of the names, titles and descriptions
    // commentSeperation is only the word Comments, that is the header for the actual comments.
    @IBOutlet weak var venueName: UILabel!
    @IBOutlet weak var venueContact: UILabel!
    @IBOutlet weak var venueAddress: UILabel!
    @IBOutlet weak var venueDescription: UILabel!
    @IBOutlet weak var commentSeparation: UILabel!
    // the button to join the wave
    @IBOutlet weak var joinWaveButton: UIButton!
    
    
    @IBOutlet weak var commentTableView: UITableView!
    
    var comments = [Comment]()
    var name:String?
    var picture:String?
    var contact:String?
    var address:String?
    var descriptions:String?
    var key:String?
    var wave:Wave?
    let locationManager = CLLocationManager()
    var latitude:CLLocationDegrees?
    var longitude:CLLocationDegrees?
    
    func getDetails(){
        let waveRef = Database.database().reference().child("Wave").child("Memphis").child(key!)
        waveRef.observe(.value, with: { snapshot in
            if let dictionary = snapshot.value as? [String:Any] {
                self.wave = Wave(key: snapshot.key, data: dictionary as Dictionary<String, AnyObject>)
                self.joinWaveButton.setImage(generateWaveImage(count: (self.wave?.count)!), for: UIControlState.normal)
            }
        })
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "comment" {
            
            if let commentVC = segue.destination as? CommmentVC {
            commentVC.waveKey = key
                
            }
        }
    }
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        var locValue:CLLocationCoordinate2D = (manager.location?.coordinate)!
        latitude = locValue.latitude
        longitude = locValue.longitude
    }
    
    

    
    
    
    @IBAction func joinTheWave(_ sender: Any) {
        print("pressed")

       
            // Get user value

                //filter based on radius

                let userLocation = CLLocation(latitude: self.latitude!, longitude: self.longitude!)
                let distance = wave?.location?.distance(from: userLocation)
                /* distance is in meters
                 1 mile is 1609.34 meters
                 */
                if CLLocationDistance(distance!) < 100.0 {
                    print("success")
                    let alert = UIAlertController(title: "Check In", message: "You successfully checked in into the event", preferredStyle: UIAlertControllerStyle.alert)
                    alert.addAction(UIAlertAction(title: "Plug In", style: UIAlertActionStyle.default, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                } else {
                    let alert = UIAlertController(title: "Check In", message: "You aren't currently at the event, please check in once you arrive.", preferredStyle: UIAlertControllerStyle.alert)
                    alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                }
            }

    

    
    
    @IBAction func toCommentVC(_ sender: Any) {
        performSegue(withIdentifier: "comment", sender: self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
       getDetails()
        let waveRef = Database.database().reference().child("Wave").child("Memphis").child(key!).child("Comments")
        waveRef.observe(.value, with: { snapshot in
            self.comments = []
            if let snapshot = snapshot.children.allObjects as? [DataSnapshot] {
                for snap in snapshot{
                    if let dictionary = snap.value as? Dictionary<String,AnyObject>{
                        let specificComment = dictionary["comment"] as? String
                        
                        let currentEvent = Comment(comment:specificComment!)
                        self.comments.append(currentEvent)
                        
                    }
                }
                self.comments.reverse()
                self.commentTableView.reloadData()
            }
        })
    }
}


        
    

extension DetailedVenue:UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = commentTableView.dequeueReusableCell(withIdentifier: "cell") as? CommentCell
        cell?.commentLabel.text = comments[indexPath.row].comment
        
        return cell!
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return comments.count
    }
}

extension DetailedVenue:UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
}
