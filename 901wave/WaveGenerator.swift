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
        return UIImage(named: "Wave - 1 Red")!
    case count > 5 && count < 10 :
        return UIImage(named: "Wave - 1 Red")!
    case count > 11 && count < 15 :
        return UIImage(named: "Wave - 2 Orange")!
    case count > 16 && count < 20 :
        return UIImage(named: "Wave - 3 Yellow")!
    case count > 21 && count < 25 :
        return UIImage(named: "Wave - 4 Green")!
    case count > 25 :
        return UIImage(named: "Wave - 5 Blue")!
        
    default:
        return UIImage(named: "Wave - 1 Red")!
    }
    
}
