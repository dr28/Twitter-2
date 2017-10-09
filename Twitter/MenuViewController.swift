//
//  MenuViewController.swift
//  Twitter
//
//  Created by Deepthy on 10/4/17.
//  Copyright © 2017 Deepthy. All rights reserved.
//

import UIKit

class MenuViewController: UIViewController {
    

    @IBOutlet weak var nightThemeImage: UIImageView!
    @IBOutlet weak var menuTableView: UITableView!
    fileprivate var homeNavigationController: UINavigationController!
    var hamburgerViewController: HamburgerViewController!
    var user = User.currentUser
    let menuSections = ["", "Timeline", "Profile", "Mentions", "Accounts", "Log Out"]

    override func viewDidLoad() {
        super.viewDidLoad()

        let storyboard = UIStoryboard(name: "Main", bundle: nil)

        homeNavigationController = storyboard.instantiateViewController(withIdentifier: "Homeline") as! UINavigationController
        let homeTweetsViewController = homeNavigationController.topViewController as? TweetsViewController
        
        menuTableView.rowHeight = UITableViewAutomaticDimension
        menuTableView.estimatedRowHeight = 300
        menuTableView.tableFooterView = UIView()
        menuTableView.separatorStyle = .none
        
        let themeImageTap = UITapGestureRecognizer(target: self, action: #selector(themeTapped))
        themeImageTap.numberOfTapsRequired = 1
        nightThemeImage?.isUserInteractionEnabled = true
        nightThemeImage?.addGestureRecognizer(themeImageTap)

              }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        var selectedThemeValue   = (UserDefaults.standard.value(forKey: "SelectedTheme") as! AnyObject).integerValue ?? 0
        
        if(selectedThemeValue != 0) {
            nightThemeImage?.image = UIImage(named: "moonfilled")
            
        }
        else {
            
            nightThemeImage?.image = UIImage(named: "moon")
            
            
        }
        self.view.backgroundColor = ThemeManager.currentTheme().backgroundColor


    }
    
    var defaults = UserDefaults.standard
    
    @IBAction func themeTapped(_ sender: Any) {
        var selectedThemeValue = (UserDefaults.standard.value(forKey: "SelectedTheme")! as AnyObject).integerValue ?? 0

        if(selectedThemeValue != 0) {
            selectedThemeValue = selectedThemeValue - 1
            nightThemeImage?.image = UIImage(named: "moonfilled")

        }
        else {

            selectedThemeValue = selectedThemeValue + 1
            nightThemeImage?.image = UIImage(named: "moon")
        }

        defaults.set(selectedThemeValue, forKey: "SelectedTheme")
        defaults.synchronize()
        ThemeManager.applyTheme(theme: ThemeManager.currentTheme())
        
        for subview in self.view.subviews{
            subview.setNeedsDisplay()
        }

        self.viewWillAppear(true)
    }
}

extension MenuViewController: UITableViewDelegate, UITableViewDataSource {
    

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 50
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView()
        return headerView
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return menuSections.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        switch indexPath.row {
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: "MenuHeaderCell", for: indexPath) as! MenuHeaderCell
            cell.loggedInuser = user
            cell.selectionStyle = .none

            return cell
        case 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: "MenuCell", for: indexPath) as! MenuCell
            cell.selectionStyle = .none

            cell.setMenu(menuText: menuSections[indexPath.row], menuImageName: "home")
            return cell
        case 2:
            let cell = tableView.dequeueReusableCell(withIdentifier: "MenuCell", for: indexPath) as! MenuCell
            cell.selectionStyle = .none

            cell.setMenu(menuText: menuSections[indexPath.row], menuImageName: "profile")
            return cell
        case 3:
            let cell = tableView.dequeueReusableCell(withIdentifier: "MenuCell", for: indexPath) as! MenuCell
            cell.selectionStyle = .none

            cell.setMenu(menuText: menuSections[indexPath.row], menuImageName: "mention")
            return cell
        case 4:
            let cell = tableView.dequeueReusableCell(withIdentifier: "MenuCell", for: indexPath) as! MenuCell
            cell.selectionStyle = .none
            
            cell.setMenu(menuText: menuSections[indexPath.row], menuImageName: "accounts")
            return cell
        case 5:
            let cell = tableView.dequeueReusableCell(withIdentifier: "MenuCell", for: indexPath) as! MenuCell
            cell.selectionStyle = .none
            
            cell.setMenu(menuText: menuSections[indexPath.row], menuImageName: "logout-white")
            return cell
            
        default:
            return UITableViewCell()

        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        switch indexPath.row {
        case 1:
            homeNavigationController = storyboard?.instantiateViewController(withIdentifier: "Homeline") as! UINavigationController

            hamburgerViewController.contentViewController = homeNavigationController
            let homeTweetsViewController = homeNavigationController.topViewController as? TweetsViewController
            homeTweetsViewController?.timeline = nil
           
            break
        case 2:
            
            homeNavigationController = storyboard?.instantiateViewController(withIdentifier: "Profile") as! UINavigationController
            let profileViewController = homeNavigationController.topViewController as? ProfileViewController
            profileViewController?.user = User.currentUser
            hamburgerViewController.contentViewController = homeNavigationController
        
            break
        case 3:
            homeNavigationController = storyboard?.instantiateViewController(withIdentifier: "Homeline") as! UINavigationController

            let homeTweetsViewController = homeNavigationController.topViewController as? TweetsViewController
            homeTweetsViewController?.timeline = "mentions"
            
            hamburgerViewController.contentViewController = homeNavigationController
            break
        case 4:
            homeNavigationController = storyboard?.instantiateViewController(withIdentifier: "Accounts") as! UINavigationController
            
            let accountsViewController = homeNavigationController.topViewController as? AccountsViewController
            
            hamburgerViewController.contentViewController = homeNavigationController
            
            break
        case 5:
            User.currentUser?.logout()
            
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let loginViewController = storyboard.instantiateViewController(withIdentifier: "login")
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            appDelegate.window?.rootViewController = loginViewController

            break

        default:
            break
        }
    }
}
