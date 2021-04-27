//
//  StyleGuide.swift
//  Moneytor
//
//  Created by Lee McCormick on 2/22/21.
//

import UIKit

struct FontNames {
    static let textTitleBoldMoneytor = "Champagne & Limousines Bold"
    static let textMoneytor = "Champagne & Limousines"
    static let textMoneytorBoldItatic = "Champagne & Limousines Bold Italic"
    static let textMoneytorItalic = "Champagne & Limousines Italic"
    static let textMoneytorMoneyFont = "Money Money Plus"
    static let textMoneytorGoodLetter = "Letters for Learners"
}

extension UIColor {
    static let mtBgBrownHeader = UIColor(named: "mtBrownHearder")!
    static let mtTextDarkBrown = UIColor(named: "mtDarkBrownText")!
    static let mtTextLightBrown = UIColor(named: "mtLightBrownText")!
    static let mtBgGolder = UIColor(named: "mtGolderBG")!
    static let mtBgDarkGolder = UIColor(named: "mtDarkGolder")!
    static let mtWhiteText = UIColor(named: "mtWhiteText")!
    static let mtLightYellow = UIColor(named: "mtLightYellow")!
    static let mtDarkYellow = UIColor(named: "mtDarkYellow")!
    static let mtDarkOrage = UIColor(named: "mtDarkOrage")!
    static let mtDarkBlue = UIColor(named: "mtDarkBlue")!
    static let mtGreen = UIColor(named: "mtGreen")!
}

extension UIView {
    func addCornerRadius(radius: CGFloat = 6) {
        self.layer.cornerRadius = radius
    }
    
    func rotate(by radians: CGFloat = -CGFloat.pi / 2) {
        self.transform = CGAffineTransform(rotationAngle: radians)
    }
}
