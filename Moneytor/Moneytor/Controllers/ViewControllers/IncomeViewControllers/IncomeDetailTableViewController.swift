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
    var income: Income?
    var selectedIncomeCategory: String = ""
    
    // MARK: - Life Cycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        let tap = UITapGestureRecognizer(target: self.view, action: #selector(UIView.endEditing))
        view.addGestureRecognizer(tap)
        incomeCategoryPicker.delegate = self
        incomeCategoryPicker.dataSource = self
        updateViews()
    }
    
    
    
    
    // MARK: - Actions
    
    @IBAction func saveButtonTapped(_ sender: Any) {
        saveIncome()
    }
    
    @IBAction func trashButtonTapped(_ sender: Any) {
        guard let income = income else {return}
        IncomeController.shared.deleteIncome(income: income)
    }
    
    
    @IBAction func incomeSaveButtonTapped(_ sender: Any) {
        saveIncome()
    }
    
    
    @IBAction func incomeDatePickerValueChange(_ sender: Any) {
    }
    
    // MARK: - Helper Fuctions
    func updateViews() {
        guard let income = income else {return}
        incomeNameTextField.text = income.name
     //   incomeAmount.text = income.amount
       // incomeCategoryPicker.
    }
    
    func saveIncome() {
        guard let name = incomeNameTextField.text, !name.isEmpty else {return}
        guard let amount = incomeAmount.text, !amount.isEmpty else {return}
        if let income = income {
            IncomeController.shared.updateIncome(income: income, name: name, amount: Double(amount) ?? 00.00, category: selectedIncomeCategory, date: incomeDatePicker.date)
        } else {
            IncomeController.shared.createIncome(name: name, amount: Double(amount) ?? 00.00, category: selectedIncomeCategory, date: incomeDatePicker.date)
        }
        navigationController?.popViewController(animated: true)
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


// MARK: - UIPickerViewDelegate, UIPickerViewDataSource
extension IncomeDetailTableViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return IncomeCategory.allCases.count
    }

    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        selectedIncomeCategory = IncomeCategory.allCases[row].rawValue
    }
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        var pickerLabel: UILabel? = (view as? UILabel)
        if pickerLabel == nil {
            pickerLabel = UILabel()
            pickerLabel?.font = UIFont(name: FontNames.textTitleBoldMoneytor, size: 20)
            pickerLabel?.textAlignment = .center
        }
        pickerLabel?.text = IncomeCategory.allCases[row].systemNameForPicker
        pickerLabel?.textColor = UIColor.mtTextDarkBrown
        return pickerLabel!
    }
}

