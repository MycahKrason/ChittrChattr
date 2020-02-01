//
//  FriendModalViewController.swift
//  ChittrChattr
//
//  Created by Mycah on 4/20/18.
//  Copyright © 2018 Mycah. All rights reserved.
//

import UIKit
import Firebase

class FriendModalViewController: UIViewController {

    //Imported from chatroom
    //Information of person you are trying to connect with
    
    //May need to check that these are filtered
    var userName : String?
    var friendID : String?
    var chatRoomNameForDB : String?
    
    //Variables
    let ref = Database.database().reference(fromURL: Private().DATABASE_URL_FIREBASE)
    var chattersArray : [String] = [String]()
    var userIsBlocked : Bool?
    
    //Currently logged in profile information
    var currentUserID : String?
    var filteredName : String?
    
    //Outlets
    @IBOutlet weak var userNameFromChatLabel: UILabel!
    @IBOutlet weak var userImageFromChat: UIImageView!
    @IBOutlet weak var userDescriptionDisplay: UILabel!
    @IBOutlet weak var blockButtonDisplay: UIButton!
    @IBOutlet weak var reportButtonDisplay: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        userImageFromChat.layer.cornerRadius = userImageFromChat.frame.size.width / 2;
        userImageFromChat.clipsToBounds = true;
        
        filterEmailAndName()
        noBlockButton()
        
        if userName != nil{
            userNameFromChatLabel.text = userName
        }
        
        if friendID != nil{
            //Retrieve Image from URL
            ref.child("Users").child(friendID!).child("PublicRead").observeSingleEvent(of: .value) { (snapshot) in
                //Check for snapshot
                if !snapshot.exists() {
                    return
                }
                //look for the profile image
                let profileInfo = snapshot.value as! NSDictionary
                if let profileImageUrl = profileInfo["ProfileImage"]{
                    
                    //call this from the extension
                    self.userImageFromChat.loadImageUsingCacheWithUrlString(urlString: profileImageUrl as! String)
                    
                }else{
                    //For troubleshooting
                    print("User has no ProfileImage")
                }
                
                if let userDescription = profileInfo["Description"]{
                    self.userDescriptionDisplay.text = userDescription as? String
                }
            }
        }
    }
    
    //    ******************
    //    MARK: Filter Names
    //    ******************
    
    func filterEmailAndName(){
        
        //Get the current user's id
        currentUserID = Auth.auth().currentUser?.uid
        
        //Get the  profile Name and Filter it for the database
        let profileName = Auth.auth().currentUser?.displayName
        filteredName = profileName!.replacingOccurrences(of: ".", with: ",", options: NSString.CompareOptions.literal, range: nil)
    }
    
    //    *************
    //    MARK: Buttons
    //    *************
    @IBAction func blockButtonPressed(_ sender: Any) {
        print("user has been blocked")
        //update FB to show that the fried is blocked
        
        if userIsBlocked == nil || userIsBlocked! == true {
            self.blockButtonDisplay.setTitle("Unblock User", for: .normal)
            ref.child("Users").child(currentUserID!).child("PublicWrite").child("Friends").child(friendID!).updateChildValues(["Blocked" : true])
            userIsBlocked = false
         
        }else{
            self.blockButtonDisplay.setTitle("Block User", for: .normal)
            ref.child("Users").child(currentUserID!).child("PublicWrite").child("Friends").child(friendID!).updateChildValues(["Blocked" : false])
            userIsBlocked = true
            
        }
    }
    
    //Check if emails are the same to disable send message button
    func noBlockButton(){
        
        if currentUserID == friendID {
            blockButtonDisplay.setTitle("This is You", for: .normal)
            blockButtonDisplay.isEnabled = false
            reportButtonDisplay.isHidden = true
        }else{
            reportButtonDisplay.isHidden = false
            ref.child("Users").child(currentUserID!).child("PublicWrite").child("Friends").child(friendID!).observeSingleEvent(of: .value) { (snapshot) in
                //Check for snapshot
                if !snapshot.exists() {
                    return
                }
                //see if the user is already blocked
                let profileInfo = snapshot.value as! NSDictionary
                
                //Check is there is any data for being blocked
                if let isBlocked = profileInfo["Blocked"] as? Bool{
                    if isBlocked == true {
                        self.blockButtonDisplay.setTitle("Unblock User", for: .normal)
                        self.userIsBlocked = false
                    }else{
                        self.blockButtonDisplay.setTitle("Block User", for: .normal)
                        self.userIsBlocked = true
                    }
                }
            }
        }
    }
    
    @IBAction func closeButton(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }

    @IBAction func reportUserButton(_ sender: Any) {
        performSegue(withIdentifier: "friendToReport", sender: self)
    }
    
    //        ***********
    //        MARK: Segue
    //        ***********
    
    //Prepare for Segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        //Get the destination view controller
        let destVC = segue.destination as! ReportUserViewController
        
        //Send things to the destVC
        destVC.friendName = userName
        destVC.friendUID = friendID
        destVC.chatroomReportedFrom = chatRoomNameForDB
                
    }
}
