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
        self.backgroundColor = .mtLightYellow
        self.layer.borderWidth = 1.0
        self.layer.borderColor = UIColor.mtDarkOrage.cgColor
        self.addCornerRadius()
    }
}

class MoneytorDatePickerView: UIDatePicker {
    override  func awakeFromNib() {
        super.awakeFromNib()
        updateView()
    }
    
    func updateView() {
        self.backgroundColor = .mtLightYellow
        self.layer.borderWidth = 1.0
        self.layer.borderColor = UIColor.mtDarkOrage.cgColor
        self.tintColor = .mtTextDarkBrown
        self.addCornerRadius()
    }
}

