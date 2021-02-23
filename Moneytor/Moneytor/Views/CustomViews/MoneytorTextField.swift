//
//  MoneytorTextField.swift
//  Moneytor
//
//  Created by Lee McCormick on 2/22/21.
//

import UIKit

class MoneytorTextField: UITextField {
    
    // awakeFromNib() ===> once the HypeTextField load in the memory then go setupView()
    override func awakeFromNib() {
        super.awakeFromNib()
        setupView()
        updateFont()
    }
    
    func setupView() {
        self.addCornerRadius()
        setupPlaceholderText()
        self.textColor = .mtTextDarkBrown
        self.backgroundColor = .mtLightYellow
        self.layer.masksToBounds = true //Add masksToBounds to invisible to the past we don't need to see.
        
    }
    
    func setupPlaceholderText() {
        let currentPlaceholder = self.placeholder ?? "" //?? because placeholder is an optional
        self.attributedPlaceholder = NSAttributedString(string: currentPlaceholder, attributes: [
            NSAttributedString.Key.foregroundColor : UIColor.mtTextLightBrown,
            NSAttributedString.Key.font : UIFont(name: FontNames.textMoneytor, size: 16)!
        ])
    }
    
    func updateFont(){
        guard let size = self.font?.pointSize else {return} //Get the size that already exist in the textFiled
        self.font = UIFont(name: FontNames.textMoneytor, size: size)
    }
}
