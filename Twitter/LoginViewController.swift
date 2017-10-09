//
//  LoginViewController.swift
//  Twitter
//
//  Created by Deepthy on 9/26/17.
//  Copyright © 2017 Deepthy. All rights reserved.
//

import UIKit
import BDBOAuth1Manager


class LoginViewController: UIViewController {

    @IBOutlet weak var loginButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loginButton.layer.cornerRadius = loginButton.frame.height / 2
        
    }

    
    @IBAction func onLoginButton(_ sender: Any) {
        print("onLoginButton ")

        TwitterClient.sharedInstance.login(success: {user in
            
            if user != nil {
                
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                
                let hamburgerViewController = storyboard.instantiateViewController(withIdentifier: "HamburgerViewController") as! HamburgerViewController
                let menuViewController = storyboard.instantiateViewController(withIdentifier: "MenuViewController") as! MenuViewController
                
                hamburgerViewController.menuViewController = menuViewController
                menuViewController.hamburgerViewController = hamburgerViewController
                
                self.present(hamburgerViewController, animated: true, completion: nil)
                
            } else {
                print("Login failure with error")
            }
            
        }) { (error: Error) in
            print("error: \(error)")
        }
    }
    
}
