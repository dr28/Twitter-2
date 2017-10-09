//
//  TwitterClient.swift
//  Twitter
//
//  Created by Deepthy on 9/26/17.
//  Copyright © 2017 Deepthy. All rights reserved.
//

import UIKit
import BDBOAuth1Manager

class TwitterClient: BDBOAuth1SessionManager {
    
    static let sharedInstance: TwitterClient = TwitterClient(baseURL: URL(string: Constants.Client.Baseurl), consumerKey: ManageCredentials.getKey(), consumerSecret: ManageCredentials.getSecret())
    static var currentAccount:Account!
    static var accounts:[Account] = []

    var loginSuccess: ((User?) -> ()?)? = nil
    var loginFailure: ((Error) -> ())?

    func login(success: @escaping (User?) -> (), failure: @escaping (Error) -> ()) {
        print("login ")
        requestSerializer.removeAccessToken()

        loginSuccess = success
        loginFailure = failure
        
        TwitterClient.sharedInstance.deauthorize()
        TwitterClient.sharedInstance.fetchRequestToken(withPath: "https://api.twitter.com/oauth/request_token", method: "GET", callbackURL: URL(string: "twitterDemo://oauth"), scope: nil, success: { (requestToken: BDBOAuth1Credential?) in
            
            let url = URL(string: "https://api.twitter.com/oauth/authorize?oauth_token=\((requestToken?.token)!)")

            UIApplication.shared.openURL(url!)
            
        }, failure: { (error: Error?) in
                self.loginFailure!(error!)
        })
    }
    
    func handleOpenUrl(url: URL) {
        print("handleOpenUrl ")

        let requestToken = BDBOAuth1Credential(queryString: url.query)

        fetchAccessToken(withPath: "oauth/access_token", method: "POST", requestToken: requestToken, success: {
            (accessToken: BDBOAuth1Credential?) -> Void in
            TwitterClient.sharedInstance.requestSerializer.saveAccessToken(accessToken)

            //self.loginSuccess!(<#User?#>)
            self.currentAccount(accessToken: accessToken!)
            
        }) { (error: Error?) -> Void in
            self.loginFailure!(error!)

        }
    }
    
    func currentAccount(accessToken: BDBOAuth1Credential) {
        print("currentAccount ")

        get("1.1/account/verify_credentials.json", parameters: nil, progress: nil, success: { (task: URLSessionDataTask, response: Any?) in
            
            let userDictionary = response as! Dictionary<String, AnyObject>
            print(" user intialization in Tweitterclient")

            let user = User(dictionary: userDictionary)
            User.currentUser = user
            
            TwitterClient.accounts.append(Account(user: user, accessToken: accessToken))
            TwitterClient.sharedInstance.saveAccounts()
            TwitterClient.currentAccount = (Account(user: user, accessToken: accessToken))
            

            self.loginSuccess!(user)

            
        }, failure: { (task: URLSessionDataTask?, error: Error) in
            print("error:  \(error.localizedDescription)")
            self.loginSuccess!(nil)

            
        })
        
    }
    
    func saveAccounts(){
        let accountsData = NSKeyedArchiver.archivedData(withRootObject: TwitterClient.accounts)
        UserDefaults.standard.set(accountsData, forKey: "accounts")
    }
    
    func hasAccounts() -> Bool{
        
        if let accountsData = UserDefaults.standard.object(forKey: "accounts") as? NSData {
            let accountsArray = NSKeyedUnarchiver.unarchiveObject(with: accountsData as Data) as? [Account]
            
            TwitterClient.accounts = accountsArray!
            if(accountsArray?.count != 0) {
                TwitterClient.currentAccount = accountsArray?[0]
            }
            return true
        } else {
            return false
        }
    }
    
    func userTimeline(params: Dictionary<String, Any>?, success: @escaping ([Tweet]) -> (), failure: @escaping (Error) -> ()) {
        
        timelineFor(endpoint: Constants.Timeline.user.rawValue, params: params, success: success, failure: failure)
        
    }
    
    func favoriteTimeline(params: Dictionary<String, Any>?, success: @escaping ([Tweet]) -> (), failure: @escaping (Error) -> ()) {
        
        timelineFor(endpoint: Constants.Timeline.favorite.rawValue, params: params, success: success, failure: failure)
        
    }
    
    func mentionsTimeline(success: @escaping ([Tweet]) -> (), failure: @escaping (Error) -> ()) {
        
        timelineFor(endpoint: Constants.Timeline.mentions.rawValue, params: nil, success: success, failure: failure)
        
    }
    
    func homeTimeline(success: @escaping ([Tweet]) -> (), failure: @escaping (Error) -> ()) {
        
        timelineFor(endpoint: Constants.Timeline.home.rawValue, params: nil, success: success, failure: failure)
        
    }
    
    func homeTimeline(params: Dictionary<String, Any>?, success: @escaping ([Tweet]) -> (), failure: @escaping (Error) -> ()) {
        
        timelineFor(endpoint: Constants.Timeline.home.rawValue, params: params, success: success, failure: failure)
        
    }
    
