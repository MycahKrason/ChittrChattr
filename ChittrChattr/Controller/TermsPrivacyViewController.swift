//
//  TermsPrivacyViewController.swift
//  ChittrChattr
//
//  Created by Mycah on 6/24/18.
//  Copyright © 2018 Mycah. All rights reserved.
//

import UIKit
import Firebase

class TermsPrivacyViewController: UIViewController {

    //Outlets
    @IBOutlet weak var acceptBtnDisplay: UIButton!
    @IBOutlet weak var termsAndPivacyDisplay: UITextView!
    
    let ref = Database.database().reference()
    var filteredEmail : String?
    var userID : String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        termsAndPivacyDisplay.isScrollEnabled = false
        
        termsAndPivacyDisplay.text = "Terms & Conditions:\n\nBy downloading or using the app, these terms will automatically apply to you – you should make sure therefore that you read them carefully before using the app. You’re not allowed to copy, or modify the app, any part of the app, or our trademarks in any way. You’re not allowed to attempt to extract the source code of the app, and you also shouldn’t try to translate the app into other languages, or make derivative versions. The app itself, and all the trade marks, copyright, database rights and other intellectual property rights related to it, still belong to Hipstatronic LLC.\n\nHipstatronic LLC is committed to ensuring that the app is as useful and efficient as possible. For that reason, we reserve the right to make changes to the app or to charge for its services, at any time and for any reason. We will never charge you for the app or its services without making it very clear to you exactly what you’re paying for.\n\nThe Chittr Chattr app stores and processes personal data that you have provided to us, in order to provide our Service. It’s your responsibility to keep your phone and access to the app secure. We therefore recommend that you do not jailbreak or root your phone, which is the process of removing software restrictions and limitations imposed by the official operating system of your device. It could make your phone vulnerable to malware/viruses/malicious programs, compromise your phone’s security features and it could mean that the Chittr Chattr app won’t work properly or at all.\n\nYou should be aware that there are certain things that Hipstatronic LLC will not take responsibility for. Certain functions of the app will require the app to have an active internet connection. The connection can be Wi-Fi, or provided by your mobile network provider, but Hipstatronic LLC cannot take responsibility for the app not working at full functionality if you don’t have access to Wi-Fi, and you don’t have any of your data allowance left.\n\nIf you’re using the app outside of an area with Wi-Fi, you should remember that your terms of the agreement with your mobile network provider will still apply. As a result, you may be charged by your mobile provider for the cost of data for the duration of the connection while accessing the app, or other third party charges. In using the app, you’re accepting responsibility for any such charges, including roaming data charges if you use the app outside of your home territory (i.e. region or country) without turning off data roaming. If you are not the bill payer for the device on which you’re using the app, please be aware that we assume that you have received permission from the bill payer for using the app.\n\nAlong the same lines, Hipstatronic LLC cannot always take responsibility for the way you use the app i.e. You need to make sure that your device stays charged – if it runs out of battery and you can’t turn it on to avail the Service, Hipstatronic LLC cannot accept responsibility\n\nWith respect to Hipstatronic LLC’s responsibility for your use of the app, when you’re using the app, it’s important to bear in mind that although we endeavour to ensure that it is updated and correct at all times, we do rely on third parties to provide information to us so that we can make it available to you. Hipstatronic LLC accepts no liability for any loss, direct or indirect, you experience as a result of relying wholly on this functionality of the app.\n\nWho Can Use Chittr Chattr.\nWe want our Service to be as open and inclusive as possible, but we also want it to be safe, secure, and in accordance with the law. So, we need you to commit to a few restrictions in order to be part of the Chittr Chattr community.\n - You must be at least 13 years old.\n - You must not be prohibited from receiving any aspect of our Service under applicable laws or engaging in payments related Services if you are on an applicable denied party listing.\n - We must not have previously disabled your account for violation of law or any of our policies.\n - You must not be a convicted sex offender.\n - You must not use Chittr Chattr to break the law in anyway.\n\nHow You Can't Use Chittr Chattr.\nProviding a safe and open Service for a broad community requires that we all do our part.\n - You can't impersonate others or provide inaccurate information.\n\nYou don't have to disclose your identity on Chittr Chattr. However, you may not impersonate someone you aren't, and you can't create an account for someone else unless you have their express permission.\n - You can't do anything unlawful, misleading, or fraudulent or for an illegal or unauthorized purpose.\n - You can't violate (or help or encourage others to violate) these Terms or our policies.\n - You can't do anything to interfere with or impair the intended operation of the Service.\n - You can't attempt to create accounts or access or collect information in unauthorized ways.\n\nThis includes creating accounts or collecting information in an automated way without our express permission.\n - You can't attempt to buy, sell, or transfer any aspect of your account (including your username) or solicit, collect, or use login credentials or badges of other users.\n - You can't post private or confidential information or do anything that violates someone else's rights, including intellectual property.\n\nReport Abuse, Block Users, and Delete Posts/Messages\n\nReport Abuse\nTo maintain a Safe Environment, users may easily report abusive/illegal/inappropriate conduct/images to Support@Hipstatronic.com by performing the following steps:\nClick on a Message from the user performing the abusive conduct.\nClick the red Report button in the top left of the Profile Pop-up.\nFill in the requested information and press the Report Abuse button at the bottom of the screen.\nThis will open up an email containing the appropriate and necessary information.\nSend the Email.\n\nBlock User\nIf a user is bothering you, but they are not conducting any abusive/illegal/inappropriate behaviors, you may easily block the user by performing the following steps:\nGo to your list of friends and open the direct chat between yourself and the person you would like to block\nClick on one of their messages\nClick the button that says Block User (You may unBlock a user by following these same steps)\n\nDelete Chatroom Message\nIf you have posted something in a Public Chat and would like to delete what you have said, click on your message and select the button that says DELETE YOUR MESSAGE.\n\nDelete News Post\nIf you would like to delete a News Post, click on your News Post and select the button that says Delete.\n\nAt some point, we may wish to update the app. The app is currently available on Android and iOS – the requirements for both systems (and for any additional systems we decide to extend the availability of the app to) may change, and you’ll need to download the updates if you want to keep using the app. Hipstatronic LLC does not promise that it will always update the app so that it is relevant to you and/or works with the iOS/Android version that you have installed on your device. However, you promise to always accept updates to the application when offered to you, We may also wish to stop providing the app, and may terminate use of it at any time without giving notice of termination to you. Unless we tell you otherwise, upon any termination, (a) the rights and licenses granted to you in these terms will end; (b) you must stop using the app, and (if needed) delete it from your device.\n\nChanges to This Terms and Conditions\n\nWe may update our Terms and Conditions from time to time. Thus, you are advised to review this page periodically for any changes. We will notify you of any changes by posting the new Terms and Conditions on this page. These changes are effective immediately after they are posted on this page.\n\n\nPrivacy Policy:\n\nHipstatronic LLC built the Chittr Chattr app as an Ad Supported app. This SERVICE is provided by Hipstatronic LLC at no cost and is intended for use as is.\n\nThis page is used to inform website visitors regarding our policies with the collection, use, and disclosure of Personal Information if anyone decided to use our Service.\n\nIf you choose to use our Service, then you agree to the collection and use of information in relation to this policy. The Personal Information that we collect is used for providing and improving the Service. We will not use or share your information with anyone except as described in this Privacy Policy.\n\nThe terms used in this Privacy Policy have the same meanings as in our Terms and Conditions, which is accessible at Chittr Chattr unless otherwise defined in this Privacy Policy.\n\nInformation Collection and Use\n\nFor a better experience, while using our Service, we may require you to provide us with certain personally identifiable information, including but not limited to Email, Name. The information that we request is will be retained by us and used as described in this privacy policy.\n\nThe app does use third party services that may collect information used to identify you.\n\nService providers used by the app\n - Google Play Services\n - AdMob\n - Firebase Analytics\n\nLog Data\n\nWe want to inform you that whenever you use our Service, in a case of an error in the app we collect data and information (through third party products) on your phone called Log Data. This Log Data may include information such as your device Internet Protocol (“IP”) address, device name, operating system version, the configuration of the app when utilizing our Service, the time and date of your use of the Service, and other statistics.\n\nCookies\n\nCookies are files with a small amount of data that are commonly used as anonymous unique identifiers. These are sent to your browser from the websites that you visit and are stored on your device's internal memory.\n\nThis Service does not use these “cookies” explicitly. However, the app may use third party code and libraries that use “cookies” to collect information and improve their services. You have the option to either accept or refuse these cookies and know when a cookie is being sent to your device. If you choose to refuse our cookies, you may not be able to use some portions of this Service.\n\nService Providers\n\nWe may employ third-party companies and individuals due to the following reasons:\n - To facilitate our Service;\n - To provide the Service on our behalf;\n - To perform Service-related services; or\n - To assist us in analyzing how our Service is used.\n\nWe want to inform users of this Service that these third parties have access to your Personal Information. The reason is to perform the tasks assigned to them on our behalf. However, they are obligated not to disclose or use the information for any other purpose.\n\nSecurity\n\nWe value your trust in providing us your Personal Information, thus we are striving to use commercially acceptable means of protecting it. But remember that no method of transmission over the internet, or method of electronic storage is 100% secure and reliable, and we cannot guarantee its absolute security.\n\nLinks to Other Sites\n\nThis Service may contain links to other sites. If you click on a third-party link, you will be directed to that site. Note that these external sites are not operated by us. Therefore, we strongly advise you to review the Privacy Policy of these websites. We have no control over and assume no responsibility for the content, privacy policies, or practices of any third-party sites or services.\n\nChildren’s Privacy\n\nThese Services do not address anyone under the age of 13. We do not knowingly collect personally identifiable information from children under 13. In the case we discover that a child under 13 has provided us with personal information, we immediately delete this from our servers. If you are a parent or guardian and you are aware that your child has provided us with personal information, please contact us so that we will be able to do necessary actions.\n\nChanges to This Privacy Policy\n\nWe may update our Privacy Policy from time to time. Thus, you are advised to review this page periodically for any changes. We will notify you of any changes by posting the new Privacy Policy on this page. These changes are effective immediately after they are posted on this page.\n\nContact Us\n\nIf you have any questions or suggestions about our Privacy Policy, do not hesitate to contact us at:\nwww.Hipstatronic.com"
        
