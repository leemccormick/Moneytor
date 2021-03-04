//
//  MoneytorNavigationAndTabBar.swift
//  Moneytor
//
//  Created by Lee McCormick on 2/22/21.
//

import UIKit

class MoneytorNavigationController: UINavigationController {
    override func awakeFromNib() {
        super.awakeFromNib()
        setupNavigationBar()
    }
    
    func setupNavigationBar(){
        UINavigationBar.appearance().barTintColor = .mtBgBrownHeader
        UINavigationBar.appearance().tintColor = .mtTextDarkBrown
        UINavigationBar.appearance().titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.mtTextDarkBrown]
        UINavigationBar.appearance().titleTextAttributes = [NSAttributedString.Key.font: UIFont(name: FontNames.textMoneytorMoneyFont, size: 25)!]
    }
}

class MoneytorTabBarController: UITabBarController {
    override func awakeFromNib() {
        super.awakeFromNib()
        setupTapBar()
    }
    
    func setupTapBar(){
        UINavigationBar.appearance().barTintColor = .mtBgBrownHeader
        UINavigationBar.appearance().tintColor = .mtTextDarkBrown
        UINavigationBar.appearance().titleTextAttributes = [NSAttributedString.Key.font: UIFont(name: FontNames.textMoneytorGoodLetter, size: 25)!]
     UITabBar.appearance().barTintColor = .mtBgBrownHeader
   UITabBar.appearance().tintColor = .mtTextDarkBrown

    }
}
