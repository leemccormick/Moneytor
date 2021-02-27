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
    @IBOutlet weak var incomeAmountTextField: MoneytorTextField!
    @IBOutlet weak var incomeCategoryPicker: UIPickerView!
    @IBOutlet weak var incomeDatePicker: UIDatePicker!
    
    // MARK: - Properties
    var income: Income?
    // var selectedIncomeCategory: IncomeCategory
    var selectedIncomeCategory: IncomeCategory = IncomeCategory(name: "other", emoji: "💵")
    
    
    // MARK: - Life Cycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        let tap = UITapGestureRecognizer(target: self.view, action: #selector(UIView.endEditing))
        view.addGestureRecognizer(tap)
        incomeCategoryPicker.delegate = self
        incomeCategoryPicker.dataSource = self
        incomeNameTextField.delegate = self
        incomeAmountTextField.delegate = self
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        updateViews()
    }
    
    
    
    // MARK: - Actions
    
    @IBAction func saveButtonTapped(_ sender: Any) {
        saveIncome()
    }
    
    @IBAction func trashButtonTapped(_ sender: Any) {
        guard let income = income else {return}
        IncomeController.shared.deleteIncome(income)
        navigationController?.popViewController(animated: true)
    }
    
    
    @IBAction func incomeSaveButtonTapped(_ sender: Any) {
        saveIncome()
    }
    
    
    @IBAction func incomeDatePickerValueChange(_ sender: Any) {
        
    }
    
    // MARK: - Helper Fuctions
    func updateViews() {
        guard let income = income else {
            self.navigationItem.title = "Add Income"
            return
        }
        self.navigationItem.title = "Update Income"
        incomeNameTextField.text = income.name
        incomeAmountTextField.text = income.incomeAmountStringToUpdate
        
        //TO DO UPDATE :: PickerView?? Selected Income
        switch income.incomeCategory?.name {
        case "salary":
            incomeCategoryPicker.selectRow(1, inComponent: 0, animated: true)
        case "saving":
            incomeCategoryPicker.selectRow(2, inComponent: 0, animated: true)
        case "checking":
            incomeCategoryPicker.selectRow(3, inComponent: 0, animated: true)
        default:
            incomeCategoryPicker.selectRow(0, inComponent: 0, animated: true)
        }
    
        
        incomeDatePicker.date = income.date ?? Date()
        // incomeCategoryPicker.
    }
    
    func saveIncome() {
        guard let name = incomeNameTextField.text, !name.isEmpty else {
            if incomeAmountTextField.text?.isEmpty == true  {
                presentErrorToUser(titleAlert: "INCOME'S INPUT NEEDED!", messageAlert: "Don't forget to add name and amount!")
            } else {
                presentErrorToUser(titleAlert: "INCOME'S NAME!", messageAlert: "Don't forget to name your income!")
            }
            return
            
        }
        guard let amount = incomeAmountTextField.text, !amount.isEmpty else {
            presentErrorToUser(titleAlert: "INCOME'S AMOUNT!", messageAlert: "Don't forget to input income's amount!")
            return
        }
        
        if let income = income {
            IncomeController.shared.updateWith(income, name: name, amount: Double(amount) ?? 00.00, category: selectedIncomeCategory, date: incomeDatePicker.date)
        } else {
            IncomeController.shared.createIncomeWith(name: name, amount: Double(amount) ?? 00.00, category: selectedIncomeCategory, date: incomeDatePicker.date)
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
        print(":::::::::::IncomeCategoryController.shared.incomeCategories.count::::::::::::\(IncomeCategoryController.shared.incomeCategories.count)")
        return IncomeCategoryController.shared.incomeCategories.count
    }
    
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        selectedIncomeCategory = IncomeCategoryController.shared.incomeCategories[row]
        pickerView.reloadAllComponents()
    }
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        var pickerLabel: UILabel? = (view as? UILabel)
        if pickerLabel == nil {
            pickerLabel = UILabel()
            pickerLabel?.font = UIFont(name: FontNames.textTitleBoldMoneytor, size: 20)
            pickerLabel?.textAlignment = .center
        }
        
        let incomeCategory = IncomeCategoryController.shared.incomeCategories[row]
        pickerLabel?.text = "\(incomeCategory.emoji ?? "💵")  \(incomeCategory.name ?? "other")"
        pickerLabel?.textColor = UIColor.mtTextDarkBrown
        return pickerLabel!
    }
    
}

extension IncomeDetailTableViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.text = ""
        return true
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        textField.text = ""
        return true
    }
}