    func timelineFor(endpoint: String, params: Dictionary<String, Any>?,success: @escaping ([Tweet]) -> (), failure: @escaping (Error) -> ()) {
        print("endpoint:  \(endpoint)")

        get(endpoint, parameters: params, progress: nil, success: { (task: URLSessionDataTask, response: Any?) in
            
            let dictionaries = response as! [Dictionary<String, AnyObject>]
            let tweets = Tweet.tweetsWithArray(dictionaries: dictionaries)
            
            success(tweets)
            
        }, failure: { (task: URLSessionDataTask?, error: Error) in
            failure(error)
        })
        
    }
    
    // MARK: - New Tweet
    
    func update(status: String, inReplyToStatusId: String?, success: @escaping (Tweet) -> (), failure: @escaping (Error) -> ()) {
        
        var params = ["status": status]

        if let replyIdStr = inReplyToStatusId {
            params["in_reply_to_status"] = replyIdStr
        }

        self.post("1.1/statuses/update.json", parameters: params, progress: nil, success: { (operation: URLSessionDataTask, response: Any?) in
            
            let newTweet = Tweet(dictionary: response as! Dictionary<String, AnyObject>)
            let notificationName = NSNotification.Name(rawValue: "TweetDidUpdate")
            NotificationCenter.default.post(name: notificationName, object: nil, userInfo: ["tweet": newTweet])
            
            success(newTweet)

        }, failure: { (operation: URLSessionDataTask?, error: Error) in
            failure(error)

            print(error.localizedDescription)
        })
    }

    // MARK: - Retweet

    func reweet(tweetIdString: String, success: @escaping (Tweet?) -> (), failure: @escaping (Error) -> ()) {
        
        post(Constants.getRetweetUrl(tweetId: tweetIdString), parameters: nil, progress: nil, success: { (operation: URLSessionDataTask, response: Any?) in
           
            let reTweet = Tweet(dictionary: response as! Dictionary<String, AnyObject>)
            success(reTweet)
            
        }, failure: { (operation: URLSessionDataTask?, error: Error) in
            
            print(error.localizedDescription)
            failure(error)

        })
    }

    // MARK: - Find Retweets
    func findUserRetweet(tweetId: String, success: @escaping (Tweet) -> (), failure: @escaping (Error) -> ()) {
        
        let params = ["include_my_retweet" : true]
        
        self.get(Constants.showUserRetweetUrl(tweetId: tweetId), parameters: params, progress: nil, success: { (operation: URLSessionDataTask, response: Any?) in
            
            if let userTweet = response as? Dictionary<String, AnyObject> {
                
                if let currentUserRetweet = userTweet["current_user_retweet"] as? Dictionary<String, AnyObject> {
                    
                    if let userRetweetId = currentUserRetweet["id_str"] as? String {
                        self.deleteTweet(tweetId: userRetweetId, success: { (tweet: (Tweet?)) in
                            
                            let reTweet = Tweet(dictionary: response as! Dictionary<String, AnyObject>)

                            success(reTweet)
                            
                        }) { (error: Error) in
                            print("error ==== \(error.localizedDescription)")
                        }
                    }
                }
            }
            
        }, failure: { (operation: URLSessionDataTask?, error: Error) in
            print(error.localizedDescription)
        })
    }

    func deleteTweet(tweetId: String, success: @escaping (Tweet) -> (), failure: @escaping (Error) -> ()) {
        
        self.post(Constants.DestroyTweetUrl(tweetId: tweetId), parameters: nil, progress: nil, success: { (operation: URLSessionDataTask, response: Any?) in
            
            let deletedTweet = Tweet(dictionary: response as! Dictionary<String, AnyObject>)

            success(deletedTweet)
            
        }, failure: { (operation: URLSessionDataTask?, error: Error) in
            
            print(error.localizedDescription)
            
        })
    }

    
    // MARK: - Favorite
    func createFavorite(tweet: Tweet, success: @escaping (Tweet) -> (), failure: @escaping (Error) -> ()) {

         updateFavorite(endpoint: Constants.Favorites.Url.Create, tweet: tweet, success: success, failure: failure)

    }
    
    func deleteFavorite(tweet: Tweet, success: @escaping (Tweet) -> (), failure: @escaping (Error) -> ()) {

        updateFavorite(endpoint: Constants.Favorites.Url.Destroy, tweet: tweet, success: success, failure: failure)

    }
    
    func updateFavorite(endpoint: String, tweet: Tweet, success: @escaping (Tweet) -> (), failure: @escaping (Error) -> ()) {
        if let remoteId = tweet.remoteId {

            self.post("\(endpoint)\(remoteId)", parameters: nil, progress: nil, success: { (operation: URLSessionDataTask, response: Any?) in
                
                let tweet = Tweet(dictionary: response as! Dictionary<String, AnyObject>)
                success(tweet)
                
            }, failure: { (task: URLSessionDataTask?, error: Error) in
    
                print(error.localizedDescription)
            })
        }

    }

}



