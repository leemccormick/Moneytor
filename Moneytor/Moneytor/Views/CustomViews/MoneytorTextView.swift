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
        self.textColor = .mtTextLightBrown
        self.backgroundColor = .mtLightYellow
        self.layer.borderWidth = 1.0
        self.layer.borderColor = UIColor.mtDarkOrage.cgColor
        self.layer.masksToBounds = true
    }
    
    func updateFont(){
        self.font = UIFont(name: FontNames.textTitleBoldMoneytor, size: 14)
    }
}
