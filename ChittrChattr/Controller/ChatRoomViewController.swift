//
//  ChatRoomViewController.swift
//  ChittrChattr
//
//  Created by Mycah on 4/7/18.
//  Copyright © 2018 Mycah. All rights reserved.
//

import UIKit
import Firebase

class ChatRoomViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate {
    
    //Imported from the LocationView
    var chatRoomName : String?
    var chatRoomAddress : String?
    var newsChatRoomId : String?
    
    //Instance variables
    var timePosted : String?
    var messageArray : [Message] = [Message]()
    var filteredEmail : String?
    var userID : String?
    let ref = Database.database().reference()
    
    //Linked Outlets
    
    @IBOutlet weak var messageTableView: UITableView!
    @IBOutlet weak var messageTextfield: UITextField!
    @IBOutlet weak var chatroomTitle: UILabel!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var backButtonDisplay: UIButton!
    @IBOutlet weak var infoButtonDisplay: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Set Delegate for TableView
        messageTableView.delegate = self
        messageTableView.dataSource = self
        
        //Set Delegate for Text Input
        messageTextfield.delegate = self
        
        //Set the ChatRoom Title
        if let chatRoomName = chatRoomName {
            chatroomTitle.text = chatRoomName
        }
        
        //set image size aspect
        backButtonDisplay.imageView?.contentMode = UIViewContentMode.scaleAspectFit
        backButtonDisplay.imageEdgeInsets = UIEdgeInsetsMake(10, 10, 10, 10);
        //set image size aspect
        infoButtonDisplay.imageView?.contentMode = UIViewContentMode.scaleAspectFit
        infoButtonDisplay.imageEdgeInsets = UIEdgeInsetsMake(5, 5, 5, 5)
        
        //Get User ID
        userID = Auth.auth().currentUser?.uid
        
        //Set up constraints for input components
        setupInputComponents()
        
        //Set up the Keyboard
        setupKeyboardObservers()
        
        //Set up tap gesture
        hideKeyboardWhenTappedAround()
        
        //Change Return to Send on the keyboard
        messageTextfield.returnKeyType = UIReturnKeyType.send
        
        //Register the CustomMessageCell xib file
        messageTableView.register(UINib(nibName: "CustomMessageCell", bundle: nil), forCellReuseIdentifier: "customMessageCell")
        
        //call configureTableView so your tables don't look TOTALLY STUPID
        configureTableView()
        
        //Call the retrieveMessages function... to retrieve messages
        retrieveMessages()
        
