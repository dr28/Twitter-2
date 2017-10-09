//
//  Theme.swift
//  Twitter
//
//  Created by Deepthy on 10/1/17.
//  Copyright © 2017 Deepthy. All rights reserved.
//

import UIKit
let SelectedThemeKey = "SelectedTheme"

enum Theme: Int {
    case Default, Dark
    
    var mainColor: UIColor {
        switch self {
        case .Default:
            return UIColor.black
                
                UIColor(red: 29/255, green: 161/255, blue: 242/255, alpha: 1)// blue
            
        case .Dark:
            return UIColor.white
            
        }
    }
    
    var backgroundColor: UIColor {
        switch self {
        case .Default:
            return UIColor.white
            
        case .Dark:
            return UIColor(red: 27/255, green: 41/255, blue: 52/255, alpha: 1)// Navy blue
        }
    }
    
    var secondaryColor: UIColor {
        switch self {
        case .Default:
            return UIColor(red: 156.0/255.0, green: 156.0/255.0, blue: 156.0/255.0, alpha: 1.0)
            
        case .Dark:
            return UIColor()
        }
    }
    
    var secondaryBackgroundColor: UIColor {
        switch self {
        case .Default:
            return UIColor(red: 240/255.0, green: 240/255.0, blue: 240/255.0, alpha: 1.0)
            
        case .Dark:
            return UIColor()
        }
    }
    
    var barStyle: UIBarStyle {
        switch self {
        case .Default:
            return .default
        case .Dark:
            return .default
        }
    }
    
    
}

struct ThemeManager {
    
    static func currentTheme() -> Theme {
        var storedTheme = 0
        
        if (UserDefaults.standard.value(forKey: SelectedThemeKey) != nil)
        {
            storedTheme = (UserDefaults.standard.value(forKey: SelectedThemeKey)! as AnyObject).integerValue
            print("storedTheme \(storedTheme)")
        }
        
        return Theme(rawValue: storedTheme)!
        
    }
    
    static func applyTheme(theme: Theme) {
        UserDefaults.standard.setValue(theme.rawValue, forKey: SelectedThemeKey)
        UserDefaults.standard.synchronize()
        
        let sharedApplication = UIApplication.shared
        sharedApplication.delegate?.window??.tintColor = theme.mainColor
        sharedApplication.delegate?.window??.backgroundColor = theme.backgroundColor
        //UILabel.appearance().textColor = theme.mainColor
        
        UINavigationBar.appearance().barStyle = theme.barStyle


        //UINavigationBar.appearance().barTintColor = UIColor(red: 212/255, green: 32/255, blue: 43/255, alpha: 1.0)
        UINavigationBar.appearance().tintColor = UIColor(red: 29/255, green: 161/255, blue: 242/255, alpha: 1)

        
    }
}
