//
//  MenuCell.swift
//  Twitter
//
//  Created by Deepthy on 10/4/17.
//  Copyright © 2017 Deepthy. All rights reserved.
//

import UIKit

class MenuCell: UITableViewCell {
    
    @IBOutlet weak var menuImageView: UIImageView!
    
    @IBOutlet weak var menuLabel: UILabel!
    
    func setMenu(menuText: String, menuImageName: String) {
        if  menuImageName != "accounts" {
           let  menuImageName = UIImageView.init(image: UIImage(named: menuImageName)?.withRenderingMode(UIImageRenderingMode.alwaysTemplate))
            
            UIImageView.appearance().tintColor = UIColor(red: 156.0/255.0, green: 156.0/255.0, blue: 156.0/255.0, alpha: 1.0)
            menuImageView.image = menuImageName.image

        }
        
        
        menuLabel.text = menuText
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
