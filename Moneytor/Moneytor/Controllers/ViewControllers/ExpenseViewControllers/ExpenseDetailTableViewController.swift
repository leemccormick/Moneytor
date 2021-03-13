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
    var selectedExpenseCategory = ExpenseCategoryController.shared.expenseCategories.first
    
    // MARK: - Life Cycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        let tap = UITapGestureRecognizer(target: self.view, action: #selector(UIView.endEditing))
        view.addGestureRecognizer(tap)
        expenseCategoryPicker.delegate = self
        expenseCategoryPicker.dataSource = self
        expenseNameTextField.delegate = self
        expenseAmountTextField.delegate = self
        ExpenseCategoryController.shared.fetchAllExpenseCategories()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        ExpenseCategoryController.shared.fetchAllExpenseCategories()
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
      //  print("==================\nExpenseCategoryController.shared.expenseCategorie :: \(ExpenseCategoryController.shared.expenseCategories.count)\n=======================")
       // ExpenseCategoryController.shared.generateSectionsAndSumEachExpenseCategory()
    }
    
    
    
    @IBAction func addCategoryButtonTapped(_ sender: Any) {
    }
    
    
    
    @IBAction func addNotifincationButtonTapped(_ sender: Any) {
    }
    
    
    @IBAction func expensesDatePickerValueChange(_ sender: Any) {
    }
    
    // MARK: - Helper Fuctions
    func updateView() {
        guard let expense = expense else {
            self.navigationItem.title = "Add Expense"
            return
        }
        self.navigationItem.title = "Update Expense"
        selectedExpenseCategory = expense.expenseCategory ?? ExpenseCategoryController.shared.expenseCategories[0]
        expenseNameTextField.text = expense.name
        expenseAmountTextField.text = expense.expenseAmountToUpdate
        expenseDatePicker.date = expense.date ?? Date()
        
        let numberOfRows = ExpenseCategoryController.shared.expenseCategories.count
        for row in 0..<numberOfRows {
            if expense.expenseCategory == ExpenseCategoryController.shared.expenseCategories[row] {
                expenseCategoryPicker.selectRow(row, inComponent: 0, animated: true)
            }
        }
    }
    
    func saveExpense() {
        guard let name = expenseNameTextField.text, !name.isEmpty else {
            if expenseAmountTextField.text?.isEmpty == true  {
                presentAlertToUser(titleAlert: "EXPENSE'S INPUT NEEDED!", messageAlert: "Don't forget to add name and amount!")
            } else {
                presentAlertToUser(titleAlert: "EXPENSE'S NAME!", messageAlert: "Don't forget to name your expense!")
            }
            return
        }
        guard let amount = expenseAmountTextField.text, !amount.isEmpty else {
            presentAlertToUser(titleAlert: "EXPENSE'S AMOUNT!", messageAlert: "Don't forget to input expense's amount!")
            return}
        
        
        guard let selectedExpenseCategory = selectedExpenseCategory else {return}
        if let expense = expense {
            ExpenseController.shared.updateWith(expense, name: name, amount: Double(amount) ?? 0.0, category: selectedExpenseCategory, date: expenseDatePicker.date)
        } else {
            ExpenseController.shared.createExpenseWith(name: name, amount: Double(amount) ?? 0.0, category: selectedExpenseCategory, date: expenseDatePicker.date)
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
        if section == 2 {
            return CGFloat(0.0)
        } else if section == 3 {
            return CGFloat(0.0)
        } else if section == 4{
            return CGFloat(0.0)
        }else {
            return CGFloat(40.0)
        }
    }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // toScannerVC
    }
}

// MARK: - UIPickerViewDelegate, UIPickerViewDataSource
extension ExpenseDetailTableViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        print("-------------------- ExpenseCategoryController.shared.expenseCategories.count: \(ExpenseCategoryController.shared.expenseCategories.count) in \(#function) : ----------------------------\n)")
        return ExpenseCategoryController.shared.expenseCategories.count
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        print("-----------------print :: \(print)-----------------")
        selectedExpenseCategory = ExpenseCategoryController.shared.expenseCategories[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        var pickerLabel: UILabel? = (view as? UILabel)
        if pickerLabel == nil {
            pickerLabel = UILabel()
            pickerLabel?.font = UIFont(name: FontNames.textTitleBoldMoneytor, size: 20)
            pickerLabel?.textAlignment = .center
        }
        let expenseCategory = ExpenseCategoryController.shared.expenseCategories[row]
        pickerLabel?.text = "\(expenseCategory.emoji ?? "💸")  \(expenseCategory.name?.capitalized ?? "other")"
        pickerLabel?.textColor = UIColor.mtTextDarkBrown
        return pickerLabel!
    }
}

// MARK: - UITextFieldDelegate
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


