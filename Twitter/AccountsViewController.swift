//
//  AccountsViewController.swift
//  Twitter
//
//  Created by Deepthy on 10/7/17.
//  Copyright © 2017 Deepthy. All rights reserved.
//

import UIKit

class AccountsViewController: UIViewController {

    @IBOutlet weak var accountsTableView: UITableView!
    fileprivate var isSwipe: Bool!
    var user = User.currentUser

    override func viewDidLoad() {
        super.viewDidLoad()

        accountsTableView.delegate = self
        accountsTableView.dataSource = self
        accountsTableView.rowHeight = UITableViewAutomaticDimension
        accountsTableView.estimatedRowHeight = 200
        TwitterClient.sharedInstance.saveAccounts()
        accountsTableView.reloadData()
        
        accountsTableView.tableFooterView = UIView()


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

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated )
    
        accountsTableView.reloadData()

    }

    func onOpenMenu() {
        NotificationCenter.default.post(name: Constants.MenuEventEnum.didOpen.notification, object: nil, userInfo: nil)
    }
    

    func addNewAccount() {
        TwitterClient.sharedInstance.login(success: {_ in }, failure: {_ in })
    }
    
    func onAccSwipeGesture(_ sender: UIPanGestureRecognizer) {
        if isSwipe {
            let cell = sender.view as! AccountsCell
            cell.animateAccountView(sender, removeCell: {
                if let indexPath = self.accountsTableView.indexPath(for: cell) {
                    self.accountsTableView.beginUpdates()
                    TwitterClient.accounts.remove(at: indexPath.row)
                    TwitterClient.sharedInstance.saveAccounts()
                    self.accountsTableView.deleteRows(at: [indexPath], with: UITableViewRowAnimation.right)
                    self.accountsTableView.endUpdates()
                }
            })
        }
    }

}

extension AccountsViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return TwitterClient.accounts.count + 1

    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row < TwitterClient.accounts.count && TwitterClient.accounts.count + 1 != 1 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "AccountsCell", for: indexPath)  as? AccountsCell
            cell?.user = TwitterClient.accounts[indexPath.row].user
            let accSwipeGesture = UIPanGestureRecognizer(target: self, action: #selector(onAccSwipeGesture))
            accSwipeGesture.delegate = self
            cell?.addGestureRecognizer(accSwipeGesture)
            return cell!
        }
        else {
            let cell = UITableViewCell()
            tableView.rowHeight = 100
            let cellView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.width, height: 100))
            cellView.backgroundColor = UIColor.gray
            
            let newAccountBtn = UIButton()
            newAccountBtn.setImage(UIImage.init(named: "plus"), for: .normal)
            newAccountBtn.frame = CGRect(x: 40, y: 60, width: 30, height: 30)
            newAccountBtn.center = CGPoint(x: view.bounds.width / 2.0, y: 100 / 2.0)
            
            newAccountBtn.addTarget(self, action: #selector(addNewAccount), for: .touchUpInside)
            cellView.addSubview(newAccountBtn)
            cell.addSubview(cellView)
            return cell

        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if(indexPath.row != TwitterClient.accounts.count + 1) {
        let cell = tableView.cellForRow(at: indexPath) as! AccountsCell
            
            if TwitterClient.accounts[indexPath.row].user.name == cell.user.name {
                
                if User.currentUser?.name == cell.user.name {
                    let storyboard = UIStoryboard(name: "Main", bundle: nil)
                    
                    let hamburgerViewController = storyboard.instantiateViewController(withIdentifier: "HamburgerViewController") as! HamburgerViewController
                    let menuViewController = storyboard.instantiateViewController(withIdentifier: "MenuViewController") as! MenuViewController
                    
                    hamburgerViewController.menuViewController = menuViewController
                    menuViewController.hamburgerViewController = hamburgerViewController
                    var vc = storyboard.instantiateViewController(withIdentifier: "Homeline") as! UINavigationController
                    
                    hamburgerViewController.contentViewController = vc
                    
                UIApplication.shared.delegate!.window??.rootViewController = hamburgerViewController

                }
                else {
                
                UserDefaults.standard.set(indexPath.row, forKey: "credential")
                User.currentUser?.logout()
                    
                TwitterClient.sharedInstance.login(success: {user in
                    
                    if user != nil {
                        
                        let storyboard = UIStoryboard(name: "Main", bundle: nil)
                        
                        let hamburgerViewController = storyboard.instantiateViewController(withIdentifier: "HamburgerViewController") as! HamburgerViewController
                        let menuViewController = storyboard.instantiateViewController(withIdentifier: "MenuViewController") as! MenuViewController
                        
                        hamburgerViewController.menuViewController = menuViewController
                        menuViewController.hamburgerViewController = hamburgerViewController
                        let homeNavigationController = storyboard.instantiateViewController(withIdentifier: "Homeline") as! UINavigationController
                        hamburgerViewController.contentViewController = homeNavigationController
                        
                    } else {
                        print("Login failure with error")
                    }
                    
                    
                }) { (error: Error) in
                    print("error: \(error)")
                }
                }
            }
        }
    }
}

extension AccountsViewController: UIGestureRecognizerDelegate {
    
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        
        guard let swipeRecognizer = gestureRecognizer as? UIPanGestureRecognizer else {
            return false
        }
        
        let velocity = swipeRecognizer.velocity(in: self.view)
        isSwipe = abs(velocity.x) > abs(velocity.y)
        return true
        
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true

    }
    
}
