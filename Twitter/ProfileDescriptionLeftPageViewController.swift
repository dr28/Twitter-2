//
//  ProfileDescriptionLeftPageViewController.swift
//  Twitter
//
//  Created by Deepthy on 10/7/17.
//  Copyright © 2017 Deepthy. All rights reserved.
//

import UIKit

class ProfileDescriptionLeftPageViewController: UIViewController {

    @IBOutlet weak var screennameLabel: UILabel!
    @IBOutlet weak var tweetsLabel: UILabel!
    @IBOutlet weak var followingLabel: UILabel!
    @IBOutlet weak var followersLabel: UILabel!
    @IBOutlet weak var tweetsCountLabel: UILabel!
    @IBOutlet weak var followingCountLabel: UILabel!
    @IBOutlet weak var followersCountLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!

    var user: User?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.showUserInfo), name: NSNotification.Name(rawValue: "profileUser"), object: nil)
    }
    
    func showUserInfo(_ notification: NSNotification) {

        if let usr = notification.userInfo?["user"] as? User {
            
            self.user = usr
        }
        nameLabel.text = user?.name
        nameLabel.textColor = UIColor.black
        
        screennameLabel.text = "@\((user?.screenname)!)"
        
        tweetsCountLabel.text = Constants.getFriendlyCounts(count: (user?.tweetsCount!)!)
        followingCountLabel.text = Constants.getFriendlyCounts(count: (user?.followingCount!)!)
        followersCountLabel.text = Constants.getFriendlyCounts(count: (user?.followersCount!)!)
    }

    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        nameLabel.text = user?.name
        nameLabel.textColor = UIColor.black
    }
}
