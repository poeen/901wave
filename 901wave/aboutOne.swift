//
//  aboutOne.swift
//  901wave
//
//  Created by Kareem Dasilva on 10/29/17.
//  Copyright © 2017 Poeen. All rights reserved.
//

import UIKit

private let reuseIdentifier = "Cell"

class aboutOne: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        let swipeLeft = UISwipeGestureRecognizer(target: self, action: Selector("swipeToTwo"))
        swipeLeft.direction = UISwipeGestureRecognizerDirection.left
        self.view.addGestureRecognizer(swipeLeft)
       
        

        
    }
    func swipeToTwo(){
        self.performSegue(withIdentifier: "aOneToATwo", sender: self)
    }

}
