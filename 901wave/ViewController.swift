//
//  ViewController.swift
//  901wave
//
//  Created by Kareem Dasilva on 9/6/17.
//  Copyright © 2017 Poeen. All rights reserved.
//

import UIKit
import FBSDKCoreKit
import FBSDKLoginKit
import Firebase
import FirebaseAuth
import SwiftKeychainWrapper
import GeoFire

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        let geofireRef = Database.database().reference()
        let geoFire = GeoFire(firebaseRef: geofireRef)
        geoFire?.setLocation(CLLocation(latitude: 37.7853889, longitude: -122.4056973), forKey: "firebase-hq") { (error) in
            if (error != nil) {
                print("An error occured: \(error)")
            } else {
                print("Saved location successfully!")
            }
        }
    }

  
    
    
    
    @IBAction func loginWithFacebook(_ sender: Any) {
        
        
        let facebookLogin = FBSDKLoginManager()
        facebookLogin.logIn(withReadPermissions: ["email"], from: self) { (result, error) in
            if error != nil {
                print("Umer: Unable to authenticate with Facebook - \(error)")
            } else if result?.isCancelled == true {
                print("Umer: User canceled Facebook authentication")
            } else {
                print("Umer: Successfully authenticated with Facebook")
                let credential = FacebookAuthProvider.credential(withAccessToken: FBSDKAccessToken.current().tokenString)
                self.firebaseAuth(credential)
                self.getFacebookUserInfo()
                self.performSegue(withIdentifier: "toMainFeed", sender: self)
                
            }
        }
    }
    
    func getFacebookUserInfo() {
        if(FBSDKAccessToken.current() != nil)
        {
            //print permissions, such as public_profile
            print(FBSDKAccessToken.current().permissions)
            let graphRequest = FBSDKGraphRequest(graphPath: "me", parameters: ["fields" : "id, name, email"])
            let connection = FBSDKGraphRequestConnection()
            
            connection.add(graphRequest, completionHandler: { (connection, result, error) -> Void in
                
                let data = result as! [String : AnyObject]
                
                //let email = data["email"] as? String
                
                let name = data["name"] as? String
                
                let FBid = data["id"] as? String
                
                let url = NSURL(string: "https://graph.facebook.com/\(FBid!)/picture?type=large&return_ssl_resources=1")
                // let profilePicture = UIImage(data: NSData(contentsOf: url! as URL)! as Data)
                
                let userData = ["Name":name]
                DataService.ds.createFirebaseUser(uid: FBid!, userData: userData as! Dictionary<String, String>)
                
            })
            connection.start()
        }
    }
    
    
    
    private func completeSignIn(id: String) {
        let keychainResult = KeychainWrapper.standard.set(id, forKey: KEY_UID) //.setString
        print("umer: Data saved to keychain \(keychainResult)")
    }
    
    
    private func firebaseAuth(_ credential: AuthCredential) {
        Auth.auth().signIn(with: credential, completion: { (user, error) in
            if error != nil {
                print("Umer: Unable to authenticate with Firebase - \(error)")
            } else {
                print("Umer: Successfully authenticated with Firebase")
                if let user = user{
                    self.completeSignIn(id: user.uid)
                }
                
            }
        })
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        if let _ = KeychainWrapper.standard.string(forKey: KEY_UID){            print("Umer: ID found in Keychain")
            performSegue(withIdentifier: "toMainFeed", sender: self)
        }
        
    }

    
    
    
    
    
    

}