        //Get rid of the message Separator
        messageTableView.separatorStyle = .none
        
    }
    
   
    
    //*******************************
    //****** Table Information ******
    //*******************************
    
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
                let image : UIImage = UIImage(named: "ProfileIcon")!
                cell.profileImage.image = image
                print("User has no ProfileImage")
            }
            
        }
             
        //Set a different color for text
        if cell.senderEmail == userID!{
            //Messages we sent
            cell.messageBackground.backgroundColor = UIColor(red: 152/255, green: 229/255, blue: 93/255, alpha: 1.0)
        }else{
            //Messages other people sent
            //TODO: Make this a random color?! Could be cool
            cell.messageBackground.backgroundColor = UIColor(red: 240/255, green: 244/255, blue: 238/255, alpha: 1.0)
        }
        
        //This will load the Messages from the bottom
        messageTableView.transform = CGAffineTransform(rotationAngle: -CGFloat.pi)
        cell.transform = CGAffineTransform(rotationAngle: CGFloat.pi)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //return messageArray.count
        if messageArray.count < 50{
            return messageArray.count
        }else{
            return 50
        }
        
    }
    
    //Set up the Cells to be buttons to retrieve the modal
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        performSegue(withIdentifier: "modalSegue", sender: self)
        
    }
    
    //Func to configure the table view, for instance, if a message is longer than normal
    func configureTableView(){
        
        messageTableView.rowHeight = UITableViewAutomaticDimension
        messageTableView.estimatedRowHeight = 200.0
        
    }
    
    //************************
    //MARK: Send Message Stuff
    //************************
  
    func sendMessageContent(){
        //Turn off Send functionality so that user can't send a message a billion times on accident
        messageTextfield.isEnabled = false
        
        var messagesDB : DatabaseReference?
        
        //Decide whether the chat room is from the Location or the Newsfeed
        if chatRoomAddress != nil{
            messagesDB = ref.child("Chatrooms").child("LocationRooms").child(chatRoomName! + " - " + chatRoomAddress!)
        }else{
            messagesDB = ref.child("Chatrooms").child("NewsFeedRooms").child("NewsRoomID" + " - " + newsChatRoomId!)
        }
        //Create Dictionary of values for the Sender\
        
        //This will check to make sure there are no blank spaces so some fool cant just type spaces
        if (messageTextfield.text?.hasPrefix(" "))! || (messageTextfield.text?.hasSuffix("     "))! || messageTextfield.text == ""{
            print("Stop posting spaces")
            //Let the user know they are using to many spaces
            messageTextfield.placeholder = "No Spaces before or after text"
            
            //Re-enable sendButton and Textfield so the user can send more messages
            self.messageTextfield.isEnabled = true
            
            //Clear out the textfield
            self.messageTextfield.text = ""
            
        }else{
            print("Thanks for postig an actual post!")
    
            //Get Time
            timePosted = DateFormatter.localizedString(from: Date(), dateStyle: DateFormatter.Style.short, timeStyle: DateFormatter.Style.short)
            
            let messageDictionary = ["Sender" : userID, "MessageBody" : messageTextfield.text, "ProfileName" : Auth.auth().currentUser?.displayName, "Time" : timePosted]
            
            //Clear out the textfield
            self.messageTextfield.text = ""
            
            //Create a custom random key for the message
            messagesDB!.childByAutoId().setValue(messageDictionary){
                (error, reference) in
                
                if error != nil{
                    print(error!)
                }else{
                    print("Message has saved Successfully")
                    
                    //Re-enable sendButton and Textfield so the user can send more messages
                    self.messageTextfield.isEnabled = true
                    
                }
            }
        }
    }
    
    func retrieveMessages(){
        
        var messagesDB : DatabaseReference?
        
        //Decide whether the chat room is from the Location or the Newsfeed
        if chatRoomAddress != nil{
            messagesDB = ref.child("Chatrooms").child("LocationRooms").child(chatRoomName! + " - " + chatRoomAddress!)
        }else{
            messagesDB = ref.child("Chatrooms").child("NewsFeedRooms").child("NewsRoomID" + " - " + newsChatRoomId!)
        }
        //Firebase let us know if any new messages have been added
        messagesDB!.observe(.childAdded) { (snapshot) in
            let snapshotValue = snapshot.value as! Dictionary<String, String>
            
            let text = snapshotValue["MessageBody"]!
            let sender = snapshotValue["Sender"]!
            let profileName = snapshotValue["ProfileName"]!
            let timeDisplay = snapshotValue["Time"]!
            
            //Create a Message Object
            let message = Message()
            message.messageBody = text
            message.sender = sender
            message.profileName = profileName
            message.messageTime = timeDisplay
            message.messageKey = snapshot.key
            
            //TODO: this needs to add the message to the back off the array
            //add message to the messageArray
            self.messageArray.insert(message, at: 0)
            
            //configure the table view
            self.configureTableView()
            //reload data
            self.messageTableView.reloadData()
        }
    }
    
    //Send a message when pressing enter
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        sendMessageContent()
        return true
    }
    
    //**********************
    //****** Keyboard ******
    //**********************
    
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
    
    //    ********************
    //    MARK: Title Bar Area
    //    ********************
    
    @IBAction func backButton(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    
//        ***********
//        MARK: Segue
//        ***********
    
    //Prepare for Segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "modalSegue"{
            
            //Get the indexPath so we know what was clicked
            if let indexPath = messageTableView.indexPathForSelectedRow{
                
                //Get the destination view controller
                let destVC = segue.destination as! DirectMessageModalViewController
                
                //Get user name
                let userNameFromChat = messageArray[indexPath.row].profileName
                let userIDFromChat = messageArray[indexPath.row].sender

                //Send things to the destVC
                destVC.friendUserName = userNameFromChat
                destVC.friendUserID = userIDFromChat
                destVC.chatroomSentFrom = (chatRoomName! + " - " + chatRoomAddress!)
                destVC.specificMessage = messageArray[indexPath.row].messageKey
                
            }
            
        }else if segue.identifier == "chatroomToInfoModal"{
            let destVC = segue.destination as! InfoModalViewController
            destVC.receivedInfo = "Say something in the chat \n\nOr click on a person to send them a direct message"
        }
        
    }
}

