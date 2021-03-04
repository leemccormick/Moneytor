//
//  MoneytorPickerView.swift
//  Moneytor
//
//  Created by Lee McCormick on 2/23/21.
//

import UIKit

class MoneytorPickerView: UIPickerView {
    override  func awakeFromNib() {
        super.awakeFromNib()
        updateView()
    }
    
    func updateView() {
        self.backgroundColor = .mtDarkOrage
        self.layer.borderWidth = 2.5
        self.layer.borderColor = UIColor.mtLightYellow.cgColor
        self.addCornerRadius()
    }
}

class MoneytorDatePickerView: UIDatePicker {
    override  func awakeFromNib() {
        super.awakeFromNib()
        updateView()
    }
    
    func updateView() {
        self.backgroundColor = .mtDarkOrage
        self.layer.borderWidth = 2.5
        self.layer.borderColor = UIColor.mtLightYellow.cgColor
        self.tintColor = .mtTextDarkBrown
        self.addCornerRadius()
    }
}

