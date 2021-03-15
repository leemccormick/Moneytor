//
//  MoneytorSegmentedControl.swift
//  Moneytor
//
//  Created by Lee McCormick on 3/9/21.
//

import UIKit

class MoneytorSegment: UISegmentedControl {
    override  func awakeFromNib() {
        super.awakeFromNib()
        setupView()
    }

    func setupView() {
        
        let titleFont : UIFont = UIFont(name: FontNames.textMoneytorGoodLetter, size: 18)!
               let attributes = [
                NSAttributedString.Key.foregroundColor : UIColor.mtTextLightBrown,
                   NSAttributedString.Key.font : titleFont
               ]
        self.backgroundColor = .mtDarkYellow
        self.selectedSegmentTintColor = .mtLightYellow
        self.selectedSegmentIndex = 1
        self.setTitleTextAttributes(attributes, for: .normal)
        self.layer.borderWidth = 2.5
        self.layer.borderColor = UIColor.mtLightYellow.cgColor
        self.setTitleTextAttributes([.foregroundColor : UIColor.mtTextLightBrown], for: .selected)
               self.addCornerRadius()
    }
}
