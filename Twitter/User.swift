//
//  User.swift
//  Twitter
//
//  Created by Deepthy on 9/26/17.
//  Copyright © 2017 Deepthy. All rights reserved.
//

import UIKit


class User: NSObject, NSCoding {
    static var _currentUser: User?
    static let currentUserKey = "CurrentUserKey"

    var name: String?
    var screenname: String?
    var profileImageUrl: String?
    var tagline: String?
    var userid: String?
    var dictionary: Dictionary<String, AnyObject>?
    var followersCount: Int?
    var followingCount: Int?
    var bannerImageUrl: String?
    var bannerImageView: UIImageView?
    var tweetsCount: Int?

    var isFollowing: Bool?
    var userDescription: String?
    var location: String?
    var displayURL: String?


    init(dictionary: Dictionary<String, AnyObject>) {
        
        name = dictionary["name"] as? String
        screenname = dictionary["screen_name"] as? String
        profileImageUrl = dictionary["profile_image_url"] as? String
        tagline = dictionary["description"] as? String

        userid = dictionary["id_str"] as? String
        followersCount = dictionary["followers_count"] as? Int
        followingCount = dictionary["friends_count"] as? Int
        bannerImageUrl = dictionary["profile_banner_url"] as? String

        if bannerImageUrl != nil {
            bannerImageView = UIImageView()
            bannerImageView?.setImageWith(URL(string: bannerImageUrl!)!)
        }

        tweetsCount = dictionary["statuses_count"] as? Int

        isFollowing = dictionary["following"] as? Bool
        userDescription = dictionary["description"] as? String

        location = dictionary["location"] as? String
        if let entities = dictionary["entities"] as? Dictionary<String, AnyObject> {
            
            if let url = entities["url"] as? Dictionary<String, AnyObject> {
                
                if let urls = url["urls"] as? [Dictionary<String, AnyObject>] {
                    
                    if urls.count > 0 {
                        let urlEntry = urls[0]
                        displayURL = urlEntry["display_url"] as? String
                       // profileURL = urlEntry["expanded_url"] as? String
                    }
                }
            }
        }
        
        
        self.dictionary = dictionary

    }
    
    // MARK: NSCoding
    func encode(with aCoder: NSCoder) {
        aCoder.encode(self.name, forKey: "name")
        aCoder.encode(self.screenname, forKey: "screenname")
        aCoder.encode(self.userid, forKey: "userid")
        aCoder.encode(self.profileImageUrl, forKey: "profileImageUrl")
        aCoder.encode(self.bannerImageUrl, forKey: "bannerImageUrl")
        aCoder.encode(self.userDescription, forKey: "userDescription")
      //  aCoder.encode(self.followingCount, forKey: "followingCount")
       // aCoder.encode(self.followersCount, forKey: "followersCount")
       // aCoder.encode(self.tweetsCount, forKey: "tweetsCount")
    }
    
    required convenience init?(coder decoder: NSCoder) {
        let name = decoder.decodeObject(forKey: "name") as! String
        let screenname = decoder.decodeObject(forKey: "screenname") as! String
        let userid = decoder.decodeObject(forKey: "userid") as! String
        let profileImageUrl = decoder.decodeObject(forKey: "profileImageUrl") as! String
        let bannerImageUrl = decoder.decodeObject(forKey: "bannerImageUrl") as? String
        let userDescription = decoder.decodeObject(forKey: "userDescription") as! String
        //let followingCount = decoder.decodeInt64(forKey: "followingCount") //.decodeInteger(forKey: "followingCount")
       // let followersCount = decoder.decodeInteger(forKey: "followersCount")
       // let tweetsCount = decoder.decodeInteger(forKey: "tweetsCount")

        self.init(name: name, screenname: screenname, userid: userid, profileImageUrl: profileImageUrl, bannerImageUrl: bannerImageUrl, userDescription: userDescription/*, followingCount: Int(followingCount), followersCount: followersCount, tweetsCount: tweetsCount*/)
    }
    
    private init(name:String, screenname:String, userid: String, profileImageUrl: String, bannerImageUrl: String?, userDescription: String/*, followingCount: Int, followersCount: Int, tweetsCount: Int*/){
        self.name = name
        self.screenname = screenname
        self.userid = userid
        self.profileImageUrl = profileImageUrl
        self.bannerImageUrl = bannerImageUrl
        self.userDescription = userDescription

       // self.followingCount = followingCount as Int
       // self.followersCount = followersCount
       // self.tweetsCount = tweetsCount
    }
    
    class var currentUser: User? {
        get {
            let defaults = UserDefaults.standard
            if _currentUser == nil {
                if let data = defaults.object(forKey: currentUserKey) as? Data {
                    
                    do {
                        let dictionary = try JSONSerialization.jsonObject(with: data, options: [])
                        _currentUser = User(dictionary: dictionary as! Dictionary<String, AnyObject>)
                        print(" in currentUser from session \((dictionary as! Dictionary<String, AnyObject>)["profile_banner_url"] as? String)")

                    } catch {
                        print("JSON serialization error: \(error)")
                    }
                }
            }
            return _currentUser
        }
        set(user) {

            _currentUser = user
            let defaults = UserDefaults.standard
            
            if _currentUser != nil {
                do {
                    let data = try JSONSerialization.data(withJSONObject: (user?.dictionary)! as Any, options: [])
                    defaults.set(data, forKey: currentUserKey)
                } catch {
                    print("JSON deserialization error: \(error)")
                }
            } else {
                defaults.removeObject(forKey: currentUserKey)
            }
            defaults.synchronize()
        }
    }

    class func isCurrentUser(user: User) -> Bool{
        return user.userid == User.currentUser?.userid
    }

    class func getBannerURL(user: User) -> String {
        if user.bannerImageUrl == nil {
            return "http://www.planwallpaper.com/static/images/autumn-free-wallpaper-autumn-colors_.jpg"
        }
        
        if isCurrentUser(user: user) {
            return user.bannerImageUrl!
        } else {
            return "\(user.bannerImageUrl!)/1500x500"
        }
    }
    
    func logout() {
        User.currentUser = nil
        TwitterClient.sharedInstance.deauthorize()
        
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "userDidLogoutNotification"), object: nil)

        let defaults = UserDefaults.standard
        defaults.removeObject(forKey: User.currentUserKey)
        defaults.synchronize()
        
    }

}
