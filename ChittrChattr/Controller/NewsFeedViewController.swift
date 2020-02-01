//
//  NewsFeedViewController.swift
//  ChittrChattr
//
//  Created by Mycah on 4/20/18.
//  Copyright © 2018 Mycah. All rights reserved.
//

import UIKit
import Firebase
import GoogleMobileAds

class NewsFeedViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate  {

    //Variables
    let ref = Database.database().reference(fromURL: Private().DATABASE_URL_FIREBASE)
    var newsArray : [News] = [News]()
    var friendArray : [FriendInfo] = [FriendInfo]()
    var timePosted : String?
    var currentUserID : String?
    var filteredName : String?
    
    //Outlets
    @IBOutlet weak var newsTableView: UITableView!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var newsTextfield: UITextField!
    @IBOutlet weak var backButtonDisplay: UIButton!
    @IBOutlet weak var infoButtonDisplay: UIButton!
    @IBOutlet weak var bannerDisplay: GADBannerView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        //Set up the ad banner
        //TODO: change this to a DEPLOYMENT adUnitID
        //TEST
        //bannerDisplay.adUnitID = "ca-app-pub-3940256099942544/2934735716"
        //Legit
        bannerDisplay.adUnitID = Private().ADMOB_BANNER_ID
        
        bannerDisplay.rootViewController = self
        bannerDisplay.load(GADRequest())
        
        //Set Delegate for TableView
        newsTableView.delegate = self
        newsTableView.dataSource = self
        
        //Set Delegate for Text Input
        newsTextfield.delegate = self
        
        //set image size aspect
        backButtonDisplay.imageView?.contentMode = UIViewContentMode.scaleAspectFit
        backButtonDisplay.imageEdgeInsets = UIEdgeInsetsMake(10, 10, 10, 10)
        //set image size aspect
        infoButtonDisplay.imageView?.contentMode = UIViewContentMode.scaleAspectFit
        infoButtonDisplay.imageEdgeInsets = UIEdgeInsetsMake(5, 5, 5, 5)
        
        //Register the CustomMessageCell xib file
        newsTableView.register(UINib(nibName: "CustomNewsFeedCell", bundle: nil), forCellReuseIdentifier: "customNewsFeedCell")
        
        //Remove seperation lines
        newsTableView.separatorStyle = .none
        
        //Change Return to Send on the keyboard
        newsTextfield.returnKeyType = UIReturnKeyType.send
        
        //Get the  profile Name and Filter it for the database
        let profileName = Auth.auth().currentUser?.displayName
        filteredName = profileName!.replacingOccurrences(of: ".", with: ",", options: NSString.CompareOptions.literal, range: nil)
        
        //Get the current User's userID
        currentUserID = Auth.auth().currentUser?.uid
        
        
        //TEST Fetch friends
        fetchFriends()
  
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        //set up keyboard observers
        setupKeyboardObservers()
        
        //Hide keyboard when tapped away
        hideKeyboardWhenTappedAround()
        
