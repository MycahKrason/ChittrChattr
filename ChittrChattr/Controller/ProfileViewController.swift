//
//  ProfileViewController.swift
//  ChittrChattr
//
//  Created by Mycah on 4/7/18.
//  Copyright © 2018 Mycah. All rights reserved.
//

// Version 9.2 (9C40b)

import UIKit
import Firebase

class ProfileViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate{

    //Variables
    var usersStorage = Storage.storage().reference(forURL: Private().STORAGE_URL_FIREBASE)
    let ref = Database.database().reference()
    
    var profileEmail : String?
    var filteredName : String?
    var userID : String?
    
    //Outlets
    @IBOutlet weak var profileNameLabel: UILabel!
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var profileImageButton: UIButton!
    @IBOutlet weak var profileDescriptionDisplay: UILabel!
    //Navigation button outlets
    @IBOutlet weak var friendsListButtonDisplay: UIButton!
    @IBOutlet weak var newsFeedButtonDisplay: UIButton!
    @IBOutlet weak var locationButtonDisplay: UIButton!
    @IBOutlet weak var infoButtonDisplay: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if (Auth.auth().currentUser?.displayName) == nil{
            
            print("Not Logged in")
            let newViewController = LoginViewController()
            self.present(newViewController, animated: true, completion: nil)
            
        }
        //Dismiss the keyboard
        hideKeyboardWhenTappedAround()
        
        //Make profile picture round
        profileImage.layer.cornerRadius = profileImage.frame.size.width / 2
        profileImage.clipsToBounds = true
        
        //set image size aspect
        infoButtonDisplay.imageView?.contentMode = UIViewContentMode.scaleAspectFit
        infoButtonDisplay.imageEdgeInsets = UIEdgeInsetsMake(5, 5, 5, 5)

        //set image size aspect
        newsFeedButtonDisplay.imageView?.contentMode = UIViewContentMode.scaleAspectFit
        newsFeedButtonDisplay.imageEdgeInsets = UIEdgeInsetsMake(5, 5, 5, 5)
        friendsListButtonDisplay.imageView?.contentMode = UIViewContentMode.scaleAspectFit
        friendsListButtonDisplay.imageEdgeInsets = UIEdgeInsetsMake(5, 5, 5, 5)
        locationButtonDisplay.imageView?.contentMode = UIViewContentMode.scaleAspectFit
        locationButtonDisplay.imageEdgeInsets = UIEdgeInsetsMake(5, 5, 5, 5)
        
        //Get the  profile Name and Filter it for the database
        let profileName = Auth.auth().currentUser?.displayName
        filteredName = profileName!.replacingOccurrences(of: ".", with: ",", options: NSString.CompareOptions.literal, range: nil)
        
        //Get the Email and filter it for the database
        profileEmail = Auth.auth().currentUser?.email
        
        //Get the user ID
        userID = Auth.auth().currentUser?.uid
        
        //Display the users Display Name from gmail or facebook
        profileNameLabel.text = profileName
        
