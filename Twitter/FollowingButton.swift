//
//  FollowingButton.swift
//  Twitter
//
//  Created by Deepthy on 10/6/17.
//  Copyright © 2017 Deepthy. All rights reserved.
//

import UIKit

class FollowingButton: UIButton {
    
    var isFollowing: Bool?
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        self.layer.cornerRadius = 5
        self.layer.masksToBounds = true
        
        self.layer.borderWidth = 1
    }
    
    func setUpFollowingAppearance() {
        isFollowing = true
        UIView.animate(withDuration: 0.1, animations: {
            self.setTitle("Following", for: .normal)
            self.setTitleColor(UIColor.white, for: .normal)
        })
    }
    
    func setUpToFollowAppearance() {
        isFollowing = false
        UIView.animate(withDuration: 0.1, animations: {
            self.setTitle("Follow", for: .normal)
            self.backgroundColor = UIColor.white
        })
    }
}
