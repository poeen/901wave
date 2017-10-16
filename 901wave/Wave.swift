//
//  Wave.swift
//  901wave
//
//  Created by Kareem Dasilva on 10/16/17.
//  Copyright © 2017 Poeen. All rights reserved.
//

import Foundation

class Wave {
    private var _title:String?
    private var _phoneNumber:String?
    private var _count:Int?
    private var _address:String?
    private var _key:String
    private var _location:CLLocation?
    
    var location:CLLocation?{
        return _location
    }
    
    var key:String{
        return _key
    }
    
    var title:String? {
        return _title
    }
    
    var address:String?{
        return _address
    }
    
    var count:Int?{
        return _count
    }
    
    var phoneNumber:String?{
        return _phoneNumber
    }
    
    
    
    
    init(key:String, data:Dictionary<String,AnyObject>){
        self._key = key
        
        
        if let waveLocation = data["Memphis"] as? Dictionary<String,AnyObject> {
            if let wavecordin = waveLocation["l"] as? NSArray {
                let cllocation = CLLocation(latitude: wavecordin[0] as! CLLocationDegrees, longitude: wavecordin[1] as! CLLocationDegrees)
                self._location = cllocation
            }
            
            
        }
        
        if let waveTitle = data["title"] {
            self._title = waveTitle as! String
        }
        
        if let waveAddress = data["address"] {
            self._address = waveAddress as! String
        }
        
        if let waveCount = data["count"] {
            self._count = waveCount as! Int
        }
        
        if let wavePhoneNumber = data["phone number"] {
            self._title = wavePhoneNumber as! String
        }
      
    }
    
    
}
