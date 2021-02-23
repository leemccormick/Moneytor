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
        // update the font
        updateFont(fontName: FontNames.textMoneytor)
        // set the text color
        self.textColor = .mtTextDarkBrown
    }
    func updateFont(fontName: String) {
        let size = self.font.pointSize
        self.font = UIFont(name: fontName, size: size)
    }
}

class MoneytorGoodLetterLabel: MoneytorLabel {
    override func awakeFromNib() {
        super.awakeFromNib() //.awakeFromNib() from HypeLabel
       // super.updateFont(fontName: FontNames.latoBold)
        updateFont(fontName: FontNames.textMoneytorGoodLetter)
    }
}

class MoneytorTitleFontWhiteLabel: UILabel {
    override  func awakeFromNib() {
        super.awakeFromNib()
        // update the font
        updateFont(fontName: FontNames.textMoneytorMoneyFont)
        // set the text color
        self.textColor = .mtWhiteText
    }
    func updateFont(fontName: String) {
        let size = self.font.pointSize
        self.font = UIFont(name: fontName, size: size)
    }
}


