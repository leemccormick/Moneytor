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
        self.addCornerRadius()
        self.searchTextField.textColor = .mtTextLightBrown
        self.backgroundColor = .mtLightYellow
        self.layer.borderWidth = 2.5
        self.layer.borderColor = UIColor.mtLightYellow.cgColor
        self.layer.masksToBounds = true
        self.showsCancelButton = true
        self.showsSearchResultsButton = true
        self.tintColor = .mtTextDarkBrown
    }
}
