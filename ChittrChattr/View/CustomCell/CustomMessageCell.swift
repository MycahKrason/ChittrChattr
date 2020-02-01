//
//  CustomMessageCell.swift
//  ChittrChattr
//
//  Created by Mycah on 4/7/18.
//  Copyright © 2018 Mycah. All rights reserved.
//

import UIKit

class CustomMessageCell: UITableViewCell {
    
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var messageBackground: UIView!
    @IBOutlet weak var senderUsername: UILabel!
    @IBOutlet weak var messageBody: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    
    var senderEmail : String?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        //make image a circle
        profileImage.layer.cornerRadius = profileImage.frame.size.width / 2;
        profileImage.clipsToBounds = true;
        
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    

}
