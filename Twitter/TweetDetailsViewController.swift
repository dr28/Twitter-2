//
//  TweetDetailsViewController.swift
//  Twitter
//
//  Created by Deepthy on 9/28/17.
//  Copyright © 2017 Deepthy. All rights reserved.
//

import UIKit

class TweetDetailsViewController: UIViewController {
    
    @IBOutlet weak var tweetDetailsTableView: UITableView!

    var tweet: Tweet!
    
    var tweetModified = false

    override func viewDidLoad() {
        super.viewDidLoad()

        tweetDetailsTableView.dataSource = self
        tweetDetailsTableView.delegate = self
        //navigationController?.delegate = self

        tweetDetailsTableView.rowHeight = UITableViewAutomaticDimension
        tweetDetailsTableView.estimatedRowHeight = 120
        tweetDetailsTableView.showsVerticalScrollIndicator = false
        tweetDetailsTableView.tableFooterView = UIView()

    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if let tweetDetailsViewController = segue.destination as? TweetDetailsViewController {
            if let tweetCell = sender as? TweetCell {
                tweetDetailsViewController.tweet = tweetCell.tweet
            }
        }
    }
    
}

extension TweetDetailsViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        switch indexPath.row {
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: "DetailsRow1", for: indexPath) as! TweetDetailsRowOneCell
            cell.tweet = self.tweet
            cell.selectionStyle = .none
            return cell

        case 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: "DetailsRow2", for: indexPath) as! TweetDetailsRowTwoCell
            cell.selectionStyle = .none
            cell.tweet = self.tweet
            return cell

        case 2:
            let cell = tableView.dequeueReusableCell(withIdentifier: "DetailsRow3", for: indexPath) as! TweetDetailsRowThreeCell
            cell.selectionStyle = .none
            cell.tweet = self.tweet
            cell.delegate = self
            return cell

        default:
            return UITableViewCell()
        }
    }
}

extension TweetDetailsViewController: TweetDetailsRowThreeCellDelegate {
    
    func tweetDetailsRowThreeCell(tweetDetailsRowThreeCell: TweetDetailsRowThreeCell, didReply tweet: Tweet) {
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let composeTweetViewController = storyboard.instantiateViewController(withIdentifier: "compose") as! ComposeTweetViewController
        
        composeTweetViewController.replyingTweet = tweet
        self.navigationController?.pushViewController(composeTweetViewController, animated: true)
        
    }

    func tweetDetailsRowThreeCell(tweetDetailsRowThreeCell: TweetDetailsRowThreeCell, didRetweetChange tweet: Tweet) {
        
        let cellIndexPath = tweetDetailsTableView.indexPath(for: tweetDetailsRowThreeCell)
        
        let retweetAlert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)

