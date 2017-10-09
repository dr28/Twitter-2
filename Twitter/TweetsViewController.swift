//
//  TweetsViewController.swift
//  Twitter
//
//  Created by Deepthy on 9/26/17.
//  Copyright © 2017 Deepthy. All rights reserved.
//

import UIKit
import ACProgressHUD_Swift

class TweetsViewController: UIViewController {

    var tweets: [Tweet]!
    
    @IBOutlet weak var tweetsTableView: UITableView!
    
    fileprivate let refreshControl = UIRefreshControl()
    fileprivate let progressView = ACProgressHUD.shared

    fileprivate var loadMoreView: InfiniteScrollActivityView!
    fileprivate var isMoreDataLoading = false
    
    fileprivate func getInfiniteScrollFrame() -> CGRect {
        return CGRect(
            x: 0,
            y: tweetsTableView.contentSize.height,
            width: tweetsTableView.bounds.size.width,
            height: InfiniteScrollActivityView.defaultHeight
        )
    }
    var user = User.currentUser
    
    var timeline:String!

    override func viewDidLoad() {
        super.viewDidLoad()
        registerForNotifications()
        self.navigationItem.title = "Home"
        navigationController!.navigationBar.isTranslucent=false

        // Infinite scroll view setup
        loadMoreView = InfiniteScrollActivityView(frame: getInfiniteScrollFrame())
        tweetsTableView.contentInset.bottom += InfiniteScrollActivityView.defaultHeight
        tweetsTableView.addSubview(loadMoreView!)

        // set up the refresh control
        refreshControl.backgroundColor =  UIColor(red: (231.0/255.0), green: (236.0/255.0), blue: (240.0/255.0), alpha: 1.0)
        refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
        refreshControl.addTarget(self, action: #selector(refresh(sender:)), for: UIControlEvents.valueChanged)
        tweetsTableView.addSubview(refreshControl)
        
        let composeImageView = UIImageView(image: UIImage(named: "compose"))
        composeImageView.frame = CGRect(x: 0, y: 0, width: 35, height: 35)
        let composeTap = UITapGestureRecognizer(target: self, action: #selector(composeTweet))
        composeTap.numberOfTapsRequired = 1
        composeImageView.addGestureRecognizer(composeTap)
        let rightBarButton = UIBarButtonItem.init(customView: composeImageView)
        self.navigationItem.rightBarButtonItem = rightBarButton
        
        
        let tapGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(showAccounts(_:)))
        self.navigationController?.navigationBar.addGestureRecognizer(tapGestureRecognizer)
        
        tweetsTableView.tableFooterView = UIView()
        
        if let profileImageUrl = user?.profileImageUrl {
            let largeImageUrl = profileImageUrl.replacingOccurrences(of: "normal", with: "200x200")
            
            if let url = URL(string: largeImageUrl) {
                let profileImage = UIImage()
                let profileImageView = UIImageView(image: profileImage)
                profileImageView.setImageWith(url)
                profileImageView.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
                
                profileImageView.layer.cornerRadius = (profileImageView.frame.size.width)/2
                profileImageView.clipsToBounds = true
                let profileImageTap = UITapGestureRecognizer(target: self, action: #selector(onOpenMenu))
                profileImageTap.numberOfTapsRequired = 1
                profileImageView.isUserInteractionEnabled = true
                profileImageView.addGestureRecognizer(profileImageTap)
                
                let leftbarButton = UIBarButtonItem.init(customView: profileImageView)
                self.navigationItem.leftBarButtonItem = leftbarButton
                
            }
        }

        progressView.showHUD()
        if(timeline == nil) {
            getHomeLine()
        } else {
            getMentionsLine()

        }
        
        tweetsTableView.dataSource = self
        tweetsTableView.delegate = self
        tweetsTableView.rowHeight = UITableViewAutomaticDimension
        tweetsTableView.estimatedRowHeight = 120
        
    }
    
    func onOpenMenu() {
        NotificationCenter.default.post(name: Constants.MenuEventEnum.didOpen.notification, object: nil, userInfo: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        progressView.hideHUD()
    }
    
    func registerForNotifications() {
        // Register to receive new tweet notifications
        NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: "TweetDidUpdate"),
                                               object: nil, queue: OperationQueue.main) {
                                                [weak self] (notification: Notification) in
                                                let tweet = notification.userInfo!["tweet"] as! Tweet
                                                self?.tweets.insert(tweet, at: 0)
                                                self?.tweetsTableView.reloadData()
        }
    }
    

    // MARK: - Refresh Control

    func refresh(sender:AnyObject) {
        progressView.showHUD()
        if(timeline == nil) {
            getHomeLine()
        } else {
            getMentionsLine()
            
        }
        progressView.hideHUD()
    
    }
    
    func getHomeLine() {
        TwitterClient.sharedInstance.homeTimeline(success: { (tweets: [Tweet]?) in
            if let newTweets = tweets {
                if newTweets.count > 0 {
                    self.tweets = tweets
                    self.tweetsTableView.reloadData()
                }
            }
            self.refreshControl.endRefreshing()
        }) { (error: Error) in
            print("error \(error.localizedDescription)")
        }
    }
    
    func getMentionsLine() {

        TwitterClient.sharedInstance.mentionsTimeline(success: { (tweets: [Tweet]?) in
            print("inside ")

            if let newTweets = tweets {
                if newTweets.count > 0 {
                    self.tweets = tweets
                    self.tweetsTableView.reloadData()
                }
            }
            self.refreshControl.endRefreshing()
        }) { (error: Error) in
            print("error \(error.localizedDescription)")
        }
    }
    
    func composeTweet() {
        
       performSegue(withIdentifier: "composeTweet", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

        if let tweetDetailsViewController = segue.destination as? TweetDetailsViewController {
            if let tweetCell = sender as? TweetCell {
                tweetDetailsViewController.tweet = tweetCell.tweet
            }
        }
    }
    
    @IBAction func prepareForUnwind(segue: UIStoryboardSegue){
        
    }
    
    
    @IBAction func logOut(_ sender: Any) {
        
        User.currentUser?.logout()
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let loginViewController = storyboard.instantiateViewController(withIdentifier: "login")
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.window?.rootViewController = loginViewController

    }
    
    func showAccounts(_ : AnyObject){
        
        let homeNavigationController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "Accounts") as! UINavigationController
        
        let hamburgerViewController = UIApplication.shared.delegate!.window!!.rootViewController! as! HamburgerViewController
            
        hamburgerViewController.contentViewController = homeNavigationController
    }
    
    
}

// MARK: - Scrollview Delegate methods

extension TweetsViewController: UIScrollViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        if !isMoreDataLoading {
            let scrollViewContentHeight = tweetsTableView.contentSize.height
            let scrollOffsetThreshold = scrollViewContentHeight - tweetsTableView.bounds.size.height
            
