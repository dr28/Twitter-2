//
//  HamburgerViewController.swift
//  Twitter
//
//  Created by Deepthy on 10/3/17.
//  Copyright © 2017 Deepthy. All rights reserved.
//

import UIKit

class HamburgerViewController: UIViewController {
    @IBOutlet weak var menuView: UIView!

    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var leftMarginConstraint: NSLayoutConstraint!
    
    var originalLeftMargin: CGFloat!
    var tapGestureRecognizer: UITapGestureRecognizer?
    var isMenuOpen = false

    var menuViewController: MenuViewController!
    var greyCover: UIView!

    var contentViewController: UIViewController! {
        didSet(oldContentViewController) {
            view.layoutIfNeeded()
            
            if oldContentViewController != nil {
                
                oldContentViewController.willMove(toParentViewController: nil)
                oldContentViewController.view.removeFromSuperview()
                oldContentViewController.didMove(toParentViewController: nil)
            }
            
            contentViewController.willMove(toParentViewController: self)
            contentView.addSubview(contentViewController.view)
            contentViewController.didMove(toParentViewController: self)
            
            self.closeMenu()
        }
    }

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Observer
        NotificationCenter.default.addObserver(self, selector: #selector(didOpenMenu), name: Constants.MenuEventEnum.didOpen.notification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(didCloseMenu), name: Constants.MenuEventEnum.didClose.notification, object: nil)

        menuView.addSubview(menuViewController.view)
        greyCover = UIView.init(frame: self.contentView.frame)
        greyCover.backgroundColor = UIColor(red: (231.0/255.0), green: (236.0/255.0), blue: (240.0/255.0), alpha: 0.7)

        let panGestureRecognizer = UIPanGestureRecognizer()
        panGestureRecognizer.addTarget(self, action: #selector(onPanGesture(_:)))
        self.contentView.addGestureRecognizer(panGestureRecognizer)
        
        tapGestureRecognizer = UITapGestureRecognizer()
        tapGestureRecognizer!.numberOfTapsRequired = 1
        tapGestureRecognizer?.isEnabled = false
        tapGestureRecognizer!.addTarget(self, action: #selector(onTapGesture(_:)))
        
        self.contentView.addGestureRecognizer(tapGestureRecognizer!)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func onPanGesture(_ sender: UIPanGestureRecognizer) {
        
        let translation = sender.translation(in: view)
        let velocity = sender.velocity(in: view)
        
        if sender.state == .began {
            originalLeftMargin = leftMarginConstraint.constant
            
        } else if sender.state == .changed {
            let openingConditions = !isMenuOpen && velocity.x > 0
            let closingConditions = isMenuOpen && velocity.x < 0
            print("openingConditions \(openingConditions)")
            print("closingConditions \(closingConditions)")

            if (openingConditions || closingConditions) {
                leftMarginConstraint.constant = originalLeftMargin + translation.x
            }
            
        } else if sender.state == .ended {
            UIView.animate(withDuration: 0.3, animations: {
                if velocity.x > 0 {
                    self.openMenu()
                } else {
                    self.closeMenu()
                }
            })
            
            
        }
    }
    
    func didOpenMenu() {
        self.openMenu()
    }
    
    func didCloseMenu() {
        self.closeMenu()
    }

    
    func onTapGesture(_ tapGestureRecognizer: UITapGestureRecognizer) {
        if (isMenuOpen) {
            self.closeMenu()
        }
    }
    func openMenu() {
        UIView.animate(withDuration: 0.3, animations: {
            self.leftMarginConstraint.constant = 220
            
            self.contentView.addSubview(self.greyCover)
            
            self.view.layoutIfNeeded() // This has to be insde the animation block in order for animation to work
        })
        self.isMenuOpen = true
        tapGestureRecognizer?.isEnabled = true
        
        
        
    }
    func closeMenu() {
        UIView.animate(withDuration: 0.3, animations: {
            self.leftMarginConstraint.constant = 0
            self.greyCover.removeFromSuperview()

            self.view.layoutIfNeeded()
        })
        self.isMenuOpen = false
        tapGestureRecognizer?.isEnabled = false
    }
    
    
}
