//
//  Constants.swift
//  Twitter
//
//  Created by Deepthy on 9/27/17.
//  Copyright © 2017 Deepthy. All rights reserved.
//

import UIKit

struct Constants {
    
        
    static let detailsReuseIdentifier = "Details"
    
    struct Client {
        static let Baseurl = "https://api.twitter.com"
        static let Consumerkey = "uVadfW5NmZxMHEAU1UL312bnO"
        static let Secretkey = "IbgCPDYnz6JKLb6TVkrKZNc7cQ806k5NRIuDOICXZUmuVxbcYI"
    }
    
    struct Login {
        static let RequestToken = "https://api.twitter.com/oauth/request_token"
        static let Secretkey = "IbgCPDYnz6JKLb6TVkrKZNc7cQ806k5NRIuDOICXZUmuVxbcYI"
    }
    
    enum Timeline: String {
        case home = "1.1/statuses/home_timeline.json"
        case mentions = "1.1/statuses/mentions_timeline.json"
        case user = "1.1/statuses/user_timeline.json"
        case favorite = "1.1/favorites/list.json"
    }
    
    enum MenuEventEnum: String {
        case didOpen = "didOpen"
        case didClose = "didClose"
        
        var notification : Notification.Name {
            return Notification.Name(rawValue: self.rawValue)
        }
    }

    
    struct Favorites {
        struct Url {
            static let Create = "1.1/favorites/create.json?id="
            static let Destroy = "1.1/favorites/destroy.json?id="
        }
       
        struct Method {
            static let Create = "create"
            static let Destroy = "destroy"

        }
    }
    
    struct Tweet {
        struct Url {
            static let Retweet = "1.1/statuses/retweet/"
            static let UserRetweet = "1.1/statuses/show/"
            static let Destroy = "1.1/statuses/destroy/"
        }
        
    }
    
    static func getRetweetUrl(tweetId: String) -> String {
        
        return "\(Tweet.Url.Retweet)\(tweetId).json"
    }
    
    static func showUserRetweetUrl(tweetId: String) -> String {
        
        return "\(Tweet.Url.UserRetweet)\(tweetId).json"
    }
    
    static func DestroyTweetUrl(tweetId: String) -> String {
        
        return "\(Tweet.Url.Destroy)\(tweetId).json"
    }
    
    static func getTimeStampLabel(date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "M/dd/yy, hh:mm a "
        return dateFormatter.string(from: date)

    }
    
    static func getTimeAgoLabel(date: Date) -> String {
        
        let calendarScale: Set<Calendar.Component> = [.day, .hour, .minute, .second]
        let difference = Calendar.current.dateComponents(calendarScale, from: Date(), to: date)

        let day = difference.day
        let hour = difference.hour
        let minute = difference.minute
        let second = difference.second
        
        if abs(day!) > 0 {
            return "\(abs(day!))d"
        } else if abs(hour!) > 0 {
            return "\(abs(hour!))h"
        } else if abs(minute!) > 0 {
            return "\(abs(minute!))m"
        } else if (abs(second!) > 0 || second! == 0) {
            return "\(abs(second!))s"
        }
        return ""
    }
    
    static func getFriendlyCounts(count: Int) -> String {
        
        let doubleCount = Double(count)
        
        if count < 1000 {
            return "\(count)"
        } else if ((count > 1000 || count == 1000) && count < 1000000) {
            let newNumber = doubleCount / 1000.0
            return String(format: "%.1fK", newNumber)
        } else if (count > 1000000 || count == 1000000) {
            let newNumber = doubleCount / 1000000.0
            return String(format: "%.1fM", newNumber)
        }
        return "0"
    }

    
  
}
