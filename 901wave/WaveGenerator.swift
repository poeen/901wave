//
//  WaveGenerator.swift
//  901wave
//
//  Created by Umer Khan on 10/9/17.
//  Copyright © 2017 Poeen. All rights reserved.
//

import UIKit



func generateWaveImage(count:Int) -> UIImage{
    
    switch true {
    case count < 4 :
        return UIImage(named: "Location")!
    case count > 5 && count < 10 :
        return UIImage(named: "Location")!
    case count > 11 && count < 15 :
        return UIImage(named: "Location")!
    case count > 16 && count < 20 :
        return UIImage(named: "Location")!
    case count > 21 && count < 25 :
        return UIImage(named: "Location")!
    case count > 25 :
        return UIImage(named: "Location")!
        
    default:
        return UIImage(named: "Location")!
    }
    
}
