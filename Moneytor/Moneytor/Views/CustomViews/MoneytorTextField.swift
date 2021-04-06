//
//  MoneytorTextField.swift
//  Moneytor
//
//  Created by Lee McCormick on 2/22/21.
//

import UIKit

class MoneytorTextField: UITextField {
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupView()
        updateFont()
    }
    
    func setupView() {
        self.addCornerRadius()
        setupPlaceholderText()
        self.textColor = .mtTextLightBrown
        self.backgroundColor = .mtLightYellow
        self.layer.borderWidth = 1.0
        self.layer.borderColor = UIColor.mtDarkOrage.cgColor
        self.layer.masksToBounds = true
    }
    
    func setupPlaceholderText() {
        let currentPlaceholder = self.placeholder ?? ""
        self.attributedPlaceholder = NSAttributedString(string: currentPlaceholder, attributes: [
            NSAttributedString.Key.foregroundColor : UIColor.lightGray,
            NSAttributedString.Key.font : UIFont(name: FontNames.textTitleBoldMoneytor, size: 15)!
        ])
    }
    
    func updateFont(){
        self.font = UIFont(name: FontNames.textTitleBoldMoneytor, size: 18)
    }
}
