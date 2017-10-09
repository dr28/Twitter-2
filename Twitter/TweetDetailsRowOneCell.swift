//
//  TweetCellDetails.swift
//  Twitter
//
//  Created by Deepthy on 9/29/17.
//  Copyright © 2017 Deepthy. All rights reserved.
//

import UIKit
import TTTAttributedLabel

class TweetDetailsRowOneCell: UITableViewCell {
    
    @IBOutlet weak var profileImageView: UIImageView?
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var screenLabel: UILabel!
    @IBOutlet weak var tweetTextLabel: TTTAttributedLabel!//UILabel!
    @IBOutlet weak var timestampLabel: UILabel?

    var tweet: Tweet! {
        didSet {
            
            if let user = tweet.tweetCreater {
                
                profileImageView?.layer.cornerRadius = 3.0
                profileImageView?.layer.masksToBounds = true
                
                profileImageView?.layer.cornerRadius = (profileImageView?.frame.size.width)!/2
                profileImageView?.clipsToBounds = true
                if let normalImageUrl = user.profileImageUrl {
                    
                    let largeImageUrl = normalImageUrl.replacingOccurrences(of: "normal", with: "200x200")
                    
                    if let url = URL(string: largeImageUrl) {
                        
                        profileImageView?.setImageWith(url)
                    }
                }
                
                if let name = user.name {
                    nameLabel?.text = name
                }
                
                if let screenname = user.screenname {
                    screenLabel?.text = "@\(screenname)"
                }
            
            }

            if let date = tweet.createdAt {
                timestampLabel?.text = Constants.getTimeStampLabel(date: date)
            }

            if let text = tweet.text {
                tweetTextLabel?.text = text
                self.tweetTextLabel?.linkAttributes = [NSForegroundColorAttributeName: UIColor(red: 29/255, green: 161/255, blue: 242/255, alpha: 1.0)]
            }
        }
    }


    override func awakeFromNib() {
        super.awakeFromNib()
        self.tweetTextLabel?.enabledTextCheckingTypes =  NSTextCheckingAllTypes
}

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
