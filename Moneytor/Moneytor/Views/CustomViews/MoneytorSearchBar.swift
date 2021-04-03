//
//  MoneytorSearchBar.swift
//  Moneytor
//
//  Created by Lee McCormick on 2/26/21.
//

import UIKit

class MoneytorSearchBar: UISearchBar {
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupView()
    }
    
    func setupView() {
        let titleFont : UIFont = UIFont(name: FontNames.textMoneytorGoodLetter, size: 18)!
               let attributes = [
                NSAttributedString.Key.foregroundColor : UIColor.mtTextLightBrown,
                   NSAttributedString.Key.font : titleFont
               ]
        self.addCornerRadius()
        self.searchTextField.textColor = .mtTextLightBrown
        self.backgroundColor = .mtLightYellow
        self.layer.borderWidth = 2.5
        self.layer.borderColor = UIColor.mtLightYellow.cgColor
        self.layer.masksToBounds = true
        self.showsCancelButton = true
       // self.barTintColor = .mtDarkYellow
       // self.showsSearchResultsButton = true
        self.tintColor = .mtTextDarkBrown
        self.searchTextField.font = UIFont(name: FontNames.textMoneytorGoodLetter, size: 20)!
        self.scopeBarButtonTitleTextAttributes(for: .highlighted)
        self.setScopeBarButtonTitleTextAttributes(attributes, for: .normal)
        //self.setScopeBarButtonBackgroundImage(<#T##backgroundImage: UIImage?##UIImage?#>, for: <#T##UIControl.State#>)
        //self.searchS
//        //scopeBarBackgroundImage = .
//        self.isSearchResultsButtonSelected = true
        UISegmentedControl.appearance().backgroundColor = .mtDarkYellow
        UISegmentedControl.appearance().selectedSegmentTintColor = .mtLightYellow
        UISegmentedControl.appearance().selectedSegmentIndex = 1
        UISegmentedControl.appearance().setTitleTextAttributes(attributes, for: .normal)
        UISegmentedControl.appearance().layer.borderWidth = 2.5
        UISegmentedControl.appearance().layer.borderColor = UIColor.mtLightYellow.cgColor
        UISegmentedControl.appearance().setTitleTextAttributes([.foregroundColor : UIColor.mtTextLightBrown], for: .selected)
        UISegmentedControl.appearance().addCornerRadius()
    }
    
    
}
