//
//  Tweet.swift
//  Twitter
//
//  Created by Deepthy on 9/26/17.
//  Copyright © 2017 Deepthy. All rights reserved.
//

import UIKit

class Tweet: NSObject {
    
    
    var tweeter: User?
    var tweetCreater: User?
    var text: String?
    var createdAtString: String?
    var createdAt: Date?
    var retweetStatus: Dictionary<String, AnyObject>?
    var retweetCount: Int?
    var retweetedByUser: Bool?
    var favorited: Bool?
    var favoriteCount: Int?
    var remoteId: Int64?
    var remoteIdStr: String?
    var originalTweetId: String?

    
    init(dictionary: Dictionary<String, AnyObject>) {
        
        text = dictionary["text"] as? String
        createdAtString = dictionary["created_at"] as? String
        retweetStatus = dictionary["retweeted_status"] as? Dictionary<String, AnyObject>
        
        if let createdAtString = createdAtString {
            let formatter = DateFormatter()
            formatter.dateFormat = "EEE MMM d HH:mm:ss Z y"
            createdAt = formatter.date(from: createdAtString)
        }
        
        if let userDict = dictionary["user"] as? Dictionary<String, AnyObject> {

            tweeter = User(dictionary: userDict)

            if(tweeter?.name ==  User.currentUser?.name) {
                
                if let bannerImageUrl = tweeter?.bannerImageUrl {

                   // var dictionary = User.currentUser?.dictionary
                    
                  //  dictionary?["profile_banner_url"] = bannerImageUrl as AnyObject
                    
                 //   var currentUser = User.currentUser
                 //   currentUser?.dictionary = dictionary
                    User.currentUser = tweeter
                }
            }

            
        }
        
        if let rtDictionary = retweetStatus {
            tweetCreater = User(dictionary: rtDictionary["user"] as! Dictionary<String, AnyObject>)

        } else {
            tweetCreater = tweeter
        }
        
        retweetCount = (dictionary["retweet_count"] as? Int) ?? 0
        retweetedByUser = dictionary["retweeted"] as? Bool //retweeted by current user
        favorited = dictionary["favorited"] as? Bool
        favoriteCount = (dictionary["favorite_count"] as? Int) //?? 0
        remoteId = dictionary["id"] as? Int64
        remoteIdStr = dictionary["id_str"] as? String
        
        if retweetStatus != nil {
            originalTweetId = retweetStatus?["id_str"] as? String
        } else {
            originalTweetId = remoteIdStr
        }

    }
    
    func isRetweeted() -> Bool {
        if retweetStatus != nil {
            return true
        } else {
            return false
        }
    }
    
    func increaseRetweetCount() {
        
        retweetCount = retweetCount! + 1
    }
    
    func decreaseRetweetCount() {
        retweetCount = retweetCount! - 1
        
        if(retweetCount! < 0) {
            retweetCount = 0
        }
    }
    
    func increaseFavCount() {
        favoriteCount = favoriteCount! + 1
    }
    
    func decreaseFavCount() {
        favoriteCount = favoriteCount! - 1
        if(favoriteCount! < 0) {
            favoriteCount = 0
        }
    }

    
    class func tweetsWithArray(dictionaries: [Dictionary<String, AnyObject>]) -> [Tweet] {
        var tweets = [Tweet]()
        for dictionary in dictionaries {
            tweets.append(Tweet(dictionary: dictionary))
        }
        return tweets
    }

}
