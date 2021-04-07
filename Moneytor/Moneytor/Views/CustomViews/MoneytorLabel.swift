//
//  MoneytorLabel.swift
//  Moneytor
//
//  Created by Lee McCormick on 2/22/21.
//

import UIKit

class MoneytorLabel: UILabel {
    override  func awakeFromNib() {
        super.awakeFromNib()
        updateFont(fontName: FontNames.textMoneytor)
        self.textColor = .mtTextDarkBrown
    }
    func updateFont(fontName: String) {
        let size = self.font.pointSize
        self.font = UIFont(name: fontName, size: size)
    }
}

class MoneytorGoodLetterLabel: UILabel {
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.textColor = .mtTextLightBrown 
        self.font = UIFont(name: FontNames.textMoneytorGoodLetter, size: 25)
    }
}

class MoneytorTitleFontWhiteLabel: UILabel {
    override  func awakeFromNib() {
        super.awakeFromNib()
        updateFont(fontName: FontNames.textMoneytorMoneyFont)
        self.textColor = .mtWhiteText
    }
    func updateFont(fontName: String) {
        let size = self.font.pointSize
        self.font = UIFont(name: fontName, size: size)
    }
}

class MoneytorTitleFontBrownLabel: UILabel {
    override  func awakeFromNib() {
        super.awakeFromNib()
        let size = self.font.pointSize
        self.font = UIFont(name: FontNames.textMoneytorMoneyFont, size: size)
        self.textColor = .mtTextDarkBrown
    }
    
}

class MoneytorHeaderSectionLabel: UILabel {
    override  func awakeFromNib() {
        super.awakeFromNib()
        self.font = UIFont(name: FontNames.textTitleBoldMoneytor, size: 20)
        self.textColor = .mtTextLightBrown
    }
}

class MoneytorGoodLetterForDateLabel: UILabel {
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.textColor = .mtTextLightBrown
        self.font = UIFont(name: FontNames.textMoneytorGoodLetter, size: 18)
    }
}
