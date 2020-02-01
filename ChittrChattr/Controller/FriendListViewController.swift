//
//  FriendListViewController.swift
//  ChittrChattr
//
//  Created by Mycah on 4/10/18.
//  Copyright © 2018 Mycah. All rights reserved.
//

import UIKit
import Firebase

class FriendListViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    //Variables
    let ref = Database.database().reference(fromURL: Private().DATABASE_URL_FIREBASE)
    var currentUserID : String?
    var friendArray : [FriendInfo] = [FriendInfo]()
    
    //Variable to send over
    var chatRoomNameForDB : String?
    
    //Outlets
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var backButtonDisplay: UIButton!
    @IBOutlet weak var infoButtonDisplay: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //register table view change this for friend custom cell
        tableView.register(UINib(nibName: "CustomFriendListCell", bundle: nil), forCellReuseIdentifier: "customFriendListCell")
        
        //set image size aspect
        backButtonDisplay.imageView?.contentMode = UIViewContentMode.scaleAspectFit
        backButtonDisplay.imageEdgeInsets = UIEdgeInsetsMake(10, 10, 10, 10);
        //set image size aspect
        infoButtonDisplay.imageView?.contentMode = UIViewContentMode.scaleAspectFit
        infoButtonDisplay.imageEdgeInsets = UIEdgeInsetsMake(5, 5, 5, 5)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        //set tableView Delegates
        tableView.dataSource = self
        tableView.delegate = self
        currentUserID = Auth.auth().currentUser?.uid
        
        fetchFriends()
    }
    
    //Get a list of all of your friends
    func fetchFriends(){
        
        friendArray = []
        
        ref.child("Users").child(currentUserID!).child("PublicWrite").child("Friends").observeSingleEvent(of: .value) { (snapshot) in
            
            for child in snapshot.children {
                
                let friendInfo = FriendInfo()
                
                let snap = child as! DataSnapshot
                //let keyt = snap.key
                let valuet = snap.value as! Dictionary<String, Any?>
                
                //Set Friends info to send
                let userName = valuet["Name"] as? String
                friendInfo.friendName = userName!

                let friendID = valuet["UserID"] as? String
                friendInfo.friendID = friendID!
                
                let friendNotification = valuet["Notification"] as? Bool
                friendInfo.friendNotification = friendNotification!
                
                if let friendIsblocked = valuet["Blocked"] as? Bool{
                    friendInfo.friendIsBlocked = friendIsblocked
                }
                
                //append the friend object to the array
                self.friendArray.append(friendInfo)

            }
            self.tableView.reloadData()
        }
      
    }
    
    //*******************************
    //****** Table Information ******
    //*******************************
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        //Change this for when your use friend custom cell
        let cell = tableView.dequeueReusableCell(withIdentifier: "customFriendListCell", for: indexPath) as! CustomFriendListCell
        
        //dont highlight
        cell.selectionStyle = .none
        
        //Retrieve Image from URL and notification
        ref.child("Users").child(friendArray[indexPath.row].friendID).child("PublicRead").observeSingleEvent(of: .value) { (snapshot) in
            //Check for snapshot
            if !snapshot.exists() {
                return
            }
            //look for the profile image
            let profileInfo = snapshot.value as! NSDictionary
            if let profileImageUrl = profileInfo["ProfileImage"]{
                
                //call this from the extension
                cell.friendImageDisplay.loadImageUsingCacheWithUrlString(urlString: profileImageUrl as! String)
                
            }else{
                
                //For troubleshooting
                print("User has no ProfileImage")
                
                let image : UIImage = UIImage(named: "ProfileIcon")!
                cell.friendImageDisplay.image = image
                print("User has no ProfileImage")
            }
            
        }
        
       cell.friendNameLabel.text = friendArray[indexPath.row].friendName
        
        //set notification image
        if friendArray[indexPath.row].friendNotification == true && friendArray[indexPath.row].friendIsBlocked == false{
            cell.friendNotificationDisplay.isHidden = false
        }else{
            cell.friendNotificationDisplay.isHidden = true
        }
        
        //show text that says blocked and darken the cell
        if friendArray[indexPath.row].friendIsBlocked == true{
            cell.friendIsBlockedDisplay.isHidden = false
        }else{
            cell.friendIsBlockedDisplay.isHidden = true
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return friendArray.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "FriendListToPrivateMessage", sender: self)
    }
    
    //        ***********
    //        MARK: Segue
    //        ***********
    
    //Prepare for Segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "FriendListToPrivateMessage"{

            //Get the indexPath so we know what was clicked
            if let indexPath = tableView.indexPathForSelectedRow{
                
                //Get the destination view controller
                let destVC = segue.destination as! PrivateMessageChatViewController

                //Get friend name, email, and chatroom name
                let userName = friendArray[indexPath.row].friendName
                let friendId = friendArray[indexPath.row].friendID
                let chatRoomNameForDB = friendArray[indexPath.row].chatRoomName

                //Send things to the destVC
                destVC.friendName = userName
                destVC.friendUID = friendId
                destVC.chatroomDBName = chatRoomNameForDB

            }
        }else if segue.identifier == "friendListToModal"{
            
            let destVC = segue.destination as! InfoModalViewController
            destVC.receivedInfo = "Click on a friend to start chatting"
            
        }
        
    }
    
    @IBAction func backButton(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
}
