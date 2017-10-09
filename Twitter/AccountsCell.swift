//
//  AccountsCell.swift
//  Twitter
//
//  Created by Deepthy on 10/6/17.
//  Copyright © 2017 Deepthy. All rights reserved.
//

import UIKit

class AccountsCell: UITableViewCell {
    @IBOutlet weak var accountView: UIView!

    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    
    @IBOutlet weak var screenNameLabel: UILabel!
    
    private var originalAlpha: CGFloat!
    private var originalScale: CGFloat!
    private var originalPositionX: CGFloat!
    
    var user:User! {
        didSet {
            if let normalImageUrl = user.profileImageUrl {
                
                let largeImageUrl = normalImageUrl.replacingOccurrences(of: "normal", with: "200x200")
                
                if let url = URL(string: largeImageUrl) {
                    
                    profileImageView?.setImageWith(url)
                    profileImageView.layer.cornerRadius = 5.0
                    profileImageView.layer.masksToBounds = true
                }
            }
            nameLabel.text = user.name
            screenNameLabel.text = "@\(user.screenname!)"
            
            accountView.frame.origin.x = 0
            accountView.transform = CGAffineTransform(scaleX: 1, y: 1)
            accountView.alpha = 1
        }
    }
    
    func animateAccountView(_ sender: UIPanGestureRecognizer, removeCell: @escaping ()->() ) {
        let translation = sender.translation(in: contentView).x
        let velocity = sender.velocity(in: contentView).x
        
        if sender.state == .began {
            originalAlpha = accountView.alpha
            originalScale = accountView.transform.tx
            originalPositionX = accountView.frame.origin.x
            
        } else if sender.state == UIGestureRecognizerState.changed {
            if originalPositionX + translation > 0 {
                accountView.frame.origin.x = originalPositionX + translation
                accountView.transform = CGAffineTransform(scaleX: (500 - translation)/500, y: (500 - translation)/500)
                accountView.alpha = (500 - translation)/500
            }
        } else if sender.state == .ended {
            UIView.animate(withDuration: 0.5, animations: {
                if abs(self.accountView.frame.origin.x - self.originalPositionX) > 70 {
                    if velocity > 0 { //finish Auto-removing accoutn
                        self.accountView.frame.origin.x = self.accountView.frame.width
                        self.accountView.transform = CGAffineTransform(scaleX: 2/5, y: 2/5)
                        self.accountView.alpha = 0.7
                        removeCell()
                    } else {            //cancel removing account
                        self.accountView.frame.origin.x = 0
                        self.accountView.transform = CGAffineTransform(scaleX: 1, y: 1)
                        self.accountView.alpha = 1
                    }
                } else { //failed removing account
                    self.accountView.frame.origin.x = 0
                    self.accountView.transform = CGAffineTransform(scaleX: 1, y: 1)
                    self.accountView.alpha = 1
                }
            })
        }
    }


    
}
