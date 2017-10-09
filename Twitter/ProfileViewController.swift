//
//  ProfileViewController.swift
//  Twitter
//
//  Created by Deepthy on 10/6/17.
//  Copyright © 2017 Deepthy. All rights reserved.
//

import UIKit

let offset_HeaderStop: CGFloat = 40.0 // At this offset the Header stops its transformations
let distance_W_LabelHeader: CGFloat = 30.0 // The distance between the top of the screen and the top of the White Label

class ProfileViewController: UIViewController {
    
    // MARK: Outlet properties
    @IBOutlet weak var pageDotControls: UIPageControl!
    
    @IBOutlet weak var profileDescription: UIView!
    var user: User?
    
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var profileView: UIView!
    @IBOutlet weak var segmentedView: UIView!
    @IBOutlet weak var avatarImage: UIImageView!
    @IBOutlet weak var headerLabel: UILabel!
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    @IBOutlet weak var followingButton: FollowingButton!
    
    fileprivate var pagedView: ProfileDescriptionPageViewController?
    var timelineChoice: Int?
    var userTweets: [Tweet]?
    var favoriteTweets: [Tweet]?

    var headerBlurImageView:UIImageView!
    var headerImageView:UIImageView!
    var ButtonOnImageView: UIButton = UIButton()
    let transparentPixel = UIImage.imageWithColor(color: UIColor.clear)
    var context = CIContext(options: nil)

