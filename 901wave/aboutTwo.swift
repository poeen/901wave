//
//  aboutTwo.swift
//  901wave
//
//  Created by Kareem Dasilva on 10/29/17.
//  Copyright © 2017 Poeen. All rights reserved.
//

import UIKit

private let reuseIdentifier = "Cell"

class aboutTwo: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        let swipeLeft = UISwipeGestureRecognizer(target: self, action: Selector("swipeToThree"))
        swipeLeft.direction = UISwipeGestureRecognizerDirection.left
        self.view.addGestureRecognizer(swipeLeft)
        
        let swipeRight = UISwipeGestureRecognizer(target: self, action: Selector("swipeToOne"))
        swipeRight.direction = UISwipeGestureRecognizerDirection.right
        self.view.addGestureRecognizer(swipeRight)
        
        
        
        
    }
    func swipeToThree(){
        self.performSegue(withIdentifier: "aTwoToAThree", sender: self)
    }

    func swipeToOne(){
        self.performSegue(withIdentifier: "aTwoToAOne", sender: self)
    }

}