        //Get the Email and filter it for the database
        let profileEmail = Auth.auth().currentUser?.email
        filteredEmail = profileEmail!.replacingOccurrences(of: ".", with: ",", options: NSString.CompareOptions.literal, range: nil)
        
        //Get user ID
        userID = Auth.auth().currentUser?.uid
        
        //Check if terms have been accepted
        ref.child("Users").child(userID!).child("Private").observeSingleEvent(of: .value) { (snapshot) in
            //Check for snapshot
            if !snapshot.exists() {
                return
            }
            //look for the profile image
            let profileInfo = snapshot.value as! NSDictionary
            
            //TODO: Check that terms have been accepted
            if let termsAccepted = profileInfo["AcceptedTermsPrivacy"] as? Bool{
                
                if termsAccepted == true{
                    //TODO: Change the button color and the text to say "Back"
                    self.acceptBtnDisplay.backgroundColor = UIColor(red: 112/255, green: 211/255, blue: 36/255, alpha: 1.0)
                    self.acceptBtnDisplay.titleLabel?.text = "Back"
                }else{
                    self.acceptBtnDisplay.backgroundColor = UIColor(red: 255/255, green: 0/255, blue: 0/255, alpha: 1.0)
                    self.acceptBtnDisplay.titleLabel?.text = "I have read and I Accept"
                }
            }
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        termsAndPivacyDisplay.isScrollEnabled = true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func acceptBtnPressed(_ sender: Any) {
        //TODO: update database that the terms have been accepted
        
        ref.child("Users").child(userID!).child("Private").updateChildValues(["AcceptedTermsPrivacy" : true])
        dismiss(animated: true, completion: nil)
    }
  

}