    override func viewDidLoad() {
        super.viewDidLoad()
        segmentedControl.initUI()

        tableView.contentInset = UIEdgeInsetsMake(headerView.frame.height, 0, 0, 0)
        
        pageDotControls.addTarget(self, action: #selector(ProfileViewController.didChangePageControlValue), for: .valueChanged)
        
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "profileUser"), object: nil, userInfo: ["user": self.user])
    
    }

    func didChangePageControlValue() {
        pagedView?.scrollToViewController(index: pageDotControls.currentPage)
    }
    

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.isHidden = true
        
        //if (User.isCurrentUser(user: user)) {
           // followingButton.isHidden = true
        //}
        //if (user.isFollowing)! {
           // followingButton.setUpFollowingAppearance()
        //} else {
           // followingButton.setUpToFollowAppearance()
        //}
        //segmentedControl.tintColor = UIConstants.twitterPrimaryBlue
        
        // labels
        headerLabel.text = user?.name
                
        tableView.dataSource = self
        tableView.delegate = self
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 120
        
        //segmentedControl.selectedSegmentIndex = 0
        let appearance = UIPageControl.appearance()
        appearance.pageIndicatorTintColor = UIColor.lightGray
        appearance.currentPageIndicatorTintColor = UIColor.gray
        getUserTimeLine()
        
        getFavoriteTimeLine()
        timelineChoice = segmentedControl.selectedSegmentIndex //UIConstants.TimelineEnum.user
        segmentedControl.addTarget(self, action: #selector(onChangeTimeline(_:)), for: .valueChanged)
        
        
       /* let userParams = ["screen_name": user.screenname!]
        TwiSwiftClient.sharedInstance?.timelineWithChoice(choice: UIConstants.TimelineEnum.user, params: userParams, completionHandler: { (tweets: [Tweet]?, error: Error?) in
            self.userTweets = tweets
            self.tableView.reloadData()
        })
        
        let favoriteParams = ["screen_name": user.screenname!]
        TwiSwiftClient.sharedInstance?.timelineWithChoice(choice: UIConstants.TimelineEnum.favorite, params: favoriteParams, completionHandler: { (tweets: [Tweet]?, erro: Error?) in
            self.favoriteTweets = tweets
        })*/
    }
    
    func getUserTimeLine() {
       
        let userParams = ["screen_name": user?.screenname!]
        TwitterClient.sharedInstance.userTimeline(params: userParams, success: { (tweets: [Tweet]?) in
            print("inside ")
            if let newTweets = tweets {
                if newTweets.count > 0 {
                    self.userTweets = tweets
                    self.tableView.reloadData()
                }
            }
        }) { (error: Error) in
            print("error \(error.localizedDescription)")
        }
    }
    
    func getFavoriteTimeLine() {
        print("getFavoriteTimeLine ")
        
        let favoriteParams = ["screen_name": user?.screenname!]
        TwitterClient.sharedInstance.favoriteTimeline(params: favoriteParams, success: { (tweets: [Tweet]?) in
            print("inside ")
            if let newTweets = tweets {
                if newTweets.count > 0 {
                    self.favoriteTweets = tweets
                }
            }
        }) { (error: Error) in
            print("error \(error.localizedDescription)")
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.navigationBar.isHidden = false
    }
    
    func onChangeTimeline(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0:
            timelineChoice = 0
            break
        case 1:
            //timelineChoice = 1 //UIConstants.TimelineEnum.favorite
            break
        default:
            break
        }
        tableView.reloadData()
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        
        // Avatar
        let largeAvatarUrl = user?.profileImageUrl!.replacingOccurrences(of: "normal", with: "200x200")
        avatarImage.setImageWith(URL(string: largeAvatarUrl!)!)
        avatarImage.layer.borderColor = UIColor.white.cgColor
        avatarImage.layer.borderWidth = 3
        avatarImage.layer.cornerRadius = (avatarImage.frame.size.width)/2
        avatarImage.clipsToBounds = true
        
        // Header - Image
        headerImageView = UIImageView(frame: headerView.bounds)
        if user?.bannerImageView?.image == nil {
            headerImageView.setImageWith(URL(string: User.getBannerURL(user: user!))!)
        } else {
            headerImageView?.image = user?.bannerImageView?.image

        }
        
        headerImageView?.contentMode = UIViewContentMode.scaleAspectFill
        headerView.insertSubview(headerImageView, belowSubview: headerLabel)
        headerView.addSubview(ButtonOnImageView)

        // Header - Blurred Image
        headerBlurImageView = UIImageView(frame: headerView.bounds)
        
        headerBlurImageView?.contentMode = UIViewContentMode.scaleAspectFill
        headerBlurImageView?.alpha = 0.0
        headerView.insertSubview(headerBlurImageView, belowSubview: headerLabel)
        
        headerView.clipsToBounds = true
    }
    
        
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if let tweetDetailsViewController = segue.destination as? TweetDetailsViewController {
            if let tweetCell = sender as? TweetCell {
                tweetDetailsViewController.tweet = tweetCell.tweet
            }
        }
    }
    
    
    
    func followingButtonTapped(_ sender: FollowingButton) {
        
        if (sender.isFollowing!) {
            
            
            let unfollowAlert = UIAlertController(title: "\(user?.name!)", message: nil, preferredStyle: .actionSheet)
            
           /*  unfollowAlert.addAction(UIAlertAction(title: "Unfollow", style: .destructive, handler: { (action) in
                
                self.followingButton.setUpToFollowAppearance()
                
                TwiSwiftClient.sharedInstance?.changeFriendshipStatus(toFollow: false, screenName: self.user.screenname!, completionHandler: { (result) in
                    
                    if (!result!) {
                        self.followingButton.setUpFollowingAppearance()
                    }
                })
            }))*/
            
            unfollowAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            
            present(unfollowAlert, animated: true, completion: nil)
            
            
        } else {
            
            sender.setUpFollowingAppearance()
            /*TwiSwiftClient.sharedInstance?.changeFriendshipStatus(toFollow: true, screenName: self.user.screenname!, completionHandler: { (result) in
                
                if (!result!) {
                    self.followingButton.setUpToFollowAppearance()
                }
                
            })*/
        }
    }
    
    
    func blurEffect(avatarImage: UIImageView) -> UIImageView{
        
        let currentFilter = CIFilter(name: "CIGaussianBlur")
        let beginImage = CIImage(image: avatarImage.image!)
        currentFilter!.setValue(beginImage, forKey: kCIInputImageKey)
        currentFilter!.setValue(10, forKey: kCIInputRadiusKey)
        
        let cropFilter = CIFilter(name: "CICrop")
        cropFilter!.setValue(currentFilter!.outputImage, forKey: kCIInputImageKey)
        cropFilter!.setValue(CIVector(cgRect: beginImage!.extent), forKey: "inputRectangle")
        
        let output = cropFilter!.outputImage
        let cgimg = context.createCGImage(output!, from: output!.extent)
        let processedImage = UIImage(cgImage: cgimg!)
        avatarImage.image = processedImage
        return avatarImage
    }

}

