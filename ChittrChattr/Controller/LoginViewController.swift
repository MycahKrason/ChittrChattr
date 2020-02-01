//
//  LoginViewController.swift
//  ChittrChattr
//
//  Created by Mycah on 4/7/18.
//  Copyright © 2018 Mycah. All rights reserved.
//

import UIKit
import FBSDKLoginKit
import Firebase
import GoogleSignIn

class LoginViewController: UIViewController,FBSDKLoginButtonDelegate, GIDSignInUIDelegate {
    
    //Outlets
    @IBOutlet weak var GButtonLabel: UIButton!
    @IBOutlet weak var FBButtonLabel: UIButton!
    
    var filteredEmail : String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Facebook Login
        let loginManager = FBSDKLoginManager()
        loginManager.logOut()
          
//        enableShowButtons()
        
        let user = Auth.auth().currentUser?.uid
        if user != nil{
            performSegue(withIdentifier: "LoginSegue", sender: self)
        }
       
        //Round the Button corners
        GButtonLabel.layer.cornerRadius = 10
        GButtonLabel.clipsToBounds = true
        
        GButtonLabel.layer.borderWidth = 3
        GButtonLabel.layer.borderColor = UIColor.white.cgColor
        
        FBButtonLabel.layer.cornerRadius = 10
        FBButtonLabel.clipsToBounds = true
        FBButtonLabel.layer.borderWidth = 3
        FBButtonLabel.layer.borderColor = UIColor.white.cgColor
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        enableShowButtons()
    }
    
    //Disable Buttons
    func disableHideButtons(){
        GButtonLabel.isEnabled = false
        FBButtonLabel.isEnabled = false
    }
    
    func enableShowButtons(){
        GButtonLabel.isEnabled = true
        FBButtonLabel.isEnabled = true
    }
    
    //****************************
    //****** FACEBOOK LOGIN ******
    //****************************
    
    //Custom Facebook button
    @IBAction func FBLoginButton(_ sender: Any) {
        
        FBSDKLoginManager().logIn(withReadPermissions: ["email", "public_profile"], from: self) { (result, err) in
            if err != nil{
                print("FBCUSTOM Login failed", err!)
                return
            }else if (result!.isCancelled){
                // No need to do anything
            }else{
                self.showEmailAddress()
                //Disable Button after login - this will need to be re-enabled once there is a logout button
                self.disableHideButtons()
            }
        }
    }
    
    //Facbook Login Button - needed for Delegate
    func loginButton(_ loginButton: FBSDKLoginButton!, didCompleteWith result: FBSDKLoginManagerLoginResult!, error: Error!) {
                if error != nil{
                    print(error)
                    return
                }else{
                    //Test that you have logged in
                    print("SUCCESS! I AM LOGGED INTO FACEBOOK")
                    showEmailAddress()
                }
    }
    
    //Facebook LogOut Button
    func loginButtonDidLogOut(_ loginButton: FBSDKLoginButton!) {
        print("I AM LOGGED OUT OF FACEBOOK!")
    }
    
    //Get Facebook user's email address
    func showEmailAddress(){
        
        //Get User Authentication Logged into Firebase
        let credentials = FacebookAuthProvider.credential(withAccessToken: FBSDKAccessToken.current().tokenString)
        Auth.auth().signIn(with: credentials) { (user, err) in
            if err != nil{
                print("Something went wrong with our FB user: ", err!)
                return
            }else{
                print("Successfully logged in with Facebook", user!)
                
                
                self.performSegue(withIdentifier: "LoginSegue", sender: self)
            }
        }
    }
    
    //**************************
    //****** GOOGLE LOGIN ******
    //**************************
    
    @IBAction func GLoginButton(_ sender: Any) {
        
        GIDSignIn.sharedInstance().uiDelegate = self
        GIDSignIn.sharedInstance().signIn()
        
    }
    
    
    
}



