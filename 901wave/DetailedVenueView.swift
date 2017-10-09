//
//  DetailedVenueView.swift
//  901wave
//
//  Created by Kareem Dasilva on 10/9/17.
//  Copyright © 2017 Poeen. All rights reserved.
//

import Foundation
import UIKit

class DetailedVenue: UIViewController{
    // image views, the rating circle will display the actualy wave rating.
    // venueBackground is just the plain gray background on the whole screen
    // line is just the line that separates the contact info from the venue description.
    @IBOutlet weak var venueImage: UIImageView!
    @IBOutlet weak var ratingCircle: UIImageView!
    @IBOutlet weak var imageNSeparation: UIImageView!
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
    override func viewDidLoad() {
        super.viewDidLoad()
    }
}
