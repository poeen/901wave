//
//  CommentVC.swift
//  901wave
//
//  Created by Kareem Dasilva on 10/18/17.
//  Copyright © 2017 Poeen. All rights reserved.
//

import UIKit
import Firebase

class CommmentVC:UIViewController {
    var comments = [Comment]()
    @IBOutlet weak var fullCommentTableView: UITableView!
    @IBOutlet weak var addCommentBox: UITextView!
    
    @IBOutlet weak var submitBtn: UIButton!
    
    var waveKey:String?
    
    
    @IBAction func submitButtonPressed(_ sender: Any) {
        if addCommentBox.text == "" {
            let alertController = UIAlertController(title: "Error", message: "Please enter a comment", preferredStyle: .alert)
            
            let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
            alertController.addAction(defaultAction)
            
            present(alertController, animated: true, completion: nil)
            
        } else {
        sendCommentToDatabase()
        performSegue(withIdentifier: "aftersubmit", sender: nil)
        }
    }
    
    func sendCommentToDatabase(){
         let waveRef = Database.database().reference().child("Wave").child("Memphis").child(waveKey!).child("Comments")
        let saveArray: NSArray = NSArray(object: addCommentBox.text)
        let values = ["UserID" : Auth.auth().currentUser?.uid, "comment": self.addCommentBox.text, "time":String(describing: Date())] as [String : Any]
        waveRef.childByAutoId().setValue(values)
                
            }
    
    @IBAction func backPressed(_ sender: Any) {
        performSegue(withIdentifier: "back", sender: nil)
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "back" {
            
            if let detailVC = segue.destination as? DetailedVenue {
                detailVC.key = waveKey
                
            }
        }
        
        if segue.identifier == "aftersubmit" {
            if let detailVC = segue.destination as? DetailedVenue {
                detailVC.key = waveKey
                
            }
 
        }
    }

    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        submitBtn.layer.cornerRadius = 10
        submitBtn.layer.borderWidth = 1
        submitBtn.layer.borderColor = UIColor.black.cgColor
        
        let waveRef = Database.database().reference().child("Wave").child("Memphis").child(waveKey!).child("Comments")
        waveRef.observe(.value, with: { snapshot in
            self.comments = []
            if let snapshot = snapshot.children.allObjects as? [DataSnapshot] {
                for snap in snapshot{
                    if let dictionary = snap.value as? Dictionary<String,AnyObject>{
                        let specificComment = dictionary["comment"] as? String
                        
                        let currentEvent = Comment(comment:specificComment!)
                        self.comments.append(currentEvent)
                    }
                }
                self.comments.reverse()
                self.fullCommentTableView.reloadData()
            }
        })
    }
}

extension CommmentVC:UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = fullCommentTableView.dequeueReusableCell(withIdentifier: "cell") as? FullCommentCell
        cell?.fullCommentLabel.text = comments[indexPath.row].comment
        
        return cell!
        
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            self.comments.remove(at: indexPath.row)
            DataService.ds.Ref_Agendas.child(waveKey!).child("Comments").observeSingleEvent(of: .value, with: { snapshot in
                
                    let commentKey = snapshot.key as? String
                    print(commentKey)
                    tableView.deleteRows(at: [indexPath as IndexPath], with: UITableViewRowAnimation.automatic)
                    
                    //DataService.ds.Ref_Agendas.child(self.waveKey!).child("Comments").child(commentKey!).removeValue()
                    print(commentKey)
                
            })
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return comments.count
    }
}

extension CommmentVC:UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
}
