//
//  TweetDetailsRowThreeCell.swift
//  Twitter
//
//  Created by Deepthy on 9/30/17.
//  Copyright © 2017 Deepthy. All rights reserved.
//

import UIKit

@objc protocol TweetDetailsRowThreeCellDelegate {
    
    @objc optional func tweetDetailsRowThreeCell(tweetDetailsRowThreeCell: TweetDetailsRowThreeCell, didReply tweet: Tweet)
    @objc optional func tweetDetailsRowThreeCell(tweetDetailsRowThreeCell: TweetDetailsRowThreeCell, didRetweetChange tweet: Tweet)
    @objc optional func tweetDetailsRowThreeCell(tweetDetailsRowThreeCell: TweetDetailsRowThreeCell, didFavoriteChange tweet: Tweet)
    
}


class TweetDetailsRowThreeCell: UITableViewCell {
    
    @IBOutlet weak var replyImageView: UIImageView?
    
    @IBOutlet weak var retweetImageView: UIImageView?
    
    @IBOutlet weak var likeImageView: UIImageView?
    
    weak var delegate: TweetDetailsRowThreeCellDelegate?
    
    var isLiked: Bool = false

    var tweet: Tweet!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        let replyButtonTap = UITapGestureRecognizer(target: self, action: #selector(replyButtonTapped))
        replyButtonTap.numberOfTapsRequired = 1
        replyImageView?.isUserInteractionEnabled = true
        replyImageView?.addGestureRecognizer(replyButtonTap)


        let reTweetButtonTap = UITapGestureRecognizer(target: self, action: #selector(reTweetButtonTapped))
        reTweetButtonTap.numberOfTapsRequired = 1
        retweetImageView?.isUserInteractionEnabled = true
        retweetImageView?.addGestureRecognizer(reTweetButtonTap)
        
        
        let likeButtonTap = UITapGestureRecognizer(target: self, action: #selector(likeButtonTapped))
        likeButtonTap.numberOfTapsRequired = 1
        likeImageView?.isUserInteractionEnabled = true
        likeImageView?.addGestureRecognizer(likeButtonTap)
    
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        isLiked = tweet.favorited ?? false
        
        if (!isLiked) {
            setLikeImage(selected: false)
        } else {
            setLikeImage(selected: true)
        }
        
        if (!tweet.retweetedByUser!) {
            setRetweetImage(selected: false)
        } else {
            setRetweetImage(selected: true)
        }
        
    }
    
    func replyButtonTapped() {
        delegate?.tweetDetailsRowThreeCell!(tweetDetailsRowThreeCell: self, didReply: self.tweet)
        
    }
    func reTweetButtonTapped() {
        self.delegate?.tweetDetailsRowThreeCell!(tweetDetailsRowThreeCell: self, didRetweetChange: self.tweet)
    }
    
    func setRetweetImage(selected: Bool) {
        if (selected) {
            retweetImageView?.image = UIImage(named: "retweet")
        } else {
            retweetImageView?.image = UIImage(named: "undoretweet")
        }
    }
    
    func likeButtonTapped() {
        self.delegate?.tweetDetailsRowThreeCell?(tweetDetailsRowThreeCell: self, didFavoriteChange: self.tweet)
        
    }
    
    
    func setLikeImage(selected: Bool) {
        if (selected) {            
            likeImageView?.image = UIImage(named: "like")
        } else {
            likeImageView?.image = UIImage(named: "dislike")
        }
    }


}
