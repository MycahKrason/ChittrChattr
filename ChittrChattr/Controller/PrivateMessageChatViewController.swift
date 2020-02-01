//
//  PrivateMessageChatViewController.swift
//  ChittrChattr
//
//  Created by Mycah on 4/15/18.
//  Copyright © 2018 Mycah. All rights reserved.
//

import UIKit
import Firebase

class PrivateMessageChatViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate {

    //Variables sent from DirectMessageViewController
    var chatroomDBName : String?
    var friendName : String?
    var friendUID : String?
    
    //User's information
    var currentUserID : String?
    var filteredName : String?
    
    //Variables
    var timePosted : String?
    var messageArray : [Message] = [Message]()
    let ref = Database.database().reference(fromURL: Private().DATABASE_URL_FIREBASE)
    
    //Outlets
    //messageTableView
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var messageTableView: UITableView!
    @IBOutlet weak var messageTextfield: UITextField!
    @IBOutlet weak var chatRoomTitleLabel: UILabel!
    @IBOutlet weak var backButtonDisplay: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Test that everything is being sent over
        print(friendUID!)
        print(friendName!)
        print(chatroomDBName!)
        
        //Get the filtered user info
        getUserInfo()
        
        //Set the chat room title label
        if let chatRoomLabel = friendName{
            chatRoomTitleLabel.text = chatRoomLabel
        }
        
        //Set Delegate for TableView
        messageTableView.delegate = self
        messageTableView.dataSource = self
        
        //set image size aspect
        backButtonDisplay.imageView?.contentMode = UIViewContentMode.scaleAspectFit
        backButtonDisplay.imageEdgeInsets = UIEdgeInsetsMake(10, 10, 10, 10);
        
        //Set Delegate for Text Input
        messageTextfield.delegate = self
        
        //Register the CustomMessageCell xib file
        messageTableView.register(UINib(nibName: "CustomMessageCell", bundle: nil), forCellReuseIdentifier: "customMessageCell")
        
        //configure Table view
        configureTableView()
        
        //Setup input components
        setupInputComponents()
        
        //set up keyboard observers
        setupKeyboardObservers()
        
        //Hide keyboard when tapped away
        hideKeyboardWhenTappedAround()
        
        //Change Return to Send on the keyboard
        messageTextfield.returnKeyType = UIReturnKeyType.send
        
        //Call the retrieveMessages function... to retrieve messages
        retrieveMessages()
        
        //Get rid of the message Separator
        messageTableView.separatorStyle = .none
        
    }
    
    //***********************
    //MARK: Table Information
    //***********************
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "customMessageCell", for: indexPath) as! CustomMessageCell

        cell.messageBody.text = messageArray[indexPath.row].messageBody
        cell.senderEmail = messageArray[indexPath.row].sender
        cell.senderUsername.text = messageArray[indexPath.row].profileName
        cell.timeLabel.text = messageArray[indexPath.row].messageTime
        
        //dont highlight
        cell.selectionStyle = .none
        
        //Retrieve Image from URL
        ref.child("Users").child(messageArray[indexPath.row].sender).child("PublicRead").observeSingleEvent(of: .value) { (snapshot) in
            //Check for snapshot
            if !snapshot.exists() {
                return
            }
            //look for the profile image
            let profileInfo = snapshot.value as! NSDictionary
            if let profileImageUrl = profileInfo["ProfileImage"]{

                //call this from the extension
                cell.profileImage.loadImageUsingCacheWithUrlString(urlString: profileImageUrl as! String)

            }else{
                //For troubleshooting
                print("User has no ProfileImage")
                let image : UIImage = UIImage(named: "ProfileIcon")!
                cell.profileImage.image = image
                print("User has no ProfileImage")
            }

        }

        //Set a different color for text
        if cell.senderEmail == currentUserID!{
            //Messages we sent
            cell.messageBackground.backgroundColor = UIColor(red: 152/255, green: 229/255, blue: 93/255, alpha: 1.0)
        }else{
            //Messages other people sent
            cell.messageBackground.backgroundColor = UIColor(red: 240/255, green: 244/255, blue: 238/255, alpha: 1.0)
        }

        //This will load the Messages from the bottom
        messageTableView.transform = CGAffineTransform(rotationAngle: -CGFloat.pi)
        cell.transform = CGAffineTransform(rotationAngle: CGFloat.pi)

        return cell
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if messageArray.count < 50{
            return messageArray.count
        }else{
            return 50
        }
    }
    
    //Set up the Cells to be buttons to retrieve the modal
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "directChatToModal", sender: self)
    }
    
    //Func to configure the table view, for instance, if a message is longer than normal
    func configureTableView(){
        
        messageTableView.rowHeight = UITableViewAutomaticDimension
        messageTableView.estimatedRowHeight = 200.0
        
    }
    
