//
//  MoneytorButton.swift
//  Moneytor
//
//  Created by Lee McCormick on 2/22/21.
//

import UIKit

class MoneytorButton: UIButton {
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupView()
    }
    
    func setupView() {
        self.backgroundColor = .mtBgBrownHeader
        self.setTitleColor(.mtWhiteText, for: .normal)
        self.addCornerRadius()
        self.titleLabel?.font = UIFont(name: FontNames.textTitleBoldMoneytor, size: 22)
    }
}

class MoneytorTotalButton: UIButton {
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupView()
    }
    
    func setupView() {
        self.setTitleColor(.mtTextDarkBrown, for: .normal)
        self.addCornerRadius() 
        self.titleLabel?.font = UIFont(name: FontNames.textMoneytorGoodLetter, size: 25)
    }
}
