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
    var selectedExpenseCategory = ExpenseCategoryController.shared.expenseCategories[0]
    
    // MARK: - Life Cycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupToHideKeyboardOnTapOnView()
        expenseCategoryPicker.delegate = self
        expenseCategoryPicker.dataSource = self
        expenseNameTextField.delegate = self
        expenseAmountTextField.delegate = self
        expenseDatePicker.isUserInteractionEnabled = true
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
      
    }
    
    @IBAction func addCategoryButtonTapped(_ sender: Any) {
    }
    
    @IBAction func addNotifincationButtonTapped(_ sender: Any) {
        presentAlertAskingUserIfRemindedNeeded()
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
        return ExpenseCategoryController.shared.expenseCategories.count
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
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
    
    func textFieldDidEndEditing(_ textField: UITextField, reason: UITextField.DidEndEditingReason) {
        textField.resignFirstResponder()
    }
}

// MARK: - Income Notification
extension ExpenseDetailTableViewController {
    
    func presentAlertAskingUserIfRemindedNeeded(){
        let alertController = UIAlertController(title: "EXPENSE REMINDER!", message:"Would you like to set reminder for the bill that needed to be paid?", preferredStyle: .alert)
        let noRemiderAction = UIAlertAction(title: "NO", style: .cancel)
        let yesRemiderAction = UIAlertAction(title: "YES", style: .destructive) { (action) in
            self.presentAlertAddIncomeNotification()
        }
        alertController.addAction(noRemiderAction)
        alertController.addAction(yesRemiderAction)
        present(alertController, animated: true)
    }
    
    func  presentAlertAddIncomeNotification() {
        guard let name = expenseNameTextField.text, !name.isEmpty else {
            if expenseAmountTextField.text?.isEmpty == true  {
                presentAlertToUser(titleAlert: "EXPENSE'S INPUT NEEDED FOR NOTIFICATION!", messageAlert: "Add name and amount for remider!")
            } else {
                presentAlertToUser(titleAlert: "EXPENSE'S NAME NEEDED FOR NOTIFICATION!", messageAlert: "Add expense's name for your remider!")
            }
            return
        }
        guard let amount = self.expenseAmountTextField.text, !amount.isEmpty else {
            presentAlertToUser(titleAlert: "EXPENSE'S AMOUNT NEEDED FOR NOTIFICATION!!", messageAlert: "Add expense's amount for your remider!")
            return
        }
        
        let alertController = UIAlertController(title: "SET REMIDER FOR DUE DATE OF THIS EXPENSES!", message: "Name : \(name.capitalized) \nAmount : \(amount) \nCategory : \(selectedExpenseCategory.nameString.capitalized) \nPaid Date : \(expenseDatePicker.date.dateToString(format: .monthDayYear))", preferredStyle: .alert)
        let noAction = UIAlertAction(title: "CANCEL", style: .cancel)
        let yesAction = UIAlertAction(title: "YES, SET REMINDER!", style: .destructive) { (action) in
            
            if let expense = self.expense {
                ExpenseController.shared.updateExpenseWithNotificaion(expense, name: name, amount: Double(amount) ?? 00.00, category: self.selectedExpenseCategory, date: self.expenseDatePicker.date)
            } else {
                ExpenseController.shared.createExpenseAndNotificationWith(name: name, amount: Double(amount) ?? 00.00, category: self.selectedExpenseCategory, date: self.expenseDatePicker.date)
            }
            self.navigationController?.popViewController(animated: true)
        }
        alertController.addAction(yesAction)
        alertController.addAction(noAction)
        present(alertController, animated: true)
    }
}







