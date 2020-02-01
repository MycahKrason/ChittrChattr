//
//  CustomNewsFeedCell.swift
//  ChittrChattr
//
//  Created by Mycah on 4/21/18.
//  Copyright © 2018 Mycah. All rights reserved.
//

import UIKit

class CustomNewsFeedCell: UITableViewCell {

    //Outlets
    @IBOutlet weak var newsImageDisplay: UIImageView!
    @IBOutlet weak var newsUserNameDisplay: UILabel!
    @IBOutlet weak var newsPostDisplay: UILabel!
    @IBOutlet weak var newsTimeDisplay: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        //make image a circle
        newsImageDisplay.layer.cornerRadius = newsImageDisplay.frame.size.width / 2;
        newsImageDisplay.clipsToBounds = true;
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    
}
