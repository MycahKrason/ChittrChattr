//
//  DescriptionViewController.swift
//  ChittrChattr
//
//  Created by Mycah on 4/19/18.
//  Copyright © 2018 Mycah. All rights reserved.
//

import UIKit
import Firebase

class DescriptionViewController: UIViewController, UITextViewDelegate {

    //Variables
    let ref = Database.database().reference(fromURL: Private().DATABASE_URL_FIREBASE)
    var filteredEmail : String?
    var userID : String?
    
    //Outlets
    @IBOutlet weak var descriptionTextField: UITextView!
    @IBOutlet weak var backButtonDisplay: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //set delegate
        self.descriptionTextField.delegate = self
        
        //set image size aspect
        backButtonDisplay.imageView?.contentMode = UIViewContentMode.scaleAspectFit
        backButtonDisplay.imageEdgeInsets = UIEdgeInsetsMake(10, 10, 10, 10)
        
        //Change Return to Send on the keyboard
        descriptionTextField.returnKeyType = UIReturnKeyType.done
        
        self.descriptionTextField.becomeFirstResponder()
        
        //Get the Email and filter it for the database
        let profileEmail = Auth.auth().currentUser?.email
        filteredEmail = profileEmail!.replacingOccurrences(of: ".", with: ",", options: NSString.CompareOptions.literal, range: nil)
        
        //Get user ID
        userID = Auth.auth().currentUser?.uid
        
        hideKeyboardWhenTappedAround()
        
        //Grab existing text if any exists
        grabExistingText()
    }

    //This will grab any existing text if there is any
    func grabExistingText(){
        ref.child("Users").child(userID!).child("PublicRead").child("Description").observe(.value) { (snapshot) in
            if snapshot.exists(){
                self.descriptionTextField.text = snapshot.value as! String
            }else{
                self.descriptionTextField.text = ""
            }
        }
    }
    
    @IBAction func backButtonPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if(text == "\n") {
            
            if descriptionTextField.text.count < 145{
                ref.child("Users").child(userID!).child("PublicRead").updateChildValues(["Description" : descriptionTextField.text])
                
                dismiss(animated: true, completion: nil)
                
                textView.resignFirstResponder()
                return false
            }else{
                
                //show alert
                let alertController = UIAlertController(title: nil, message:"Description must be less than 145 characters", preferredStyle: UIAlertControllerStyle.alert)
                alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.default,handler: nil))
                self.present(alertController, animated: true, completion: nil)
                
                print("Too many characters")
                return false
            }
            
        }
        return true
    }
}