            if scrollView.contentOffset.y > scrollOffsetThreshold && tweetsTableView.isDragging {
                isMoreDataLoading = true
                
                self.loadMoreView.frame = getInfiniteScrollFrame()
                
                self.loadMoreView.startAnimating()
                getMoreTweets()
            }
        }
    }
    
    fileprivate func getMoreTweets() {
        
        let oldestId = self.tweets?.last?.remoteIdStr as Any
        let params = ["max_id": oldestId]
        
        TwitterClient.sharedInstance.homeTimeline(params: params, success: { (tweets: [Tweet]?) in
            
            self.loadMoreView.stopAnimating()
            
            if let tweets = tweets {
                
                if tweets.count > 0 {
                    self.tweets?.removeLast()
                }
                
                for tweet in tweets {
                    self.tweets?.append(tweet)
                    self.tweetsTableView.reloadData()
                }
            }
            
        }) { (error: Error) in
            print("error \(error.localizedDescription)")
        }
        self.isMoreDataLoading = false
    }
    
}


// MARK: - Table View Datasource and Delegate
extension TweetsViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return self.tweets?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "TweetCell", for: indexPath) as! TweetCell
        let bgColorView = UIView()
        bgColorView.backgroundColor = UIColor(red: (231.0/255.0), green: (236.0/255.0), blue: (240.0/255.0), alpha: 1.0).withAlphaComponent(0.1)
        cell.selectedBackgroundView = bgColorView
        cell.delegate = self
        
        cell.retweetViewImage?.isHidden = false
        cell.retweetViewLabel?.isHidden = false
        cell.retweetView?.isHidden = false

        if let tweet = tweets?[indexPath.row] {
            cell.tweet = tweet
        }
        return cell
    }
 }

// MARK: - TweetCellDelegate
extension TweetsViewController: TweetCellDelegate {
    
    func tweetCell(tweetCell: TweetCell, didTapProfileImage tweet: Tweet) {
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        let profileViewController = storyboard.instantiateViewController(withIdentifier: "ProfileViewController") as! ProfileViewController
        let cellIndexPath = tweetsTableView.indexPath(for: tweetCell)
        
        profileViewController.user = tweet.tweetCreater
        
        let homeNavigationController = storyboard.instantiateViewController(withIdentifier: "Profile") as! UINavigationController
        
        let hamburgerViewController = UIApplication.shared.delegate!.window!!.rootViewController! as! HamburgerViewController
        
        //hamburgerViewController.contentViewController = homeNavigationController
    
        self.navigationController?.pushViewController(profileViewController, animated: true)
    }


