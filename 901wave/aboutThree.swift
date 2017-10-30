//
//  aboutThree.swift
//  901wave
//
//  Created by Kareem Dasilva on 10/29/17.
//  Copyright © 2017 Poeen. All rights reserved.
//

import UIKit

private let reuseIdentifier = "Cell"

class aboutThree: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        let swipeRight = UISwipeGestureRecognizer(target: self, action: Selector("swipeToTwo"))
        swipeRight.direction = UISwipeGestureRecognizerDirection.right
        self.view.addGestureRecognizer(swipeRight)
    }

    func swipeToTwo(){
        self.performSegue(withIdentifier: "aThreeToATwo", sender: self)
    }

}
