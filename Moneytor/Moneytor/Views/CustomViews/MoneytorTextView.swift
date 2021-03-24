//
//  MoneytorTextView.swift
//  Moneytor
//
//  Created by Lee McCormick on 3/24/21.
//

import UIKit

class MoneytorTextView: UITextView {
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupView()
        updateFont()
    }
    
    func setupView() {
        self.addCornerRadius()
        //setupPlaceholderText()
        self.textColor = .mtTextLightBrown
        self.backgroundColor = .mtDarkOrage
        self.layer.borderWidth = 2.5
        self.layer.borderColor = UIColor.mtLightYellow.cgColor
        self.layer.masksToBounds = true
    }
    
    func updateFont(){
        self.font = UIFont(name: FontNames.textTitleBoldMoneytor, size: 14)
    }
}
