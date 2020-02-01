//
//  CustomFriendListCell.swift
//  ChittrChattr
//
//  Created by Mycah on 4/19/18.
//  Copyright © 2018 Mycah. All rights reserved.
//

import UIKit

class CustomFriendListCell: UITableViewCell {

    @IBOutlet weak var friendNameLabel: UILabel!
    @IBOutlet weak var friendImageDisplay: UIImageView!
    @IBOutlet weak var friendNotificationDisplay: UIImageView!
    @IBOutlet weak var friendIsBlockedDisplay: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        friendNotificationDisplay.isHidden = true
        
        //make image a circle
        friendImageDisplay.layer.cornerRadius = friendImageDisplay.frame.size.width / 2;
        friendImageDisplay.clipsToBounds = true;
        
        //make image a circle
        friendNotificationDisplay.layer.cornerRadius = friendNotificationDisplay.frame.size.width / 2;
        friendNotificationDisplay.clipsToBounds = true;
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    
}