        //Register the user
        if userID != nil{
            ref.child("Users").child(userID!).child("Private").updateChildValues(["Email" : profileEmail!])
            ref.child("Users").child(userID!).child("PublicRead").updateChildValues(["Name" : profileName!])
        }
        
    }
    
    //Beause the description is updated in real time, we need to check when the page appears
    override func viewWillAppear(_ animated: Bool) {
        //check for Terms
        ref.child("Users").child(userID!).child("Private").observeSingleEvent(of: .value) { (snapshot) in
            
            //Check for snapshot
            if !snapshot.exists() {
                return
            }
            //look for the profile image
            let profilePrivateInfo = snapshot.value as! NSDictionary
            
            //Check that terms have been accepted
            if let termsAccepted = profilePrivateInfo["AcceptedTermsPrivacy"] as? Bool{
                
                if termsAccepted == true{
                    //If terms are accepted, do nothing
                }else if termsAccepted == false{
                    print("TERMS ARE NOT ACCEPTED")
                    let viewController:UIViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "TermsPrivacyViewController") as UIViewController
                    
                    self.present(viewController, animated: false, completion: nil)
                }
                
            }else{
                print("TERMS ARE NOT ACCEPTED")
                //let newViewController = TermsPrivacyViewController()
                let viewController:UIViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "TermsPrivacyViewController") as UIViewController
                
                self.present(viewController, animated: false, completion: nil)
            }
            
        }
        
        //check for NewsNotifications
        ref.child("Users").child(userID!).child("PublicWrite").child("NewsPost").observeSingleEvent(of: .value) { (snapshot) in
            
            //Check for snapshot
            if !snapshot.exists() {
                return
            }
            //look for the profile image
            let profilePublicWriteInfo = snapshot.value as! NSDictionary
            
            //TODO: This will need to be separate as it belongs in PublicWrite
            //Check for NewsNotification
            if let newsNotification = profilePublicWriteInfo["NewsNotification"] as? Bool{
                if newsNotification{
                    //set notification
                    let image = UIImage(named: "NewsNotifyIcon")
                    self.newsFeedButtonDisplay.setImage(image, for: .normal)
                }else{
                    //set non notification
                    let image = UIImage(named: "NewsIcon")
                    self.newsFeedButtonDisplay.setImage(image, for: .normal)
                }
            }
            
        }
        
        //Check for image
        ref.child("Users").child(userID!).child("PublicRead").observeSingleEvent(of: .value) { (snapshot) in
            //Check for snapshot
            if !snapshot.exists() {
                return
            }
            //look for the profile image
            let profilePublicReadInfo = snapshot.value as! NSDictionary
            
            if let profileImageUrl = profilePublicReadInfo["ProfileImage"]{
                
                //Retrieve using cache
                self.profileImage.loadImageUsingCacheWithUrlString(urlString: profileImageUrl as! String)
                
            }else{
                //For troubleshooting
                print("User has no ProfileImage")
            }
            
            //Look for description
            if let profileDescription = profilePublicReadInfo["Description"]{
                self.profileDescriptionDisplay.text = profileDescription as? String
            }
           
        }
        
        //Loop through all friends and check for a true notification - if all is false, dont update notification
        checkFriends()
    }
    
    //Get a list of all of your friends
    func checkFriends(){

        ref.child("Users").child(userID!).child("PublicWrite").child("Friends").observeSingleEvent(of: .value) { (snapshot) in
            
            for child in snapshot.children {
                
                let snap = child as! DataSnapshot
                //let keyt = snap.key
                let valuet = snap.value as! Dictionary<String, Any?>
                
                if valuet["Notification"] as? Bool == true {
                    
                    if let isBlocked = valuet["Blocked"] as? Bool{
                        if isBlocked == true{
                            //no notification
                            let image = UIImage(named: "FriendsIcon")
                            self.friendsListButtonDisplay.setImage(image, for: .normal)
                        }else{
                            //recieved notification
                            let image = UIImage(named: "FriendsNotifyIcon")
                            self.friendsListButtonDisplay.setImage(image, for: .normal)
                            break
                        }
                    }else{
                        //recieved notification
                        let image = UIImage(named: "FriendsNotifyIcon")
                        self.friendsListButtonDisplay.setImage(image, for: .normal)
                        break
                    }
                    
                }else{
                    //no notification
                    let image = UIImage(named: "FriendsIcon")
                    self.friendsListButtonDisplay.setImage(image, for: .normal)
                }
                
            }
        }
    }
    
//    *****************
//    MARK: Image Stuff
//    *****************
    
    //This will set up the Image Picker functionality - be sure to add Privacy - Photo Library Usage Description
    @IBAction func profileImageButtonPressed(_ sender: Any) {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.allowsEditing = true
        imagePicker.sourceType = UIImagePickerControllerSourceType.photoLibrary
        self.present(imagePicker, animated: true, completion: nil)
    }
    
    //Do something with the image you choose
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        var selectedImageFromPicker : UIImage?
        
        //This is incase the user edits the image or not
        if let editedImage = info["UIImagePickerControllerEditedImage"] as? UIImage {
            selectedImageFromPicker = editedImage
        }else if let originalImage = info["UIImagePickerControllerEditedImage"] as? UIImage{
            selectedImageFromPicker = originalImage
        }
        
        //now that we know whether they have editted the photo or not
        if let selectedImage = selectedImageFromPicker{
            profileImage.image = selectedImage
            
            //Get a unique ID - insert this into the database name if you want to store EVERY photo a person uploads, otherwise the code as it is now will just rewrite the current image (saving us storage space)
            //let uniqueID = NSUUID().uuidString
            
            //Save the image to the DB
            let addPhoto = usersStorage.child(userID!)

            if let uploadData = UIImagePNGRepresentation(profileImage.image!){
                addPhoto.putData(uploadData, metadata: nil, completion: { (metadata, error) in
                    
                    if error != nil{
                        print(error!)
                        return
                    }
                    
                    //Convert the profile image URL to a string
                    if let profileImageURL = metadata?.downloadURL()?.absoluteString{
                        
                        //Store the URL info in the profile database
                        self.ref.child("Users").child(self.userID!).child("PublicRead").updateChildValues(["ProfileImage" : profileImageURL])
                    }
                    
                    print("Photo has been uploaded!")
                    
                })
            }
            
        }
        dismiss(animated: true, completion: nil)
    }
    
    //Cancel out the image picker
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    
//    ***********************************
//    MARK: Logout and Navigation Buttons
//    ***********************************

    @IBAction func logOutButton(_ sender: Any) {
        handleLogOut()
    }
    
    func handleLogOut() {

        //Sign user out
        do{
            try Auth.auth().signOut()
        } catch let logoutError{
            print(logoutError)
        }
        
        //Send user back to login screen
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func chatRoomButton(_ sender: Any) {
        performSegue(withIdentifier: "profileToLocations", sender: self)
    }
    
    @IBAction func newsFeedButton(_ sender: Any) {
        
        performSegue(withIdentifier: "profileToNews", sender: self)
    }
    
    @IBAction func friendsListButton(_ sender: Any) {
        //Clear the notification on the friends navigation button
        performSegue(withIdentifier: "profileToFriends", sender: self)
    }
    
}
