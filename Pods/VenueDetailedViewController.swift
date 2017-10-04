//
//  VenueDetailedViewController.swift
//  Pods
//
//  Created by Kareem Dasilva on 10/4/17.
//
//

import UIKit

class VenueDetailedViewController: UIViewController {
    /*The comment section is just the main label that separates the comments for the description. These others should be self-explanatory.
    */
    @IBOutlet weak var venueCommentSection: UILabel!
    @IBOutlet weak var venueContactInfo: UILabel!
    @IBOutlet weak var venueAddress: UILabel!
    @IBOutlet weak var venueTitle: UILabel!
    @IBOutlet weak var venueDescription: UILabel!
    /*Here are the buttons for the detailed venue page. BACK button
    should take you back to the map while the JOIN WAVE button will
    allow the user to join the wave
    */
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var joinWaveButton: UIButton!
    /*These are the image views, the background is just that basic gray
     The border is just there to look pretty and divide the picture from the
     labels. Inside the rating wave circle, the wave intesity should pop up.
     Venue image allows the venue to put whatever image they want into that spot.
    */
    @IBOutlet weak var venueDetailedBackground: UIImageView!
    @IBOutlet weak var venueImageBorder: UIImageView!
    @IBOutlet weak var ratingWaveCircle: UIImageView!
    @IBOutlet weak var venueImage: UIImageView!
    

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
