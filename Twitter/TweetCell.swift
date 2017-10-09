//
//  TweetCell.swift
//  Twitter
//
//  Created by Deepthy on 9/27/17.
//  Copyright © 2017 Deepthy. All rights reserved.
//

import UIKit
import TTTAttributedLabel

@objc protocol TweetCellDelegate {

    @objc optional func tweetCell(tweetCell: TweetCell, didTapProfileImage tweet: Tweet)
    @objc optional func tweetCell(tweetCell: TweetCell, didReply tweet: Tweet)
    @objc optional func tweetCell(tweetCell: TweetCell, didRetweetChange tweet: Tweet)
    @objc optional func tweetCell(tweetCell: TweetCell, didFavoriteChange tweet: Tweet)

}

class TweetCell: UITableViewCell {
    
    @IBOutlet weak var retweetView: UIView!
    
    @IBOutlet weak var retweetViewImage: UIImageView!
    
    @IBOutlet weak var retweetViewLabel: UILabel!
   
    @IBOutlet weak var profileImageView: UIImageView?
    
    @IBOutlet weak var nameLabel: UILabel?
    
    @IBOutlet weak var screenLabel: UILabel?
    
    @IBOutlet weak var timeAgoLabel: UILabel?
    
    @IBOutlet weak var tweetTextLabel: TTTAttributedLabel?//UILabel?
    
    @IBOutlet weak var replyImageView: UIImageView?

    
    @IBOutlet weak var retweetImageView: UIImageView?
    
    @IBOutlet weak var retweetCountLabel: UILabel!
    
    @IBOutlet weak var likeImageView: UIImageView?
    
    @IBOutlet weak var likeCountLabel: UILabel!
    
    
    var isLiked: Bool = false
    
    weak var delegate: TweetCellDelegate?
    
    var tweet: Tweet! {
        didSet {
            
            if let user = tweet.tweetCreater {
                
                if(user.name ==  User.currentUser?.name) {
                    
                    if let bannerImageUrl = user.bannerImageUrl {
                        var dictionary = User.currentUser?.dictionary
                        
                        dictionary?["profile_banner_url"] = bannerImageUrl as AnyObject
                        
                        var currentUser = User.currentUser
                        currentUser?.dictionary = dictionary
                        User.currentUser = currentUser
                    }
                }
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
                
                if (tweet.isRetweeted() && tweet.tweeter != nil) {

                    if let senderName = tweet.tweeter?.name! {
                        retweetViewLabel?.text = "\(senderName) Retweeted"
                        if (User.isCurrentUser(user: tweet.tweeter!)) {
                            print(" user equals in Tweet.swift")

                            retweetViewLabel?.text = "You Retweeted"
                        }
                    }
                } else {
                    retweetViewImage?.isHidden = true
                    retweetViewLabel?.isHidden = true
                    retweetView?.isHidden = true
                }
            }
            
            if let date = tweet.createdAt {
                timeAgoLabel?.text = Constants.getTimeAgoLabel(date: date)
            }
            
            if let text = tweet.text {
                tweetTextLabel?.text = text
                self.tweetTextLabel?.linkAttributes = [NSForegroundColorAttributeName: UIColor(red: 29/255, green: 161/255, blue: 242/255, alpha: 1)]

            }

            if let rtCount = tweet.retweetCount {
                retweetCountLabel.text = "\(rtCount)"
            }
            
            if let favCount = tweet.favoriteCount {
                likeCountLabel.text = "\(favCount)"
            }

            
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
    }


    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.tweetTextLabel?.enabledTextCheckingTypes =  NSTextCheckingAllTypes

        let profileImageTap = UITapGestureRecognizer(target: self, action: #selector(profileImageTapped))
        profileImageTap.numberOfTapsRequired = 1
        profileImageView?.isUserInteractionEnabled = true
        profileImageView?.addGestureRecognizer(profileImageTap)
        
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

        // Configure the view for the selected state
    }
    
    func profileImageTapped() {
        delegate?.tweetCell?(tweetCell: self, didTapProfileImage: self.tweet)
        
    }
    
    func replyButtonTapped() {
        delegate?.tweetCell!(tweetCell: self, didReply: self.tweet)

    }
    
    func reTweetButtonTapped() {
        delegate?.tweetCell!(tweetCell: self, didRetweetChange: tweet)
       
    }
    
    func likeButtonTapped() {
        self.delegate?.tweetCell?(tweetCell: self, didFavoriteChange: self.tweet)
        
    }

    func setRetweetImage(selected: Bool) {
        if (selected) {
            retweetImageView?.image = UIImage(named: "retweet")
        } else {
            retweetImageView?.image = UIImage(named: "undoretweet")
        }
    }
    
    
    func setLikeImage(selected: Bool) {
        if (selected) {

            likeImageView?.image = UIImage(named: "like")
        } else {
            likeImageView?.image = UIImage(named: "dislike")
        }
    }

}
