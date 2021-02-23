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
        self.addCornerRadius()
    }
}


/*
 // MARK: - UIPickerViewDelegate, UIPickerViewDataSource
 extension PizzaCalculatorViewController: UIPickerViewDelegate, UIPickerViewDataSource {
     func numberOfComponents(in pickerView: UIPickerView) -> Int {
         return 1
     }
     
     func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
         return CalculatorController.shared.resturants.count
     }
     
     func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
         return CalculatorController.shared.resturants[row]
     }
     
     func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
         selectedResturant = CalculatorController.shared.resturants[row]
     }
     
     func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
         var pickerLabel: UILabel? = (view as? UILabel)
         if pickerLabel == nil {
             pickerLabel = UILabel()
             pickerLabel?.font = UIFont(name: FontNames.pizzaTextFont, size: 30)
             pickerLabel?.textAlignment = .center
         }
         pickerLabel?.text = CalculatorController.shared.resturants[row]
         pickerLabel?.textColor = UIColor.darkSauce
         return pickerLabel!
     }
 }
 */
