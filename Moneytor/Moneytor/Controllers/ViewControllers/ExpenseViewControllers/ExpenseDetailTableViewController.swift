//
//  ExpenseDetailTableViewController.swift
//  Moneytor
//
//  Created by Lee McCormick on 2/22/21.
//

import UIKit

class ExpenseDetailTableViewController: UITableViewController {

    // MARK: - Outlets
    @IBOutlet weak var expenseNameTextField: MoneytorTextField!
    @IBOutlet weak var expenseAmountTextField: MoneytorTextField!
    @IBOutlet weak var expenseCategoryPicker: UIPickerView!
    @IBOutlet weak var expenseDatePicker: UIDatePicker!
    
    // MARK: - Properties
    var expense: Expense?
    var selectedCategory: ExpenseCategory = ExpenseCategory(name: "other", emoji: "💸")
    
    
    // MARK: - Life Cycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        let tap = UITapGestureRecognizer(target: self.view, action: #selector(UIView.endEditing))
        view.addGestureRecognizer(tap)
        expenseCategoryPicker.delegate = self
        expenseCategoryPicker.dataSource = self
        expenseNameTextField.delegate = self
        expenseAmountTextField.delegate = self
        updateView()
    }

    
    // MARK: - Actions
    
    @IBAction func saveButtonTapped(_ sender: Any) {
        saveExpense()
    }
    
    @IBAction func saveExpenseButtonTapped(_ sender: Any) {
        saveExpense()
    }
    
    
    @IBAction func scannerButtonTapped(_ sender: Any) {
    }
    
    @IBAction func expensesDatePickerValueChange(_ sender: Any) {
    }
    
    // MARK: - Helper Fuctions
    func updateView() {
        guard let expense = expense else {return}
        expenseNameTextField.text = expense.name
        expenseAmountTextField.text = expense.expenseAmountToUpdate
        // For  and PickerView Update HERE.....
        
        
        
        
        expenseDatePicker.date = expense.date ?? Date()
        
    }
    
    func saveExpense() {
        
        
        guard let name = expenseNameTextField.text, !name.isEmpty else {
            if expenseAmountTextField.text?.isEmpty == true  {
                presentErrorToUser(titleAlert: "EXPENSE'S INPUT NEEDED!", messageAlert: "Don't forget to add name and amount!")
            } else {
                presentErrorToUser(titleAlert: "EXPENSE'S NAME!", messageAlert: "Don't forget to name your expense!")
            }
            return
        }
        guard let amount = expenseAmountTextField.text, !amount.isEmpty else {
            presentErrorToUser(titleAlert: "EXPENSE'S AMOUNT!", messageAlert: "Don't forget to input expense's amount!")
            return}
        
        
        
        if let expense = expense {
            ExpenseController.shared.updateWith(expense, name: name, amount: Double(amount) ?? 0.0, category: selectedCategory, date: expenseDatePicker.date)
        } else {
            ExpenseController.shared.createExpenseWith(name: name, amount: Double(amount) ?? 0.0, category: selectedCategory, date: expenseDatePicker.date)
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

    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // toScannerVC
   }
}

// MARK: - Picker

extension ExpenseDetailTableViewController: UIPickerViewDelegate, UIPickerViewDataSource {
   
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return ExpenseCategoryController.shared.expenseCategories.count
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        selectedCategory = ExpenseCategoryController.shared.expenseCategories[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        var pickerLabel: UILabel? = (view as? UILabel)
        if pickerLabel == nil {
            pickerLabel = UILabel()
            pickerLabel?.font = UIFont(name: FontNames.textTitleBoldMoneytor, size: 20)
            pickerLabel?.textAlignment = .center
        }
        let expenseCategory = ExpenseCategoryController.shared.expenseCategories[row]
        pickerLabel?.text = "\(expenseCategory.emoji ?? "💸")  \(expenseCategory.name ?? "other")"
        pickerLabel?.textColor = UIColor.mtTextDarkBrown
        return pickerLabel!
    }
    
}

extension ExpenseDetailTableViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.text = ""
        return true
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        textField.text = ""
        return true
    }
}

