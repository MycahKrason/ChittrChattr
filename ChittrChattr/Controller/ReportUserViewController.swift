//
//  ReportUserViewController.swift
//  ChittrChattr
//
//  Created by Mycah on 12/1/18.
//  Copyright © 2018 Mycah. All rights reserved.
//

import UIKit
import MessageUI
import Firebase

class ReportUserViewController: UIViewController, UITextViewDelegate, MFMailComposeViewControllerDelegate {

    //Variables sent from DirectMessageViewController
    var chatroomReportedFrom : String?
    var friendName : String?
    var friendUID : String?
    
    var userID : String?
    
    @IBOutlet weak var reportPageTitle: UILabel!
    @IBOutlet weak var backButtonDisplay: UIButton!
    @IBOutlet weak var reportTextField: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        reportPageTitle.text = "Report \(friendName!)"
        
        //set delegate
        self.reportTextField.delegate = self
        
        //Change Return to Send on the keyboard
        reportTextField.returnKeyType = UIReturnKeyType.done
        
        hideKeyboardWhenTappedAround()
        
        //set image size aspect
        backButtonDisplay.imageView?.contentMode = UIViewContentMode.scaleAspectFit
        backButtonDisplay.imageEdgeInsets = UIEdgeInsetsMake(10, 10, 10, 10);
        
        userID = Auth.auth().currentUser?.uid
        
        //Info to add to the email
        print("\n\n")
        print(chatroomReportedFrom!)
        print(friendUID!)
        print(friendName!)
        print("\n\n")
        
    }
    
    @IBAction func backBtn(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func reportAbuseButton(_ sender: Any) {
        
        //Alert asking if they are sure they want to Report the user - if they say no, the window is closed and dismissed - if they say yes - their Email is opened
        
        //check to make sure the input field has been filled in
        if (reportTextField.text?.hasPrefix(" "))! || (reportTextField.text?.hasSuffix("     "))! || reportTextField.text == ""{
         
            //show alert
            let alertController = UIAlertController(title: nil, message:"Input field must not be blank, and there must not be uneccessary spaces at the end or beginning of your input.", preferredStyle: UIAlertControllerStyle.alert)
            alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.default,handler: nil))
            self.present(alertController, animated: true, completion: nil)
            
        }else{
            //show alert
            let alertController = UIAlertController(title: nil, message:"Are you sure you want to report this user?", preferredStyle: UIAlertControllerStyle.alert)
            
            alertController.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.default,handler: nil))
            alertController.addAction(UIAlertAction(title: "Yes", style: UIAlertActionStyle.default){ action -> Void in
                
                //TODO: Open the user's mail client
                print("Opening mail to send Abuse Report")
                
                let mailComposeViewController = self.configureMailController()
                
                if MFMailComposeViewController.canSendMail(){
                    self.present(mailComposeViewController, animated: true, completion: nil)
                    
                }else{
                    self.showMailError()
                }
            
            })
            
            self.present(alertController, animated: true, completion: nil)
            
        }
        
    }
    
    //MARK: Mail
    
    func configureMailController() -> MFMailComposeViewController{
        
        let mailComposerVC = MFMailComposeViewController()
        mailComposerVC.mailComposeDelegate = self
        
        //Who to send the Abuse to
        mailComposerVC.setToRecipients(["Support@Hipstatronic.com"])
        //Set the subject
        mailComposerVC.setSubject("ChittrChattr Abuse - \(userID!)")
        //Set Message Body
        mailComposerVC.setMessageBody("Abuse Claim from User - \(userID!)\n\nAbusing User ID:\n\(friendUID!)\n\nAbusing User Name:\n\(friendName!)\n\nAbuse Location:\n\(chatroomReportedFrom!)\n\nReported Abuse Description:\n\(reportTextField.text!)", isHTML: false)
        
        return mailComposerVC
        
    }
    
    func showMailError(){
        let sendMailErrorAlert = UIAlertController(title: nil, message: "Your device could not send email - Please send a detailed report of your abuse claim to\nSupport@Hipstatronic.com", preferredStyle: UIAlertControllerStyle.alert)
        sendMailErrorAlert.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.default,handler: nil))
        self.present(sendMailErrorAlert, animated: true, completion: nil)
    }
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true, completion: nil)
        
        self.dismiss(animated: true, completion: nil)
    }
    
    //MARK: KeyBoard
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if(text == "\n") {
            
            //Make sure there is some text
            if (reportTextField.text?.hasPrefix(" "))! || (reportTextField.text?.hasSuffix("     "))! || reportTextField.text == ""{
                
                //show alert
                let alertController = UIAlertController(title: nil, message:"Input field must not be blank, and there must not be uneccessary spaces at the end or beginning of your input.", preferredStyle: UIAlertControllerStyle.alert)
                alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.default,handler: nil))
                self.present(alertController, animated: true, completion: nil)
                
                print("Too many characters")
                return false
                
            }else{
                
                textView.resignFirstResponder()
                return false
            }
            
        }
        return true
    }
    
}
