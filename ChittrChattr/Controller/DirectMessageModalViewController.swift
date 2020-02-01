//
//  DirectMessageModalViewController.swift
//  ChittrChattr
//
//  Created by Mycah on 4/13/18.
//  Copyright © 2018 Mycah. All rights reserved.
//

import UIKit
import Firebase

class DirectMessageModalViewController: UIViewController {

    //May need to check that these are filtered
    var friendUserName : String?
    var friendUserID : String?
    var chatroomSentFrom : String?
    var specificMessage : String?
    
    //Variables
    let ref = Database.database().reference(fromURL: Private().DATABASE_URL_FIREBASE)
    var chattersArray : [String] = [String]()
    var chatRoomNameForDB : String?
    
    //Currently logged in profile information
    var currentUserID : String?
    var filteredName : String?
    
    //Outlets
    @IBOutlet weak var userImageFromChat: UIImageView!
    @IBOutlet weak var userNameFromChatLabel: UILabel!
    @IBOutlet weak var sendMessageButton: UIButton!
    @IBOutlet weak var userDescriptionDisplay: UILabel!
    @IBOutlet weak var reportButtonDisplay: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        userImageFromChat.layer.cornerRadius = userImageFromChat.frame.size.width / 2;
        userImageFromChat.clipsToBounds = true;
        
        filterEmailAndName()
        
        //Make sure this button is enabled
        sendMessageButton.isEnabled = true
        
        //Check is the users email is the same as the profiles email
        noSendMessageButton()
        
        if friendUserName != nil{
            userNameFromChatLabel.text = friendUserName
        }
        
        if friendUserID != nil{
            //Retrieve Image from URL
            ref.child("Users").child(friendUserID!).child("PublicRead").observeSingleEvent(of: .value) { (snapshot) in
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
        
        //Call function to alphebetize emails to create a private chatroom
        alphabetizeEmails()
    }
    
//    ******************
//    MARK: Filter Names
//    ******************
    
    func filterEmailAndName(){
        //Get the current users ID
        currentUserID = Auth.auth().currentUser?.uid
        
        //Get the  profile Name and Filter it for the database
        let profileName = Auth.auth().currentUser?.displayName
        filteredName = profileName!.replacingOccurrences(of: ".", with: ",", options: NSString.CompareOptions.literal, range: nil)
    }
    
//    *************
//    MARK: Buttons
//    *************
    
    //close the Modal
    @IBAction func closeButton(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    //Check if emails are the same to disable send message button
    func noSendMessageButton(){

        if currentUserID == friendUserID {
            
            sendMessageButton.setTitle("DELETE YOUR MESSAGE", for: .normal)
            sendMessageButton.isEnabled = true
            
            reportButtonDisplay.isHidden = true
        }
        
    }
    
    @IBAction func sendMessageButton(_ sender: Any) {
        if currentUserID == friendUserID{
            
            //Create an alert to ensure they want to delete message
            //show alert
            let alertController = UIAlertController(title: nil, message:"Are you sure you want to Delete your message?", preferredStyle: UIAlertControllerStyle.alert)
            
            alertController.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.default,handler: nil))
            alertController.addAction(UIAlertAction(title: "Yes", style: UIAlertActionStyle.default){ action -> Void in
                
                //Make feature to delete message
                self.ref.child("Chatrooms").child("LocationRooms").child(self.chatroomSentFrom!).child(self.specificMessage!).removeValue()
                
                let alertController = UIAlertController(title: nil, message:"Exit and Re-Enter the Chatroom to see changes", preferredStyle: UIAlertControllerStyle.alert)
                
                alertController.addAction(UIAlertAction(title: "Got it", style: UIAlertActionStyle.default){ action -> Void in
                    
                    self.dismiss(animated: true, completion: nil)
                    
                })
                
                self.present(alertController, animated: true, completion: nil)
               
            })
            
            self.present(alertController, animated: true, completion: nil)
            
            
        }else{
            performSegue(withIdentifier: "modalToPrivateChat", sender: self)
            print("Sent a message")
        }
        
    }
    @IBAction func repportUser(_ sender: Any) {
        performSegue(withIdentifier: "chatroomToReport", sender: self)
    }
    
//    ****************************
//    MARK: Alphabetize The emails
//    ****************************
    
    func alphabetizeEmails(){
        
        //check for user and profile, add to Array
        if let userAdd = friendUserID{
            chattersArray.append(userAdd)
        }
        
        if let profileAdd = currentUserID{
            chattersArray.append(profileAdd)
        }
        
        //Alphabetize the names in the array
        let alphabetizedUsers = chattersArray.sorted()
        
        //Set up the chat room Name for the database
        chatRoomNameForDB = "\(alphabetizedUsers[0])" + " - " + "\(alphabetizedUsers[1])"
        
    }
    
//        ***********
//        MARK: Segue
//        ***********
    
    //Prepare for Segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "modalToPrivateChat"{
            let destVC = segue.destination as! PrivateMessageChatViewController
            
            //Send things to the destVC
            destVC.friendName = friendUserName
            destVC.friendUID = friendUserID
            destVC.chatroomDBName = chatRoomNameForDB
            
        }else if segue.identifier == "chatroomToReport"{
            //Send things to report
            let destVC = segue.destination as! ReportUserViewController
            
            destVC.friendName = friendUserName
            destVC.friendUID = friendUserID
            destVC.chatroomReportedFrom = chatroomSentFrom
        }
    }
}
