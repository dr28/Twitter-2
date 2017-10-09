//
//  MenuHeaderCell.swift
//  Twitter
//
//  Created by Deepthy on 10/5/17.
//  Copyright © 2017 Deepthy. All rights reserved.
//

import UIKit

class MenuHeaderCell: UITableViewCell {
    
    @IBOutlet weak var profileImageView: UIImageView!
    
    @IBOutlet weak var nameLabel: UILabel!
    
    @IBOutlet weak var screenLabel: UILabel!
    
    @IBOutlet weak var followingCountLabel: UILabel!
    
    @IBOutlet weak var followerCountLabel: UILabel!
    
    
    var loggedInuser: User! {
        didSet {
            if let profileImageUrl = loggedInuser?.profileImageUrl {
                let largeImageUrl = profileImageUrl.replacingOccurrences(of: "normal", with: "200x200")
                
                if let url = URL(string: largeImageUrl) {
                    profileImageView.setImageWith(url)
                    
                    profileImageView.layer.cornerRadius = (profileImageView.frame.size.width)/2
                    profileImageView.clipsToBounds = true
                }
            }
            
            if let name = loggedInuser.name {
                nameLabel?.text = name
            }
            
            if let screenname = loggedInuser.screenname {
                screenLabel?.text = "@\(screenname)"
            }
            
            if let following = loggedInuser.followingCount {
                followingCountLabel.text = "\(following)"
            }
            
            if let follower = loggedInuser.followersCount {
                followerCountLabel.text = "\(follower)"
            }
        }
    }


    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