    func tweetCell(tweetCell: TweetCell, didReply tweet: Tweet) {
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let composeTweetViewController = storyboard.instantiateViewController(withIdentifier: "compose") as! ComposeTweetViewController
        
        composeTweetViewController.replyingTweet = tweet
        self.navigationController?.pushViewController(composeTweetViewController, animated: true)
        
    }
    
    
    func tweetCell(tweetCell: TweetCell, didRetweetChange tweet: Tweet) {
        
        let cellIndexPath = tweetsTableView.indexPath(for: tweetCell)

        let retweetAlert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)

        if (!tweet.retweetedByUser!) {
            retweetAlert.addAction(UIAlertAction(title: "Retweet", style: .default, handler: { (action) in
                
                tweetCell.tweet.retweetedByUser = true
                tweetCell.tweet.increaseRetweetCount()

                UIView.animate(withDuration: 0.3, animations: {
                    
                    tweetCell.retweetImageView?.transform = CGAffineTransform(scaleX: 3, y: 3)
                    tweetCell.setRetweetImage(selected: true)
                    
                }, completion: { (finish) in
                    
                    UIView.animate(withDuration: 0.1, animations: {
                        tweetCell.retweetImageView?.transform = CGAffineTransform(scaleX: 1, y: 1)
                    }, completion: { (finish) in
                        
                        TwitterClient.sharedInstance.reweet(tweetIdString: "\(tweetCell.tweet.remoteId!)", success: { (tweet: Tweet?) in
                                tweetCell.tweet = tweet
                            self.tweetsTableView.reloadRows(at: [cellIndexPath!], with: .none)
            
                        }) { (error: Error) in
                            print("error \(error.localizedDescription)")
                            tweetCell.tweet.decreaseRetweetCount()
                            tweetCell.setRetweetImage(selected: false)
                            tweetCell.tweet.retweetedByUser = false
                        }
                    })
                })
            }))
        } else {
            retweetAlert.addAction(UIAlertAction(title: "Undo Retweet", style: .destructive, handler: { (action) in
                
                tweetCell.tweet.retweetedByUser = false
                tweetCell.tweet.decreaseRetweetCount()
                tweetCell.setRetweetImage(selected: false)
                tweetCell.tweet = tweet

                // unretweet
                TwitterClient.sharedInstance.findUserRetweet(tweetId: tweetCell.tweet.originalTweetId!, success: { (tweet: (Tweet?)) in

                }) { (error: Error) in
                    print("error \(error.localizedDescription)")
                    tweetCell.tweet.retweetedByUser = true
                    tweetCell.tweet.increaseRetweetCount()
                    tweetCell.setRetweetImage(selected: true)
                }
                
            }))
        }
        retweetAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))

        present(retweetAlert, animated: true, completion: nil)
        
    }
   
    func tweetCell(tweetCell: TweetCell, didFavoriteChange tweet: Tweet) {
        let cellIndexPath = tweetsTableView.indexPath(for: tweetCell)
        
        if (!tweetCell.isLiked) {
            
            tweetCell.tweet.favorited = true
            tweetCell.tweet.increaseFavCount()
            
            UIView.animate(withDuration: 0.1, animations: {
                
                tweetCell.likeImageView?.transform = CGAffineTransform(scaleX: 4, y: 4)
                tweetCell.setLikeImage(selected: true)
                
            }, completion: { (finish) in
                
                UIView.animate(withDuration: 0.1, animations: {
                    tweetCell.likeImageView?.transform = CGAffineTransform(scaleX: 1, y: 1)
                })
            })

            TwitterClient.sharedInstance.createFavorite(tweet: tweetCell.tweet, success: { (tweet: (Tweet)) in
                self.tweetsTableView.reloadRows(at: [cellIndexPath!], with: .none)

                
            }) { (error: Error) in
                tweetCell.setLikeImage(selected: false)
                tweetCell.tweet.favorited = false
                tweetCell.tweet.decreaseFavCount()
                print(error.localizedDescription)
            }

        } else {
            tweetCell.tweet.favorited = false
            tweetCell.tweet.decreaseFavCount()

            tweetCell.setLikeImage(selected: false)
            
            TwitterClient.sharedInstance.deleteFavorite(tweet: tweetCell.tweet, success: { (tweet: (Tweet)) in
                self.tweetsTableView.reloadRows(at: [cellIndexPath!], with: .none)

            }) { (error: Error) in
                tweetCell.tweet.favorited = true
                tweetCell.setLikeImage(selected: true)
                tweetCell.tweet.increaseFavCount()
                
                print(error.localizedDescription)
            }
        }
        tweetCell.isLiked = !tweetCell.isLiked
    }
}