// MARK: Tablev view delegate and datasource
extension ProfileViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if segmentedControl.selectedSegmentIndex == 0 { //timelineChoice == UIConstants.TimelineEnum.user {
            return userTweets?.count ?? 0
        } else { //if timelineChoice == UIConstants.TimelineEnum.favorite {
            return favoriteTweets?.count ?? 0
        }
        return 0
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TweetCell", for: indexPath) as! TweetCell
        cell.selectionStyle = .none
        cell.delegate = self

        if segmentedControl.selectedSegmentIndex == 0 {
            if let tweet = userTweets?[indexPath.row] {
                cell.tweet = tweet
            }
        } else {
            
            if let tweet = favoriteTweets?[indexPath.row] {
                cell.tweet = tweet
            }
        }
        return cell
    }
}


// MARK: Scroll view delegate
extension ProfileViewController: UIScrollViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        let offset = scrollView.contentOffset.y + headerView.bounds.height
        
        var avatarTransform = CATransform3DIdentity
        var headerTransform = CATransform3DIdentity
        
        // PULL DOWN -----------------
        
        if offset < 0 {
            
            let headerScaleFactor:CGFloat = -(offset) / headerView.bounds.height
            let headerSizevariation = ((headerView.bounds.height * (1.0 + headerScaleFactor)) - headerView.bounds.height)/2
            headerTransform = CATransform3DTranslate(headerTransform, 0, headerSizevariation, 0)
            headerTransform = CATransform3DScale(headerTransform, 1.0 + headerScaleFactor, 1.0 + headerScaleFactor, 0)
            
            // Hide views if scrolled super fast
            headerView.layer.zPosition = 0
            headerLabel.isHidden = true
        }
            
            // SCROLL UP/DOWN ------------
        else {
            // Header -----------
            headerTransform = CATransform3DTranslate(headerTransform, 0, max(-offset_HeaderStop, -offset), 0)
            
            //  ------------ Label
            headerLabel.isHidden = false
            let alignToNameLabel = -offset + headerLabel.frame.origin.y + headerView.frame.height + offset_HeaderStop
            
            headerLabel.frame.origin = CGPoint(x: headerLabel.frame.origin.x, y: max(alignToNameLabel, distance_W_LabelHeader + offset_HeaderStop))
            
            //  ------------ Blur

            headerBlurImageView?.alpha = min (1.0, (offset - alignToNameLabel)/distance_W_LabelHeader)
            
            // Avatar -----------
            let avatarScaleFactor = (min(offset_HeaderStop, offset)) / avatarImage.bounds.height / 1.4 // Slow down the animation
            let avatarSizeVariation = ((avatarImage.bounds.height * (1.0 + avatarScaleFactor)) - avatarImage.bounds.height) / 2.0
            avatarTransform = CATransform3DTranslate(avatarTransform, 0, avatarSizeVariation, 0)
            avatarTransform = CATransform3DScale(avatarTransform, 1.0 - avatarScaleFactor, 1.0 - avatarScaleFactor, 0)
            
            if offset <= offset_HeaderStop {
                
                if avatarImage.layer.zPosition < headerView.layer.zPosition{
                    headerView.layer.zPosition = 0
                }
            } else {
                if avatarImage.layer.zPosition >= headerView.layer.zPosition{
                    headerView.layer.zPosition = 2
                }
            }
        }
        
        // Apply Transformations
        headerView.layer.transform = headerTransform
        avatarImage.layer.transform = avatarTransform
        
        // Segment control
        
        let segmentViewOffset = profileView.frame.height - segmentedView.frame.height - offset
        let buttonViewOffset = headerLabel.frame.height//headerView.frame.height + ButtonOnImageView.frame.height - offset
     
        var segmentTransform = CATransform3DIdentity
        var btnTransform = CATransform3DIdentity

        // Scroll the segment view until its offset reaches the same offset at which the header stopped shrinking
        segmentTransform = CATransform3DTranslate(segmentTransform, 0, max(segmentViewOffset, -offset_HeaderStop), 0)
        
        btnTransform = CATransform3DTranslate(btnTransform, 0, max(buttonViewOffset, -offset_HeaderStop), 0)

        segmentedView.layer.transform = segmentTransform
        ButtonOnImageView.layer.transform = btnTransform
        // Set scroll view insets just underneath the segment control
        tableView.scrollIndicatorInsets = UIEdgeInsetsMake(segmentedView.frame.maxY, 0, 0, 0)
    }

    
}