        if (!tweet.retweetedByUser!) {
            retweetAlert.addAction(UIAlertAction(title: "Retweet", style: .default, handler: { (action) in
                self.tweetModified = true
                tweetDetailsRowThreeCell.tweet.retweetedByUser = true
                tweetDetailsRowThreeCell.tweet.increaseRetweetCount()

                UIView.animate(withDuration: 0.3, animations: {
                    
                    tweetDetailsRowThreeCell.retweetImageView?.transform = CGAffineTransform(scaleX: 3, y: 3)
                    tweetDetailsRowThreeCell.setRetweetImage(selected: true)
                    
                }, completion: { (finish) in
                    
                    UIView.animate(withDuration: 0.1, animations: {
                        tweetDetailsRowThreeCell.retweetImageView?.transform = CGAffineTransform(scaleX: 1, y: 1)
                    }, completion: { (finish) in
                        self.tweet = tweetDetailsRowThreeCell.tweet

                        TwitterClient.sharedInstance.reweet(tweetIdString: "\(tweetDetailsRowThreeCell.tweet.remoteId!)", success: { (tweet: Tweet?) in

                            let prevIndexPath = IndexPath.init(row: (cellIndexPath?.row)! - 1, section: (cellIndexPath?.section)!)
                            
                            self.tweetDetailsTableView.reloadRows(at: [prevIndexPath], with: .none)
                            
                        }) { (error: Error) in
                            print("error \(error.localizedDescription)")
                            tweetDetailsRowThreeCell.tweet.decreaseRetweetCount()
                            tweetDetailsRowThreeCell.setRetweetImage(selected: false)
                            tweetDetailsRowThreeCell.tweet.retweetedByUser = false
                        }
                    })
                })
            }))
        } else {
            retweetAlert.addAction(UIAlertAction(title: "Undo Retweet", style: .destructive, handler: { (action) in
                self.tweetModified = true

                tweetDetailsRowThreeCell.tweet.retweetedByUser = false
                tweetDetailsRowThreeCell.tweet.decreaseRetweetCount()
                tweetDetailsRowThreeCell.setRetweetImage(selected: false)

                self.tweet = tweetDetailsRowThreeCell.tweet

                TwitterClient.sharedInstance.findUserRetweet(tweetId: tweetDetailsRowThreeCell.tweet.originalTweetId!, success: { (returnedTweet: (Tweet?)) in
                    
                    let prevIndexPath = IndexPath.init(row: (cellIndexPath?.row)! - 1, section: (cellIndexPath?.section)!)
                    
                    self.tweetDetailsTableView.reloadRows(at: [prevIndexPath], with: .none)
                    
                }) { (error: Error) in
                    print("error \(error.localizedDescription)")
                    tweetDetailsRowThreeCell.tweet.retweetedByUser = true
                    tweetDetailsRowThreeCell.tweet.increaseRetweetCount()
                    tweetDetailsRowThreeCell.setRetweetImage(selected: true)
                }
                
            }))
        }
        retweetAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        present(retweetAlert, animated: true, completion: nil)
        
    }

    func tweetDetailsRowThreeCell(tweetDetailsRowThreeCell: TweetDetailsRowThreeCell, didFavoriteChange tweet: Tweet) {
        let cellIndexPath = tweetDetailsTableView.indexPath(for: tweetDetailsRowThreeCell)
        
        if (!tweetDetailsRowThreeCell.isLiked) {
            tweetModified = true
            
            tweetDetailsRowThreeCell.tweet.favorited = true
            tweetDetailsRowThreeCell.tweet.increaseFavCount()

            UIView.animate(withDuration: 0.1, animations: {
                
                tweetDetailsRowThreeCell.likeImageView?.transform = CGAffineTransform(scaleX: 4, y: 4)
                tweetDetailsRowThreeCell.setLikeImage(selected: true)
                
            }, completion: { (finish) in
                
                UIView.animate(withDuration: 0.1, animations: {
                    tweetDetailsRowThreeCell.likeImageView?.transform = CGAffineTransform(scaleX: 1, y: 1)
                })
            })
            
            TwitterClient.sharedInstance.createFavorite(tweet: tweetDetailsRowThreeCell.tweet, success: { (tweet: (Tweet)) in
                
                self.tweet = tweet
                let prevIndexPath = IndexPath.init(row: (cellIndexPath?.row)! - 1, section: (cellIndexPath?.section)!)
                self.tweetDetailsTableView.reloadRows(at: [prevIndexPath], with: .none)
                
            }) { (error: Error) in
                
                tweetDetailsRowThreeCell.setLikeImage(selected: false)
                tweetDetailsRowThreeCell.tweet.favorited = false
                tweetDetailsRowThreeCell.tweet.decreaseFavCount()
                print(error.localizedDescription)
            }
        
        } else {
            
            tweetModified = true

            tweetDetailsRowThreeCell.tweet.favorited = false
            tweetDetailsRowThreeCell.tweet.decreaseFavCount()
            tweetDetailsRowThreeCell.setLikeImage(selected: false)
            
            TwitterClient.sharedInstance.deleteFavorite(tweet: tweetDetailsRowThreeCell.tweet, success: { (tweet: (Tweet)) in
                
                self.tweet = tweet
                let prevIndexPath = IndexPath.init(row: (cellIndexPath?.row)! - 1, section: (cellIndexPath?.section)!)
                self.tweetDetailsTableView.reloadRows(at: [prevIndexPath], with: .none)
                
            }) { (error: Error) in
                
                tweetDetailsRowThreeCell.tweet.favorited = true
                tweetDetailsRowThreeCell.setLikeImage(selected: true)
                tweetDetailsRowThreeCell.tweet.increaseFavCount()
                print(error.localizedDescription)
            }
        }
        tweetDetailsRowThreeCell.isLiked = !tweetDetailsRowThreeCell.isLiked

    }
}

