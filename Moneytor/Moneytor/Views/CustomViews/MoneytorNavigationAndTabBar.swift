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
       // UINavigationBar.appearance().backgroundColor = UIColor.yellow
        UINavigationBar.appearance().titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.mtTextDarkBrown]
        UINavigationBar.appearance().titleTextAttributes = [NSAttributedString.Key.font: UIFont(name: FontNames.textMoneytorMoneyFont, size: 25)!]
//        UITabBar.appearance().barTintColor = UIColor(hexaRGB: "#E0AB5B")
//        UITabBar.appearance().tintColor = UIColor(hexaRGB: "#2C2212")
//        UITabBar.appearance().backgroundColor = UIColor.yellow
    }
    
//    func setUpTextTitle() {
//        let currentTextTitle = self.title
//        self.ap
//    }
}

class MoneytorTabBarController: UITabBarController {
    override func awakeFromNib() {
        super.awakeFromNib()
        setupTapBar()
    }
    
    func setupTapBar(){
        UINavigationBar.appearance().barTintColor = .mtBgBrownHeader
        UINavigationBar.appearance().tintColor = .mtTextDarkBrown
       // UINavigationBar.appearance().backgroundColor = UIColor.yellow
        //UITab.appearance().titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.textDarkBrown]
        UINavigationBar.appearance().titleTextAttributes = [NSAttributedString.Key.font: UIFont(name: FontNames.textMoneytorGoodLetter, size: 25)!]
     UITabBar.appearance().barTintColor = .mtBgBrownHeader
   UITabBar.appearance().tintColor = .mtTextDarkBrown

    }
    
//    func setUpTextTitle() {
//        let currentTextTitle = self.title
//        self.ap
//    }
}

//extension UIView: UIViewController {
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        
//        self.view.backgroundColor = UIColor.redColor()
//    }
//}