//    ***************
//    MARK: User Info
//    ***************
    
    func getUserInfo(){
        //Get the  profile Name and Filter it for the database
        let profileName = Auth.auth().currentUser?.displayName
        filteredName = profileName!.replacingOccurrences(of: ".", with: ",", options: NSString.CompareOptions.literal, range: nil)
        
        //Get the current user's id
        currentUserID = Auth.auth().currentUser?.uid
    }
    
    //************************
    //MARK: Send Message Stuff
    //************************
    
    func sendMessageContent(){
        //Turn off Send functionality so that user can't send a message a billion times on accident
        messageTextfield.isEnabled = false
        
        //Add friend
        if self.messageArray.count < 1 {
            //Set Up friend in user profile
            self.ref.child("Users").child(self.currentUserID!).child("PublicWrite").child("Friends").child(self.friendUID!).updateChildValues(["Name" : self.friendName!, "UserID" : self.friendUID!, "Blocked" : false])
            
            //Set Up User in friend profile
            self.ref.child("Users").child(self.friendUID!).child("PublicWrite").child("Friends").child(self.currentUserID!).updateChildValues(["Name" : self.filteredName!, "UserID" : self.currentUserID!, "Blocked" : false])
        }
        
        ref.child("Users").child(currentUserID!).child("PublicWrite").child("Friends").child(friendUID!).observeSingleEvent(of: .value) { (snapshot) in
            //Check for snapshot
            if !snapshot.exists() {
                return
            }
            //see if the user is already blocked
            let profileInfo = snapshot.value as! NSDictionary
            
            //Check is there is any data for being blocked
            let isBlocked = profileInfo["Blocked"] as? Bool
            if isBlocked == true {
                
                //Disable text box
                self.messageTextfield.isEnabled = true
                self.messageTextfield.placeholder = "Unblock User to send message"
                //Clear out the textfield
                self.messageTextfield.text = ""
                
            }else if (self.messageTextfield.text?.hasPrefix(" "))! || (self.messageTextfield.text?.hasSuffix("     "))! || self.messageTextfield.text == ""{
                
                //This will check to make sure there are no blank spaces so some fool cant just type spaces
                print("Stop posting spaces")
                //Let the user know they are using to many spaces
                self.messageTextfield.placeholder = "No Spaces before or after text"
                
                //Re-enable sendButton and Textfield so the user can send more messages
                self.messageTextfield.isEnabled = true
                
                //Clear out the textfield
                self.messageTextfield.text = ""
                
            }else{
                print("\n\nThanks for posting an actual post!\n\n")
                
                //Set Notifications
                //Profile Notification
                //FriendList notification
                self.ref.child("Users").child(self.friendUID!).child("PublicWrite").child("Friends").child(self.currentUserID!).updateChildValues(["Notification" : true])
                
                //Get Time
                self.timePosted = DateFormatter.localizedString(from: Date(), dateStyle: DateFormatter.Style.short, timeStyle: DateFormatter.Style.short)
                
                //Set up the message
                let messageDictionary = ["MessageBody" : self.messageTextfield.text, "Time" : self.timePosted]
                
                //Clear out the textfield
                self.messageTextfield.text = ""
                
                //Create a custom random key for the message
                //Set up the message to be stored like the news feed
                
                //This is where the messages will be stored
                let allMessagesDB = Database.database().reference().child("AllDirectMessages").childByAutoId()
                
                allMessagesDB.updateChildValues(messageDictionary, withCompletionBlock: { (error, ref) in
                    
                    if error != nil{
                        print(error!)
                        return
                    }
                    
                    let userMessageId = allMessagesDB.key
                    
                    let userMessageRef = Database.database().reference().child("Users").child(self.currentUserID!).child("PublicWrite").child("Friends").child(self.friendUID!).child("DirectMessages")
                    
                    let friendMessageRef = Database.database().reference().child("Users").child(self.friendUID!).child("PublicWrite").child("Friends").child(self.currentUserID!).child("DirectMessages")
                    
                    //One means it came from the user
                    userMessageRef.updateChildValues([userMessageId : 1])
                    //Two means it cam from the friend
                    friendMessageRef.updateChildValues([userMessageId : 2])
                    
                    //Re-enable sendButton and Textfield so the user can send more messages
                    self.messageTextfield.isEnabled = true
                    
                })
            }
        }
    }

    func retrieveMessages(){

        let ref = Database.database().reference().child("Users").child(self.currentUserID!).child("PublicWrite").child("Friends").child(self.friendUID!).child("DirectMessages")
        
        ref.observe(.childAdded) { (snapshot) in

            let messageID = snapshot.key
            
            print("\n\n\n\(snapshot.value!)\n\n\n")
            let messageUserIdentifierNumber = snapshot.value!
            let messageUserIdentifier = "\(messageUserIdentifierNumber)"
            
            let messageRef = Database.database().reference().child("AllDirectMessages").child(messageID)

            messageRef.observe(.value, with: { (snapshot) in
                let snapshotValue = snapshot.value as! Dictionary<String, String>

                //Grab Values from the message Dictionary
                let messageBody = snapshotValue["MessageBody"]!
                let timeDisplay = snapshotValue["Time"]!

                //Create a Message Object
                let message = Message()
                message.messageBody = messageBody
                message.messageTime = timeDisplay
                
                //need to check whether the message id has a 1 or a 2
                if messageUserIdentifier == "1"{
                    message.profileName = self.filteredName!
                    message.sender = self.currentUserID!
                }else if messageUserIdentifier == "2"{
                    message.profileName = self.friendName!
                    message.sender = self.friendUID!
                }
                
                //add message to the messageArray
                self.messageArray.insert(message, at: 0)

                //configure the table view
                self.configureTableView()

                //Friends List
                self.ref.child("Users").child(self.currentUserID!).child("PublicWrite").child("Friends").child(self.friendUID!).updateChildValues(["Notification" : false])

                //reload data
                self.messageTableView.reloadData()

            })

        }
    }

    //Send a message when pressing enter
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        sendMessageContent()
        return true
    }

    //**************
    //MARK: Keyboard
    //**************
    
    //Setup the keyboard observers
    func setupKeyboardObservers(){
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        
    }
    
    //Turn off the keyboard observers
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc func handleKeyboardWillShow(notification: NSNotification) {
        
        if let keyboardFrame = (notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            //Get keyboard duration
            let keyboardDuration = notification.userInfo?[UIKeyboardAnimationDurationUserInfoKey] as! Double
            
            //Move input field to correct height
            let window = UIApplication.shared.keyWindow
            if #available(iOS 11.0, *) {
                containerViewBottomAnchor?.constant = -keyboardFrame.height + (window?.safeAreaInsets.bottom)!
            } else {
                // Fallback on earlier versions
                containerViewBottomAnchor?.constant = -keyboardFrame.height
            }
            
            //Animate input field to move with keyboard
            UIView.animate(withDuration: keyboardDuration, animations: {
                self.view.layoutIfNeeded()
            })
        }
       
    }
    
    @objc func handleKeyboardWillHide(notification: NSNotification) {
        let keyboardDuration = notification.userInfo?[UIKeyboardAnimationDurationUserInfoKey] as! Double
        
        //Move input field to correct height
        containerViewBottomAnchor?.constant = 0
        //Animate input field to move with keyboard
        UIView.animate(withDuration: keyboardDuration, animations: {
            self.view.layoutIfNeeded()
        })
    }
    
    var containerViewBottomAnchor : NSLayoutConstraint?
    var messageTableViewBottomAnchor : NSLayoutConstraint?
    
    //Set up Input components
    func setupInputComponents(){
        
        //Set up Message Table view
        messageTableView.translatesAutoresizingMaskIntoConstraints = false
        
        messageTableViewBottomAnchor = messageTableView.bottomAnchor.constraint(equalTo: containerView.topAnchor)
        messageTableViewBottomAnchor?.isActive = true
        
        messageTableView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        messageTableView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        
        //Set up Text input Container Constraints
        containerView.translatesAutoresizingMaskIntoConstraints = false
        containerView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        
        if #available(iOS 11.0, *) {
            containerViewBottomAnchor = containerView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        } else {
            // Fallback on earlier versions
            containerViewBottomAnchor = containerView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
            
        }
        containerViewBottomAnchor?.isActive = true
        containerView.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
        containerView.heightAnchor.constraint(equalToConstant: 55).isActive = true
   
    }
    
//    *************
//    MARK: Buttons
//    *************
    
    @IBAction func backButton(_ sender: Any) {
        dismiss(animated: true, completion: nil)
        Database.database().reference().child("AllDirectMessages").removeAllObservers()
        Database.database().reference().child("Users").child(self.currentUserID!).child("PublicWrite").child("Friends").child(self.friendUID!).child("DirectMessages").removeAllObservers()
        
    }
    
    //        ***********
    //        MARK: Segue
    //        ***********
    
    //Prepare for Segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "directChatToModal"{
            
            //Get the indexPath so we know what was clicked
            if let indexPath = messageTableView.indexPathForSelectedRow{
                
                //Get the destination view controller
                let destVC = segue.destination as! FriendModalViewController
                
                //Get user name
                let userNameFromChat = messageArray[indexPath.row].profileName
                let userEmailFromChat = messageArray[indexPath.row].sender
                
                //Send things to the destVC
                destVC.userName = userNameFromChat
                destVC.friendID = userEmailFromChat
                destVC.chatRoomNameForDB = chatroomDBName
            }
            
        }
    }
}
