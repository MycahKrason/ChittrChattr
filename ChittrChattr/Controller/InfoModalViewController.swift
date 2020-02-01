//
//  InfoModalViewController.swift
//  ChittrChattr
//
//  Created by Mycah on 4/30/18.
//  Copyright © 2018 Mycah. All rights reserved.
//

import UIKit

class InfoModalViewController: UIViewController {
    
    //received information
    var receivedInfo : String?
    
    //Outlets
    @IBOutlet weak var infoDisplay: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if receivedInfo != nil{
            infoDisplay.text = receivedInfo
        }
        // Do any additional setup after loading the view.
    }

    @IBAction func closeButton(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
}
