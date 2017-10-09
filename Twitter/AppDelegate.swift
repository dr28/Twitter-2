//
//  AppDelegate.swift
//  Twitter
//
//  Created by Deepthy on 9/26/17.
//  Copyright © 2017 Deepthy. All rights reserved.
//

import UIKit
import BDBOAuth1Manager

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var storyboard = UIStoryboard(name: "Main", bundle: nil)


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {

        let theme = ThemeManager.currentTheme()
        ThemeManager.applyTheme(theme: theme)
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "userDidLogoutNotification"), object: nil)

        NotificationCenter.default.addObserver(self, selector: #selector(userDidLogOut), name: NSNotification.Name(rawValue: "userDidLogoutNotification"), object: nil)
        
        if User.currentUser != nil  {
            TwitterClient.sharedInstance.hasAccounts()

            //print("cureent user \(TwitterClient.currentAccount.user.name)")
            let hamburgerViewController = storyboard.instantiateViewController(withIdentifier: "HamburgerViewController") as! HamburgerViewController
            let menuViewController = storyboard.instantiateViewController(withIdentifier: "MenuViewController") as! MenuViewController
           
            hamburgerViewController.menuViewController = menuViewController
            menuViewController.hamburgerViewController = hamburgerViewController
            
            var vc = storyboard.instantiateViewController(withIdentifier: "Homeline") as! UINavigationController
            //var vc = storyboard.instantiateViewController(withIdentifier: "tabbar") as! UITabBarController
            //vc.user = User.currentUser
            hamburgerViewController.contentViewController = vc

            window?.rootViewController = hamburgerViewController

        }

        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {
    
        if url.description.contains("denied") {
            let deniedAlert = UIAlertController(title: "Access Denied", message: "Failed to authenticate with Twitter", preferredStyle: .alert)
            deniedAlert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
            UIApplication.shared.keyWindow?.rootViewController?.present(deniedAlert, animated: true, completion: nil)
        } else {
            UserDefaults.standard.removePersistentDomain(forName: Bundle.main.bundleIdentifier!)
            UserDefaults.standard.synchronize()
        
           TwitterClient.sharedInstance.handleOpenUrl(url: url)
        }
        
        return true
    }
    
    func userDidLogOut() {
        UIView.animate(withDuration: 0.7, animations: {
            let vc = self.storyboard.instantiateInitialViewController()
            self.window?.rootViewController = vc
        })
    }
}

