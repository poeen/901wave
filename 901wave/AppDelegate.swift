//
//  AppDelegate.swift
//  901wave
//
//  Created by Kareem Dasilva on 9/6/17.
//  Copyright © 2017 Poeen. All rights reserved.
//

import UIKit
import Firebase
import FBSDKCoreKit
import IQKeyboardManagerSwift
import UserNotifications
import FirebaseMessaging
import FirebaseInstanceID
import GeoFire

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, MessagingDelegate {

    var window: UIWindow?
    var locationManager = CLLocationManager()
    let gcmMessageIDKey = "gcm.message_id"

    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        FirebaseApp.configure()
        IQKeyboardManager.sharedManager().enable = true
        FBSDKApplicationDelegate.sharedInstance().application(application, didFinishLaunchingWithOptions: launchOptions)
        
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        FBSDKApplicationDelegate.sharedInstance().application(application, didFinishLaunchingWithOptions: launchOptions)
       
        Messaging.messaging().delegate = self
        let token = Messaging.messaging().fcmToken
        print("Umer \(token)")
        
        if #available(iOS 10.0, *) {
            // For iOS 10 display notification (sent via APNS)
            UNUserNotificationCenter.current().delegate = self as? UNUserNotificationCenterDelegate
            
            let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
            UNUserNotificationCenter.current().requestAuthorization(
                options: authOptions,
                completionHandler: {_, _ in })
        } else {
            let settings: UIUserNotificationSettings =
                UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
            application.registerUserNotificationSettings(settings)
        }
        
        application.registerForRemoteNotifications()

        return true
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {
        return FBSDKApplicationDelegate.sharedInstance().application(app, open: url, options: options)
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        // Convert token to string
        let deviceTokenString = deviceToken.reduce("", {$0 + String(format: "%02X", $1)})
        
        Messaging.messaging().apnsToken = deviceToken
        // Print it to console
        print("APNs device token: \(deviceTokenString)")
        
        // With swizzling disabled you must set the APNs token here.
        // Messaging.messaging().apnsToken = deviceToken
    }

    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("Unable to register for remote notifications: \(error.localizedDescription)")
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any]) {
        // If you are receiving a notification message while your app is in the background,
        // this callback will not be fired till the user taps on the notification launching the application.
        // TODO: Handle data of notification
        // With swizzling disabled you must let Messaging know about the message, for Analytics
        // Messaging.messaging().appDidReceiveMessage(userInfo)
        // Print message ID.
        if let messageID = userInfo[gcmMessageIDKey] {
            print("Message ID: \(messageID)")
        }
        
        // Print full message.
        print(userInfo)
    }

    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any],
                     fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        // If you are receiving a notification message while your app is in the background,
        // this callback will not be fired till the user taps on the notification launching the application.
        // TODO: Handle data of notification
        // With swizzling disabled you must let Messaging know about the message, for Analytics
        // Messaging.messaging().appDidReceiveMessage(userInfo)
        // Print message ID.
        if let messageID = userInfo[gcmMessageIDKey] {
            print("Message ID: \(messageID)")
        }
        Messaging.messaging().appDidReceiveMessage(userInfo)
        // Print full message.
        print(userInfo)
        
        completionHandler(UIBackgroundFetchResult.newData)
    }
    

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }


    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        if(FBSDKAccessToken.current() != nil)
        {
        locationManager.requestLocation()
        locationManager.startMonitoringSignificantLocationChanges()
        
        }
         Messaging.messaging().disconnect()


    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        connectToFBMessaging()

    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        locationManager.stopUpdatingLocation()
    }
    func tokenRefreshNotification(notification:NSNotification) {
        let refreshedToken = InstanceID.instanceID().token()
        print("InstanceID token:\(refreshedToken)")
        connectToFBMessaging()
    }
    
    
    
    
    
    func connectToFBMessaging() {
        Messaging.messaging().connect {(error) in
            if error != nil {
                print("Unable to connect\(error) ")
            } else {
                print("Connected to Firebase Messaging")
            }
            
        }
    }



}
extension AppDelegate: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("error:: \(error.localizedDescription)")
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse {
            locationManager.requestLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard var location = locations.last else { return }
        print("KAreem was here")
        let geofireRef = Database.database().reference()
        let geoFire = GeoFire(firebaseRef: geofireRef)
        geoFire?.setLocation(CLLocation(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude), forKey: "firebase-hq") { (error) in
            if (error != nil) {
                print("An error occured: \(error)")
            } else {
                let ref = Database.database().reference().child("WaveSpots").child("Memphis")
                let geoFire = GeoFire(firebaseRef: ref)
                let waveRef = Database.database().reference().child("Wave").child("Memphis")
                
                
                geoFire?.query(at: location, withRadius: 0.5).observe(.keyEntered, with: { (key: String!, location: CLLocation!) in
                    print("someone entered")
                    waveRef.child(key).child("count").observeSingleEvent(of: .value, with: { snapshot in
                        if var number = snapshot.value as? Int{
                            number = number + 1
                            waveRef.child(key).child("count").setValue(number)
                            print(number)
                        }
                        
                        
                    })
                })
                print(location)
                print("Saved location successfully!")
            }
        }
        
    }
    
}

