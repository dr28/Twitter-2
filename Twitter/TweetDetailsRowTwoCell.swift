//
//  TweetDetailsRowTwoCell.swift
//  Twitter
//
//  Created by Deepthy on 9/29/17.
//  Copyright © 2017 Deepthy. All rights reserved.
//

import UIKit

class TweetDetailsRowTwoCell: UITableViewCell {
    
    @IBOutlet weak var tweetCount: UILabel!
    @IBOutlet weak var tweetLabel: UILabel!
    @IBOutlet weak var favoriteCount: UILabel!
    @IBOutlet weak var favoriteLabel: UILabel!

    var tweet: Tweet! {
        didSet {
            
             if let rtCount = tweet.retweetCount {
                tweetCount.text = "\(rtCount)"
                if rtCount <= 1 {
                    tweetLabel.text = "Retweet"
                } else {
                    tweetLabel.text = "Retweets"
                }
             }
             
             if let favCount = tweet.favoriteCount {
                favoriteCount.text = "\(favCount)"
                if favCount <= 1 {
                    favoriteLabel.text = "Favorite"
                } else {
                    favoriteLabel.text = "Favorites"
                }
             }
             
             for label in [tweetLabel, favoriteCount] {
                label?.textColor = UIColor.black
             }
            
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
