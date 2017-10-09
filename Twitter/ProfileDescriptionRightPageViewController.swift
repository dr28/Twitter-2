//
//  ProfileDescriptionRightPageViewController.swift
//  Twitter
//
//  Created by Deepthy on 10/7/17.
//  Copyright © 2017 Deepthy. All rights reserved.
//

import UIKit

class ProfileDescriptionRightPageViewController: UIViewController {

    
    @IBOutlet weak var userDescriptionLabel: UILabel!
    var user: User?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.showUserRightInfo), name: NSNotification.Name(rawValue: "profileUser"), object: nil)

    }
    
    func showUserRightInfo(_ notification: NSNotification) {
        if let usr = notification.userInfo?["user"] as? User {
            self.user = usr
        }
        userDescriptionLabel.text = (user?.userDescription)!
    }
    
}
