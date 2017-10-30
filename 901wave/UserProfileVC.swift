//
//  UserProfileVC.swift
//  901wave
//
//  Created by Kareem Dasilva on 10/25/17.
//  Copyright © 2017 Poeen. All rights reserved.
//

import UIKit
import FBSDKCoreKit
import FBSDKLoginKit
import SwiftKeychainWrapper
import Firebase

class UserProfileVC: UIViewController {
    
    @IBOutlet weak var profilePic: UIImageView!
    
    @IBOutlet weak var profileName: UILabel!
    
    @IBOutlet weak var aboutMeLabel: UILabel!
    
    @IBOutlet weak var cityLabel: UILabel!
    
    
    func getFacebookUserInfo() {
    if(FBSDKAccessToken.current() != nil)
    {
    //print permissions, such as public_profile
    print("Umer The permissions are \(FBSDKAccessToken.current().permissions)")
    let graphRequest = FBSDKGraphRequest(graphPath: "me", parameters: ["fields" : "id, name, email, about, location, gender"])
    let connection = FBSDKGraphRequestConnection()
    
    connection.add(graphRequest, completionHandler: { (connection, result, error) -> Void in
    
    let data = result as! [String : AnyObject]
    
    let FBid = data["id"] as? String
    
    self.profileName.text = data["name"] as? String
        
    self.aboutMeLabel.text = data["about"] as? String
        
    self.cityLabel.text = data["location"] as? String
        
        
    
    let url = NSURL(string: "https://graph.facebook.com/\(FBid!)/picture?type=large&return_ssl_resources=1")
    self.profilePic.image = UIImage(data: NSData(contentsOf: url! as URL)! as Data)
    })
    connection.start()
    }
    }

    
    @IBAction func logoutPressed(_ sender: Any) {
        let keychainResult = KeychainWrapper.standard.removeObject(forKey: KEY_UID)//removeObjectForKey
        print("Umer: ID removed from keychain \(keychainResult)")
        FBSDKLoginManager().logOut()
         try! Auth.auth().signOut()
        performSegue(withIdentifier: "logout", sender: nil)

    }
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getFacebookUserInfo()
        profilePic.layer.borderWidth = 1
        profilePic.layer.masksToBounds = true
        profilePic.layer.cornerRadius = profilePic.frame.height/2
        profilePic.clipsToBounds = true
        profilePic.layer.borderColor = UIColor.clear.cgColor

        
        
    }
}