        //Setup Input componenets
        setupInputComponents()
        
    }
    
    //***********************
    //MARK: Table Information
    //***********************
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "customNewsFeedCell", for: indexPath) as! CustomNewsFeedCell

        //dont highlight
        cell.selectionStyle = .none
        
        //Set the cell outlets to the information in the newsArray objects
        cell.newsTimeDisplay.text = newsArray[indexPath.row].newsMessageTime
        cell.newsUserNameDisplay.text = newsArray[indexPath.row].profileName
        cell.newsPostDisplay.text = newsArray[indexPath.row].newsBody
        
        //Retrieve Image from URL
        ref.child("Users").child(newsArray[indexPath.row].userID).child("PublicRead").observeSingleEvent(of: .value) { (snapshot) in
            //Check for snapshot
            if !snapshot.exists() {
                return
            }
            //look for the profile image
            let profileInfo = snapshot.value as! NSDictionary
            if let profileImageUrl = profileInfo["ProfileImage"]{

                //call this from the extension
                cell.newsImageDisplay.loadImageUsingCacheWithUrlString(urlString: profileImageUrl as! String)

            }else{
                //For troubleshooting
                print("User has no ProfileImage")
                let image : UIImage = UIImage(named: "ProfileIcon")!
                cell.newsImageDisplay.image = image
                print("User has no ProfileImage")
            }
        }
        
        //This will load the Messages from the bottom
        newsTableView.transform = CGAffineTransform(rotationAngle: -CGFloat.pi)
        cell.transform = CGAffineTransform(rotationAngle: CGFloat.pi)
 
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return newsArray.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        //Only remove if the the user is the current user
        if currentUserID == newsArray[indexPath.row].userID{
            
            //Alert user - do they want to go to the chat or delete the post
            let alertController = UIAlertController(title: nil, message:"Would you like to Enter your Chatroom, or Delete your Post?", preferredStyle: UIAlertControllerStyle.alert)
            
            alertController.addAction(UIAlertAction(title: "Enter", style: UIAlertActionStyle.default){ action -> Void in
                self.performSegue(withIdentifier: "newsToChat", sender: self)
            })
            
            alertController.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.default,handler: nil))
            
            alertController.addAction(UIAlertAction(title: "Delete", style: UIAlertActionStyle.default){ action -> Void in
                //Alert are you sure you want to delete the chatroom
                
                let alertController = UIAlertController(title: nil, message:"Are you sure you want to Delete this post?", preferredStyle: UIAlertControllerStyle.alert)
                
                alertController.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.default,handler: nil))
                
                alertController.addAction(UIAlertAction(title: "Delete", style: UIAlertActionStyle.default){ action -> Void in
                   
                    //Delete the Post
                    self.ref.child("AllNewsPosts").child(self.newsArray[indexPath.row].newsChatRoomId).child(self.currentUserID!).removeValue()
                    
                    self.ref.child("Users").child(self.currentUserID!).child("PublicWrite").child("NewsPost").child("Posts").child(self.newsArray[indexPath.row].newsChatRoomId).removeValue()
                    
                    //Delete the post chatroom
                    self.ref.child("Chatrooms").child("NewsFeedRooms").child("NewsRoomID - \(self.newsArray[indexPath.row].newsChatRoomId)").removeValue()
                    
                    
                    //delete post from all friends
                    for friend in self.friendArray{
                        self.ref.child("Users").child(friend.friendID).child("PublicWrite").child("NewsPost").child("Posts").child(self.newsArray[indexPath.row].newsChatRoomId).removeValue()
                        
                    }
                    
                    //Remove the users from the array based on the index
                    self.newsArray.remove(at: indexPath.row)
                    self.newsTableView.reloadData()
                })
                
                self.present(alertController, animated: true, completion: nil)
                
            })
            
            self.present(alertController, animated: true, completion: nil)
            
        }else{
            performSegue(withIdentifier: "newsToChat", sender: self)
        }
        
    }
    
