//
//  IncomeDetailTableViewController.swift
//  Moneytor
//
//  Created by Lee McCormick on 2/22/21.
//

import UIKit

class IncomeDetailTableViewController: UITableViewController {
    
    // MARK: - Outlets
    @IBOutlet weak var incomeNameTextField: MoneytorTextField!
    @IBOutlet weak var incomeAmount: MoneytorTextField!
    @IBOutlet weak var incomeCategoryPicker: UIPickerView!
    @IBOutlet weak var incomeDatePicker: UIDatePicker!
    
    // MARK: - Properties
        
    
    

    // MARK: - Life Cycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        let tap = UITapGestureRecognizer(target: self.view, action: #selector(UIView.endEditing))
        view.addGestureRecognizer(tap)
    }
    
    // MARK: - Actions
    
    @IBAction func saveButtonTapped(_ sender: Any) {
    }
    
    @IBAction func trashButtonTapped(_ sender: Any) {
    }
    
    
    @IBAction func incomeSaveButtonTapped(_ sender: Any) {
    }
    
    
    // MARK: - Table View
     override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
         view.tintColor = UIColor.mtBgGolder
           let header = view as! UITableViewHeaderFooterView
         header.textLabel?.textColor = UIColor.mtTextLightBrown
         header.textLabel?.font = UIFont(name: FontNames.textTitleBoldMoneytor, size: 20)
       }
     override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
         if section == 4 {
             return CGFloat(0.0)
         } else {
             return CGFloat(40.0)
         }
       }
    
}

/*
// MARK: - UIPickerViewDelegate, UIPickerViewDataSource
extension IncomeDetailTableViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return //CalculatorController.shared.resturants.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return //CalculatorController.shared.resturants[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        //selectedResturant = CalculatorController.shared.resturants[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        var pickerLabel: UILabel? = (view as? UILabel)
        if pickerLabel == nil {
            pickerLabel = UILabel()
            pickerLabel?.font = UIFont(name: FontNames.textTitleBoldMoneytor, size: 20)
            pickerLabel?.textAlignment = .center
        }
        // pickerLabel?.text = CalculatorController.shared.resturants[row]
        pickerLabel?.textColor = UIColor.mtTextDarkBrown
        return pickerLabel!
    }
}
*/