extension UIImage {
    class func imageWithColor(color: UIColor) -> UIImage {
        let rect = CGRect(origin: CGPoint(x: 0, y:0), size: CGSize(width: 1, height: 1))
        UIGraphicsBeginImageContext(rect.size)
        let context = UIGraphicsGetCurrentContext()!
        
        context.setFillColor(color.cgColor)
        context.fill(rect)
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return image!
    }
}

extension ProfileViewController: ProfileDescriptionPageViewControllerDelegate {
    
    func profileDescriptionPageViewController(profileDescriptionPageViewController: ProfileDescriptionPageViewController,
                                    didUpdatePageCount count: Int) {
        pageDotControls.numberOfPages = count
    }
    
    func profileDescriptionPageViewController(profileDescriptionPageViewController: ProfileDescriptionPageViewController,
                                    didUpdatePageIndex index: Int) {
        pageDotControls.currentPage = index
    }
    
}

// MARK: - TweetCellDelegate
extension ProfileViewController: TweetCellDelegate {
    
    func tweetCell(tweetCell: TweetCell, didTapProfileImage tweet: Tweet) {
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        let profileViewController = storyboard.instantiateViewController(withIdentifier: "ProfileViewController") as! ProfileViewController
        let cellIndexPath = tableView.indexPath(for: tweetCell)
        
        profileViewController.user = tweet.tweetCreater
        
        
        let homeNavigationController = storyboard.instantiateViewController(withIdentifier: "Profile") as! UINavigationController
        
        let hamburgerViewController = UIApplication.shared.delegate!.window!!.rootViewController! as! HamburgerViewController
        
        self.navigationController?.pushViewController(profileViewController, animated: true)
    }
    
    func tweetCell(tweetCell: TweetCell, didReply tweet: Tweet) {
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let composeTweetViewController = storyboard.instantiateViewController(withIdentifier: "compose") as! ComposeTweetViewController
        
        composeTweetViewController.replyingTweet = tweet
        self.navigationController?.pushViewController(composeTweetViewController, animated: true)
        
    }
    
    func tweetCell(tweetCell: TweetCell, didRetweetChange tweet: Tweet) {
        
        let cellIndexPath = tableView.indexPath(for: tweetCell)
        
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
                            self.tableView.reloadRows(at: [cellIndexPath!], with: .none)
                            
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
        let cellIndexPath = tableView.indexPath(for: tweetCell)
        
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
                self.tableView.reloadRows(at: [cellIndexPath!], with: .none)
                
                
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
                self.tableView.reloadRows(at: [cellIndexPath!], with: .none)
                
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
extension UISegmentedControl {
    
    func initUI(){
        setupBackground()
        setupFonts()
    }
    
    func setupBackground(){
        let backgroundImage = UIImage(named: "segmented_unselected")
        let dividerImage = UIImage(named: "segmented_separator")
        let backgroundImageSelected = UIImage(named: "segmented_selected")
        let backgroundImageSelectedView = UIImageView.init(image: backgroundImageSelected?.withRenderingMode(UIImageRenderingMode.alwaysTemplate))
        UIImageView.appearance().tintColor = UIColor(red: 29/255, green: 161/255, blue: 242/255, alpha: 1)
        
        
        self.setBackgroundImage(backgroundImage, for: UIControlState(), barMetrics: .default)
        self.setBackgroundImage(backgroundImageSelectedView.image, for: .highlighted, barMetrics: .default)
        self.setBackgroundImage(backgroundImageSelectedView.image, for: .selected, barMetrics: .default)
        
        self.setDividerImage(dividerImage, forLeftSegmentState: UIControlState(), rightSegmentState: .selected, barMetrics: .default)
        self.setDividerImage(dividerImage, forLeftSegmentState: .selected, rightSegmentState: UIControlState(), barMetrics: .default)
        self.setDividerImage(dividerImage, forLeftSegmentState: UIControlState(), rightSegmentState: UIControlState(), barMetrics: .default)
    }
    
    func setupFonts(){
        let font = UIFont.systemFont(ofSize: 16.0)
        
        
        let normalTextAttributes = [
            NSForegroundColorAttributeName: UIColor.black,
            NSFontAttributeName: font
        ]
        
        self.setTitleTextAttributes(normalTextAttributes, for: UIControlState())
        self.setTitleTextAttributes(normalTextAttributes, for: .highlighted)
        self.setTitleTextAttributes(normalTextAttributes, for: .selected)
    }
}