//    *************************************************
//    MARK: Get Friends and sort Posts by date and time
//    *************************************************
    
    //Get a list of all of your friends
    func fetchFriends(){

        ref.child("Users").child(currentUserID!).child("PublicWrite").child("Friends").observeSingleEvent(of: .value) { (snapshot) in

            for child in snapshot.children {

                let friendInfo = FriendInfo()

                let snap = child as! DataSnapshot
                //let keyt = snap.key
                let valuet = snap.value as! Dictionary<String, Any?>

                //Set Friends info to send
                let userName = valuet["Name"]
                friendInfo.friendName = userName as! String

                let userEmail = valuet["UserID"]
                friendInfo.friendID = userEmail as! String
                
                let isBlocked = valuet["Blocked"]
                friendInfo.friendIsBlocked = isBlocked as! Bool
                
                //append the friend object to the array
                if !friendInfo.friendIsBlocked{
                    self.friendArray.append(friendInfo)
                }

            }

            self.retrieveNews()
        }
    }

    //************************
    //MARK: Send Message Stuff
    //************************
    
    func sendPostContent(){
        //Turn off Send functionality so that user can't send a message a billion times on accident
        newsTextfield.isEnabled = false
        
        //This will check to make sure there are no blank spaces so some fool cant just type spaces
        if (newsTextfield.text?.hasPrefix(" "))! || (newsTextfield.text?.hasSuffix("     "))! || newsTextfield.text == ""{
            print("Stop posting spaces")
            //Let the user know they are using to many spaces
            newsTextfield.placeholder = "No Spaces before or after text"
            
            //Re-enable sendButton and Textfield so the user can send more messages
            self.newsTextfield.isEnabled = true
            
            //Clear out the textfield
            self.newsTextfield.text = ""
            
        }else{
            print("Thanks for posting an actual post!")
            
            //Get Time
            timePosted = DateFormatter.localizedString(from: Date(), dateStyle: DateFormatter.Style.short, timeStyle: DateFormatter.Style.short)
            
            //Create a custom random key for the News post in allNews
            let childRef = ref.child("AllNewsPosts").childByAutoId()
            
            let newsIdName = childRef.key
            
            //Set up Dictionary
            let newsDictionary = ["UserID" : currentUserID, "NewsBody" : newsTextfield.text, "ProfileName" : filteredName, "Time" : timePosted, "NewsPostID" : newsIdName] as [String : Any]
            
            //Clear out the textfield
            self.newsTextfield.text = ""

            childRef.child(self.currentUserID!).updateChildValues(newsDictionary, withCompletionBlock: { (error, ref) in
                if error != nil{
                    print(error!)
                    return
                }
                
                let userNewsRef = Database.database().reference().child("Users").child(self.currentUserID!).child("PublicWrite").child("NewsPost").child("Posts")
                let newsId = childRef.key
                userNewsRef.updateChildValues([newsId : 1])
                
                //loop through all friends
                for friend in self.friendArray{
                    if(!friend.friendIsBlocked){
                        //Set the news
                        let recipientUserNewsRef = Database.database().reference().child("Users").child(friend.friendID).child("PublicWrite").child("NewsPost").child("Posts")
                        recipientUserNewsRef.updateChildValues([newsId: 2])
                        
                    }
                }
                
                self.newsTextfield.isEnabled = true
            })
        }
    }
    
    //Retrieve news
    func retrieveNews(){
        
        let ref2 = ref.child("Users").child(self.currentUserID!).child("PublicWrite").child("NewsPost").child("Posts")

        ref2.observe(.childAdded, with: { (snapshot) in
            let newsId = snapshot.key
            let newsReference = self.ref.child("AllNewsPosts").child(newsId)

            newsReference.observe(.value , with: { (snapshot) in
                
                if let userSnapshot = snapshot.children.allObjects as? [DataSnapshot]{
                    for snap in userSnapshot{
                        let snapshotValue = snap.value as! Dictionary<String, String>
                        
                        //Grabvalues from the news dictionary
                        let newsBody = snapshotValue["NewsBody"]!
                        let timeDisplay = snapshotValue["Time"]!
                        let userID = snapshotValue["UserID"]!
                        let profileName = snapshotValue["ProfileName"]!
                        let newsChatId = snapshotValue["NewsPostID"]!
                        
                        if userID == self.currentUserID{
                            //Create a Message Object
                            let news = News()
                            news.newsBody = newsBody
                            news.userID = userID
                            news.profileName = profileName
                            news.newsMessageTime = timeDisplay
                            news.newsChatRoomId = newsChatId
                            
                            //add message to the messageArray
                            self.newsArray.insert(news, at: 0)
                            
                            self.newsTableView.reloadData()
                        }else{
                            for friend in self.friendArray{
                                if friend.friendID == userID{
                                    
                                    //Create a Message Object
                                    let news = News()
                                    news.newsBody = newsBody
                                    news.userID = userID
                                    news.profileName = profileName
                                    news.newsMessageTime = timeDisplay
                                    news.newsChatRoomId = newsChatId
                                    
                                    //add message to the messageArray
                                    self.newsArray.insert(news, at: 0)
                                    
                                    self.newsTableView.reloadData()
                                }
                            }
                        }
                    }
                }
            }, withCancel: nil)

        }, withCancel: nil)
        
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
    var newsTableViewBottomAnchor : NSLayoutConstraint?
    
    //Set up Input components
    func setupInputComponents(){
        
        //Set up Message Table view
        newsTableView.translatesAutoresizingMaskIntoConstraints = false
        
        newsTableViewBottomAnchor = newsTableView.bottomAnchor.constraint(equalTo: containerView.topAnchor)
        newsTableViewBottomAnchor?.isActive = true
        
        newsTableView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        newsTableView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        
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
    
    //Send a message when pressing enter
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        sendPostContent()
        return true
    }
    
    @IBAction func backButton(_ sender: Any) {
        ref.child("Users").child(self.currentUserID!).child("PublicWrite").child("NewsPost").child("Posts").removeAllObservers()
        dismiss(animated: true, completion: nil)
    }
    
//    ***********
//    MARK: Segue
//    ***********
    
    //Prepare for Segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "newsToChat"{
            
            //Get the indexPath so we know what was clicked
            if let indexPath = newsTableView.indexPathForSelectedRow{
                
                //Get the destination view controller
                let destVC = segue.destination as! ChatRoomViewController
                
                let chatRoomId = newsArray[indexPath.row].newsChatRoomId
                
                //Send things to the destVC
                destVC.newsChatRoomId = chatRoomId
                destVC.chatRoomName = newsArray[indexPath.row].newsBody
            }
            
        }else if segue.identifier == "newsFeedToInfoModal"{
            let destVC = segue.destination as! InfoModalViewController
            destVC.receivedInfo = "Post something for people to talk about\n\nOr Click on a Post to talk to people about it."
        }
    }
}


