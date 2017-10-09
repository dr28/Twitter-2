//
//  ManageCredentials.swift
//  Twitter
//
//  Created by Deepthy on 10/8/17.
//  Copyright © 2017 Deepthy. All rights reserved.
//

import UIKit

class ManageCredentials: NSObject {
    
    
    static let twitterBaseURL = URL(string: "https://api.twitter.com")
    static let keysArray = ["uVadfW5NmZxMHEAU1UL312bnO","YX8Nj862GVLLClccjgQBB3mqV"]
    static let secretsArray = ["IbgCPDYnz6JKLb6TVkrKZNc7cQ806k5NRIuDOICXZUmuVxbcYI", "OlyG9eSgjkLmzNPjZZpQK24xfXJewqZXhUYU5DQpi46TsjYcGq"]
    
   /* class func getBaseURL() -> URL {
        return twitterBaseURL!
    }*/
    
    class func getKey() -> String {
        
        let index = UserDefaults.standard.integer(forKey: "credential") ?? 0
        print(index)
        
        if index == 0 {
            return keysArray[0]
        }
        return keysArray[index - 1]
    }
    
    class func getSecret() -> String {
        
        let index = UserDefaults.standard.integer(forKey: "credential") ?? 0
        
        if index == 0 {
            return secretsArray[0]
        }
        return secretsArray[index - 1]
    }
}
