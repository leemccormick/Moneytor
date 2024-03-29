//
//  ExpenseDetailTableViewController.swift
//  Moneytor
//
//  Created by Lee McCormick on 2/22/21.
//

import UIKit
import Vision
import VisionKit

class ExpenseDetailTableViewController: UITableViewController  {
    
    // MARK: - Outlets
    @IBOutlet weak var expenseNameTextField: MoneytorTextField!
    @IBOutlet weak var expenseAmountTextField: MoneytorTextField!
    @IBOutlet weak var expenseCategoryPicker: UIPickerView!
    @IBOutlet weak var expenseDatePicker: UIDatePicker!
    @IBOutlet weak var expenseNoteTextView: UITextView!
    @IBOutlet weak var expenseImageView: UIImageView!
    
    // MARK: - Properties
    var expense: Expense?
    var selectedExpenseCategory: ExpenseCategory?
    var expenseFromScanner: Expense?
    let textRecognizationQueue = DispatchQueue.init(label: "TextRecognizationQueue", qos: .userInitiated, attributes: [], autoreleaseFrequency: .workItem, target: nil)
    var requests = [VNRequest]()
    var startedDate: Date?
    var endedDate: Date?
    
    // MARK: - Life Cycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupToHideKeyboardOnTapOnView()
        expenseCategoryPicker.delegate = self
        expenseCategoryPicker.dataSource = self
        expenseNameTextField.delegate = self
        expenseAmountTextField.delegate = self
        expenseNoteTextView.delegate = self
        expenseDatePicker.isUserInteractionEnabled = true
        expenseImageView.enableZoom()
        ExpenseCategoryController.shared.fetchAllExpenseCategories()
        if ExpenseCategoryController.shared.expenseCategories.count == 0 {
            let newCategory = ExpenseCategoryController.shared.createExpenseDefaultCategories(name: "other", emoji: "💸")
            guard let upwrapNewCategory = newCategory else {return}
            selectedExpenseCategory = upwrapNewCategory
        }
        selectedExpenseCategory = ExpenseCategoryController.shared.expenseCategories.first
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        ExpenseCategoryController.shared.fetchAllExpenseCategories()
        expenseCategoryPicker.reloadAllComponents()
        selectedExpenseCategory = ExpenseCategoryController.shared.expenseCategories.first
        if ScannerController.shared.hasScanned {
            self.expenseNameTextField.text = ScannerController.shared.name
            self.expenseAmountTextField.text = ScannerController.shared.amount
            self.expenseDatePicker.date = ScannerController.shared.date.toDate() ?? Date()
            self.expenseNoteTextView.text = ScannerController
                .shared.note
            if let image = ScannerController.shared.imageScanner {
                self.expenseImageView.image = image
            }
            if let categoryFromScanner = ScannerController.shared.expenseCategory {
                selectedExpenseCategory = categoryFromScanner
                let numberOfRows = ExpenseCategoryController.shared.expenseCategories.count
                for row in 0..<numberOfRows {
                    if categoryFromScanner == ExpenseCategoryController.shared.expenseCategories[row] {
                        expenseCategoryPicker.selectRow(row, inComponent: 0, animated: true)
                    }
                }
            }
        }
        updateView()
        tableView.reloadData()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        ScannerController.shared.deleteNameAmountAndNote()
        self.requests = ScannerController.shared.setupVisionForExpenseScanner()
    }
    
    // MARK: - Actions
    @IBAction func saveButtonTapped(_ sender: Any) {
        saveExpense()
    }
    
    @IBAction func saveExpenseButtonTapped(_ sender: Any) {
        saveExpense()
    }
    
    @IBAction func scannerBarButtonTapped(_ sender: Any) {
        scanReceiptForExpenseResult()
    }
    
    @IBAction func scannerButtonTapped(_ sender: Any) {
        scanReceiptForExpenseResult()
    }
    
    @IBAction func addCategoryButtonTapped(_ sender: Any) {
        createNewCategory()
    }
    
    @IBAction func addNotifincationButtonTapped(_ sender: Any) {
        presentAlertAskingUserIfRemindedNeeded()
    }
    
    @IBAction func plusAddMoreExpensesButtonTapped(_ sender: Any) {
        presentAlertAddAmountOptions()
    }
    
    @IBAction func monthlyExpenseButtonTapped(_ sender: Any) {
        presentAlertMonthlyExpenses()
    }
    
    // MARK: - Helper Fuctions
    func scanReceiptForExpenseResult() {
        ScannerController.shared.deleteNameAmountAndNote()
        let documentCameraController = VNDocumentCameraViewController()
        documentCameraController.delegate = self
        self.present(documentCameraController, animated: true, completion: nil)
    }
    
    func updateView() {
        guard let expense = expense else {
            self.navigationItem.title = "Add Expense"
            if let startedDate = startedDate,
               let endedDate = endedDate {
                expenseDatePicker.minimumDate = startedDate
                expenseDatePicker.maximumDate = endedDate
            }
            expenseNoteTextView.text = "Take a note for your expense here or scan a receipt for expense's detail..."
            return
        }
        if let startedDate = startedDate,
           let endedDate = endedDate {
            expenseDatePicker.minimumDate = startedDate
            expenseDatePicker.maximumDate = endedDate
        }
        self.navigationItem.title = "Update Expense"
        selectedExpenseCategory = expense.expenseCategory ?? ExpenseCategoryController.shared.expenseCategories[0]
        expenseNameTextField.text = expense.name
        expenseAmountTextField.text = expense.expenseAmountToUpdate
        expenseDatePicker.date = expense.date ?? Date()
        if let note = expense.note, note.isEmpty {
            expenseNoteTextView.text = "Take a note for your expense here or scan a receipt for expense's detail..."
        } else {
            expenseNoteTextView.text = expense.note
        }
        let numberOfRows = ExpenseCategoryController.shared.expenseCategories.count
        for row in 0..<numberOfRows {
            if expense.expenseCategory == ExpenseCategoryController.shared.expenseCategories[row] {
                expenseCategoryPicker.selectRow(row, inComponent: 0, animated: true)
            }
        }
        if let image = expense.image {
            expenseImageView.image = UIImage(data: image)
        } else {
            expenseImageView.isHidden = true
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
        var totalInString = "0"
        var amountToSaveNote = ""
        if amount.contains(".") {
            amountToSaveNote = "\n\nExpense's Amount : \(amount)"
        } else {
            amountToSaveNote = "\n\nExpense's Amount : \(amount).00"
        }
        if amount.contains("=") {
            guard let index = amount.firstIndex(of: "=") else {return}
            var newAmountWithOutEqual = amount
            newAmountWithOutEqual.remove(at: index)
            totalInString = String(newAmountWithOutEqual.suffix(from: index)).stringByRemovingWhitespaces
        } else {
            totalInString = amount
        }
        guard let selectedExpenseCategory = selectedExpenseCategory else {return}
        if let expense = expense {
            if expenseNoteTextView.text.contains(amountToSaveNote) {
                ExpenseController.shared.updateWith(expense, name: name, amount: Double(totalInString) ?? 0.0, category: selectedExpenseCategory, date: expenseDatePicker.date, note: expenseNoteTextView.text)
            } else {
                ExpenseController.shared.updateWith(expense, name: name, amount: Double(totalInString) ?? 0.0, category: selectedExpenseCategory, date: expenseDatePicker.date, note: expenseNoteTextView.text + amountToSaveNote + "\nUpdated On : \(Date().dateToString(format: .monthDayYear))")
            }
        } else {
            let imageData = expenseImageView.image?.jpegData(compressionQuality: 0.7)
            var textViewNote = ""
            if expenseNoteTextView.text == "Take a note for your expense here or scan a receipt for expense's detail..." {
                textViewNote = ""
            } else {
                textViewNote = expenseNoteTextView.text
            }
            let textViewNoteToSave = "\(textViewNote) \n\(amountToSaveNote)  \nCreated On : \(Date().dateToString(format: .monthDayYear))"
            ExpenseController.shared.createExpenseWith(name: name, amount: Double(totalInString) ?? 0.0, category: selectedExpenseCategory, date: expenseDatePicker.date, note: textViewNoteToSave, image: imageData)
        }
        navigationController?.popViewController(animated: true)
    }
    
    // MARK: - Table View
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 2
        case 1:
            return 2
        case 2:
            return 2
        case 3:
            return 2
        case 4:
            return 1
        case 5:
            if expenseImageView.image == nil {
                return 0
            } else {
                return 1
            }
        case 6:
            return 2
        default:
            return 0
        }
    }
    
    override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        view.tintColor = UIColor.mtDarkYellow
        let header = view as! UITableViewHeaderFooterView
        header.textLabel?.textColor = UIColor.mtTextLightBrown
        header.textLabel?.font = UIFont(name: FontNames.textTitleBoldMoneytor, size: 20)
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        switch section {
        case 0:
            return CGFloat(00.0)
        case 1:
            return CGFloat(00.0)
        case 2:
            return CGFloat(0.0)
        case 3:
            return CGFloat(0.0)
        case 4:
            return CGFloat(40.0)
        case 5:
            if expenseImageView.image == nil {
                return CGFloat(0.0)
            } else {
                return CGFloat(40.0)
            }
        case 6:
            return CGFloat(0.0)
        default:
            return CGFloat(0.0)
        }
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
        return true
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField, reason: UITextField.DidEndEditingReason) {
        textField.resignFirstResponder()
    }
}

// MARK: - UITextViewDelegate
extension ExpenseDetailTableViewController: UITextViewDelegate {
    func textViewDidBeginEditing(_ textView: UITextView) {
        if expenseNoteTextView.text ==  "Take a note for your expense here or scan a receipt for expense's detail..." {
            textView.text = ""
        }
    }
}

// MARK: - VNDocumentCameraViewControllerDelegate
extension ExpenseDetailTableViewController: VNDocumentCameraViewControllerDelegate {
    func documentCameraViewController(_ controller: VNDocumentCameraViewController, didFinishWith scan: VNDocumentCameraScan) {
        controller.dismiss(animated: true, completion: nil)
        for i in 0..<scan.pageCount {
            let scannedImage = scan.imageOfPage(at: i)
            expenseImageView.image = scannedImage
            ScannerController.shared.imageScanner = scannedImage
            if let cgImage = scannedImage.cgImage {
                let requestHandler = VNImageRequestHandler.init(cgImage: cgImage, options: [:])
                do {
                    try requestHandler.perform(self.requests)
                } catch {
                    print(error.localizedDescription)
                }
            }
        }
    }
    
    func documentCameraViewControllerDidCancel(_ controller: VNDocumentCameraViewController) {
        controller.dismiss(animated: true, completion: nil)
        expenseImageView.image = nil
        ScannerController.shared.imageScanner = nil
        presentAlertToUser(titleAlert: "CANCELED!", messageAlert: "Expense receipt scanner have been cancled!")
    }
    
    func documentCameraViewController(_ controller: VNDocumentCameraViewController, didFailWithError error: Error) {
        controller.dismiss(animated: true, completion: nil)
        expenseImageView.image = nil
        ScannerController.shared.imageScanner = nil
        print("\n==== ERROR SCANNING RECEIPE IN \(#function) : \(error.localizedDescription) : \(error) ====\n")
        presentAlertToUser(titleAlert: "ERROR! SCANNING RECEIPT!", messageAlert: "Please, make sure if you are using camera propertly to scan receipt!")
    }
}

// MARK: - Category
extension ExpenseDetailTableViewController {
    func createNewCategory() {
        let alertController = UIAlertController(title: "Add New Category!",
                                                message: "If you would like to add new expense category, please enter a new expense category emoji and name." ,preferredStyle: .alert)
        alertController.addTextField { (emojiTextFiled) in
            emojiTextFiled.placeholder = "Enter an emoji for category..."
            emojiTextFiled.keyboardAppearance = .dark
            emojiTextFiled.keyboardType = .default
        }
        
        alertController.addTextField { (nameTextFiled) in
            nameTextFiled.placeholder = "Enter a name for category..."
            nameTextFiled.keyboardAppearance = .dark
            nameTextFiled.keyboardType = .default
        }
        let dismissAction = UIAlertAction(title: "Cancel", style: .destructive)
        let doSomethingAction = UIAlertAction(title: "Add New Category", style: .default) { (action) in
            guard let name = alertController.textFields?.last?.text, !name.isEmpty else {
                self.presentAlertToUser(titleAlert: "NAME ERROR!\nUnable to create new category! ", messageAlert: "Make sure you input a name for creating new category!")
                return}
            guard let emoji = alertController.textFields?.first?.text, !emoji.isEmpty, emoji.isSingleEmoji else {
                self.presentAlertToUser(titleAlert: "EMOJI ERROR!\nUnable to create new category! ", messageAlert: "Make sure you input a sigle emoji for creating new category!")
                return}
            let newExpenseCategory = ExpenseCategoryController.shared.createExpenseDefaultCategories(name: name, emoji: emoji)
            self.expenseCategoryPicker.reloadAllComponents()
            guard let upwrapNewExpenseCategory = newExpenseCategory else {return}
            let numberOfRows = ExpenseCategoryController.shared.expenseCategories.count
            for row in 0..<numberOfRows {
                if upwrapNewExpenseCategory == ExpenseCategoryController.shared.expenseCategories[row] {
                    self.expenseCategoryPicker.selectRow(row, inComponent: 0, animated: true)
                }
            }
            self.selectedExpenseCategory = upwrapNewExpenseCategory
        }
        alertController.addAction(doSomethingAction)
        alertController.addAction(dismissAction)
        present(alertController, animated: true)
    }
}

// MARK: - Amount
extension ExpenseDetailTableViewController {
    func presentAlertAddAmountOptions() {
        let alertController = UIAlertController(title: "Add More Expense Amount!",
                                                message: "Would you like to add more specific amount, or add tip on the expense amount?" ,preferredStyle: .alert)
        
        let dismissAction = UIAlertAction(title: "Cancel", style: .destructive)
        let addSpecificAmountAction = UIAlertAction(title: "ADD AMOUNT", style: .default) { (action) in
            self.presentAlertAddSpecificAmount()
        }
        let addTipToAmountAction = UIAlertAction(title: "ADD TIP", style: .default) { (action) in
            self.presentAlertAddTip()
        }
        alertController.addAction(addSpecificAmountAction)
        alertController.addAction(addTipToAmountAction)
        alertController.addAction(dismissAction)
        present(alertController, animated: true)
    }
    
    func presentAlertAddSpecificAmount() {
        var amountText = expenseAmountTextField.text ?? "0.0"
        if amountText.contains("=") {
            guard let index = amountText.firstIndex(of: "=") else {return}
            let lastRange = amountText.index(amountText.startIndex, offsetBy: (amountText.count))
            amountText.removeSubrange(index..<lastRange)
        }
        let alertController = UIAlertController(title: "Add Specific Amount!",
                                                message: "If you would like to add more expense amount, please enter more amount!" ,preferredStyle: .alert)
        alertController.addTextField { (amountTextFiled) in
            amountTextFiled.placeholder = "Enter an amount for this expense..."
            amountTextFiled.keyboardAppearance = .dark
            amountTextFiled.keyboardType = .decimalPad
            amountText += amountTextFiled.text ?? ""
        }
        alertController.addTextField { (detailAmountTextField) in
            detailAmountTextField.placeholder = "Expense amount's Detail..."
            detailAmountTextField.keyboardAppearance = .dark
            detailAmountTextField.keyboardType = .default
            detailAmountTextField.isEnabled = false
            detailAmountTextField.text = "\(amountText)"
        }
        let dismissAction = UIAlertAction(title: "Cancel", style: .cancel)
        let addMoreExpenseAction = UIAlertAction(title: "Add More Amount!", style: .default) { (action) in
            guard let amountToAdd = alertController.textFields?.first?.text, !amountToAdd.isEmpty else {
                self.presentAlertToUser(titleAlert: "ADD AMOUNT ERROR!\nUnable to add more amount! ", messageAlert: "Make sure you input an amount for adding more amount!")
                return}
            amountText += "+\(amountToAdd)"
            let arrayOfAmount = amountText.components(separatedBy: "+")
            var arrayOfAmountWithNoWhiteSpaces: [String] = []
            for amountString in arrayOfAmount {
                arrayOfAmountWithNoWhiteSpaces.append(amountString.stringByRemovingWhitespaces)
            }
            let totalAmount = arrayOfAmountWithNoWhiteSpaces.reduce(0) {(Double($0)) + (Double($1) ?? 0.0)}
            self.expenseAmountTextField.text = "\(amountText) = \(totalAmount)"
            self.presentAlertAddSpecificAmount()
        }
        alertController.addAction(addMoreExpenseAction)
        alertController.addAction(dismissAction)
        present(alertController, animated: true)
    }
    
    func presentAlertAddTip() {
        let alertController = UIAlertController(title: "Add Tip on Amount!",
                                                message: "If you would like to add more expense amount, please enter more amount!" ,preferredStyle: .alert)
        alertController.addTextField { (textField) in
            textField.placeholder = "Enter % of the tip."
            textField.keyboardAppearance = .dark
            textField.keyboardType = .decimalPad
        }
        let dismissAction = UIAlertAction(title: "Cancel", style: .cancel)
        let specificPercentAction = UIAlertAction(title: "Add Input Tip", style: .default) { (action) in
            guard let tipToAddInPercent = alertController.textFields?.first?.text, !tipToAddInPercent.isEmpty else {
                self.presentAlertToUser(titleAlert: "ADD TIP ERROR!\nUnable to add tip to the amount! ", messageAlert: "Make sure you input the percent of the tip or choose tip from the options!")
                return}
            let amountOfTipInNumber = (Double(tipToAddInPercent) ?? 0.00)
            let amountOfTipInPercent = amountOfTipInNumber / 100
            self.addTipIn(percent: amountOfTipInPercent)
        }
        let fifteenPercentAction = UIAlertAction(title: "Add 15 % Tip", style: .default) { (action) in
            self.addTipIn(percent: 0.15)
        }
        let eightteenPercentAction = UIAlertAction(title: "Add 18 % Tip", style: .default) { (action) in
            self.addTipIn(percent: 0.18)
        }
        let twentyPercentAction = UIAlertAction(title: "Add 20 % Tip", style: .default) { (action) in
            self.addTipIn(percent: 0.20)
        }
        let twentyFivePercentAction = UIAlertAction(title: "Add 25 % Tip", style: .default) { (action) in
            self.addTipIn(percent: 0.25)
        }
        alertController.addAction(specificPercentAction)
        alertController.addAction(fifteenPercentAction)
        alertController.addAction(eightteenPercentAction)
        alertController.addAction(twentyPercentAction)
        alertController.addAction(twentyFivePercentAction)
        alertController.addAction(dismissAction)
        present(alertController, animated: true)
    }
    
    func addTipIn(percent: Double) {
        var amountText = expenseAmountTextField.text ?? "0.0"
        if amountText.contains("=") {
            guard let index = amountText.firstIndex(of: "=") else {return}
            amountText.remove(at: index)
            let firstRange = amountText.index(amountText.startIndex, offsetBy: 0)
            amountText.removeSubrange(firstRange..<index)
            amountText = amountText.stringByRemovingWhitespaces
        }
        let amountTextInDouble = Double(amountText) ?? 0.0
        let amountOfTip = amountTextInDouble * percent
        let amountOfTipInStringWithTwoDecimals = AmountFormatter.twoDecimalPlaces(num: amountOfTip)
        let totalAmountPlusTip = amountTextInDouble + amountOfTip
        let totalAmountPlusTipInStringWithTwoDecimals = AmountFormatter.twoDecimalPlaces(num: totalAmountPlusTip)
        let detailOfAddTip = "\(amountText) + \(amountOfTipInStringWithTwoDecimals) = \(totalAmountPlusTipInStringWithTwoDecimals)"
        
        let stringTotalPlusTip = "\(Int(totalAmountPlusTip)).00"
        
        if totalAmountPlusTipInStringWithTwoDecimals == stringTotalPlusTip {
            self.expenseAmountTextField.text = "\(amountText) + \(amountOfTipInStringWithTwoDecimals) = \(totalAmountPlusTipInStringWithTwoDecimals)"
        } else {
            presentAlertToRoundUp(tip: amountOfTip, total: totalAmountPlusTip, detail: detailOfAddTip, amount: amountTextInDouble)
        }
    }
    
    func presentAlertToRoundUp(tip : Double, total: Double, detail: String, amount: Double) {
        let alertController = UIAlertController(title: "Round Up Tip!",
                                                message: "\nAmount With Tip : \n\(detail) \n\nWould you like to round up the total to \(Int(total+1)).00 ?" ,preferredStyle: .alert)
        let dismissAction = UIAlertAction(title: "No", style: .cancel) { (action) in
            self.expenseAmountTextField.text = detail
        }
        let yesRoundUpTipAction = UIAlertAction(title: "Yes", style: .default) { (action) in
            let roundedUpIntTotal = Int(total+1)
            let amountPlusTip = amount + tip
            let totalDifferentOfTip = Double(roundedUpIntTotal) - amountPlusTip
            let newTip = tip + totalDifferentOfTip
            let newTipWithTwoDecimal = AmountFormatter.twoDecimalPlaces(num: newTip)
            self.expenseAmountTextField.text = "\(amount) + \(newTipWithTwoDecimal) = \(roundedUpIntTotal)"
        }
        alertController.addAction(yesRoundUpTipAction)
        alertController.addAction(dismissAction)
        present(alertController, animated: true)
    }
}

// MARK: - Monthly Expenses
extension ExpenseDetailTableViewController {
    func presentAlertMonthlyExpenses(){
        let alertController = UIAlertController(title: "MONTHLY EXPENSES!", message:"Would you like to set this expense to be automatically input monthly?", preferredStyle: .alert)
        let noRemiderAction = UIAlertAction(title: "NO", style: .destructive)
        let yesRemiderAction = UIAlertAction(title: "YES", style: .default) { (action) in
            self.presentAlertAddMonthlyExpenses()
        }
        alertController.addAction(yesRemiderAction)
        alertController.addAction(noRemiderAction)
        present(alertController, animated: true)
    }
    
    func presentAlertAddMonthlyExpenses() {
        guard let name = expenseNameTextField.text, !name.isEmpty else {
            if expenseAmountTextField.text?.isEmpty == true  {
                presentAlertToUser(titleAlert: "EXPENSE'S INPUT NEEDED!", messageAlert: "Add name and amount for setting an expense to be automatically input monthly!")
            } else {
                presentAlertToUser(titleAlert: "EXPENSE'S NAME NEEDED!", messageAlert: "Add expense's name for setting an expense to be automatically input monthly!")
            }
            return
        }
        guard let amount = self.expenseAmountTextField.text, !amount.isEmpty else {
            presentAlertToUser(titleAlert: "EXPENSE'S AMOUNT NEEDED!", messageAlert: "Add expense's amount for setting an expense to be automatically input monthly!")
            return
        }
        let amountInString = AmountFormatter.currencyInString(num: Double(amount) ?? 0.0)
        guard let selectedExpenseCategory = selectedExpenseCategory else {return}
        let alertController = UIAlertController(title: "SET EXPENSE MONTHLY INPUT!", message: "Name : \(name.capitalized) \nAmount : \(amountInString) \nCategory : \(selectedExpenseCategory.nameString.capitalized) \nMothly Bill Date : \(expenseDatePicker.date.dateToString(format: .onlyDate))", preferredStyle: .alert)
        let noAction = UIAlertAction(title: "CANCEL", style: .destructive)
        let yesSixMonthsAction = UIAlertAction(title: "SET FOR 6 MONTHS!", style: .default) { (action) in
            if let expense = self.expense {
                ExpenseController.shared.updateWith(expense, name: name, amount: Double(amount) ?? 00.00, category: selectedExpenseCategory, date: self.expenseDatePicker.date, note: self.expenseNoteTextView.text)
                let imageData = self.expenseImageView.image?.jpegData(compressionQuality: 0.7)
                let fiveMonths = self.expenseDatePicker.date.getUpdateRepeatedDatesForSixMonths()
                ExpenseController.shared.createMonthlyExpensesWith(name: name, amount: Double(amount) ?? 00.00, category: selectedExpenseCategory, date: self.expenseDatePicker.date, note: self.expenseNoteTextView.text, image: imageData, repeatedDuration: fiveMonths)
            } else {
                let imageData = self.expenseImageView.image?.jpegData(compressionQuality: 0.7)
                let sixMonths = self.expenseDatePicker.date.getRepeatedDatesForSixMonths()
                ExpenseController.shared.createMonthlyExpensesWith(name: name, amount: Double(amount) ?? 00.00, category: selectedExpenseCategory, date: self.expenseDatePicker.date, note: self.expenseNoteTextView.text, image: imageData, repeatedDuration: sixMonths)
            }
            self.navigationController?.popViewController(animated: true)
        }
        let yesOneYearAction = UIAlertAction(title: "SET FOR 1 YEAR!", style: .default) { (action) in
            if let expense = self.expense {
                ExpenseController.shared.updateWith(expense, name: name, amount: Double(amount) ?? 00.00, category: selectedExpenseCategory, date: self.expenseDatePicker.date, note: self.expenseNoteTextView.text)
                let imageData = self.expenseImageView.image?.jpegData(compressionQuality: 0.7)
                let elevenMonths = self.expenseDatePicker.date.getUpdateRepeatedDatesForAYear()
                ExpenseController.shared.createMonthlyExpensesWith(name: name, amount: Double(amount) ?? 00.00, category: selectedExpenseCategory, date: self.expenseDatePicker.date, note: self.expenseNoteTextView.text, image: imageData, repeatedDuration: elevenMonths)
            } else {
                let imageData = self.expenseImageView.image?.jpegData(compressionQuality: 0.7)
                let oneYear = self.expenseDatePicker.date.getRepeatedDatesForAYear()
                ExpenseController.shared.createMonthlyExpensesWith(name: name, amount: Double(amount) ?? 00.00, category: selectedExpenseCategory, date: self.expenseDatePicker.date, note: self.expenseNoteTextView.text, image: imageData, repeatedDuration: oneYear)
            }
            self.navigationController?.popViewController(animated: true)
        }
        let yesTwoYearAction = UIAlertAction(title: "SET FOR 2 YEARS!", style: .default) { (action) in
            if let expense = self.expense {
                ExpenseController.shared.updateWith(expense, name: name, amount: Double(amount) ?? 00.00, category: selectedExpenseCategory, date: self.expenseDatePicker.date, note: self.expenseNoteTextView.text)
                let imageData = self.expenseImageView.image?.jpegData(compressionQuality: 0.7)
                let twentyThreeMonths = self.expenseDatePicker.date.getUpdateRepeatedDatesForTwoYears()
                ExpenseController.shared.createMonthlyExpensesWith(name: name, amount: Double(amount) ?? 00.00, category: selectedExpenseCategory, date: self.expenseDatePicker.date, note: self.expenseNoteTextView.text, image: imageData, repeatedDuration: twentyThreeMonths)
            } else {
                let imageData = self.expenseImageView.image?.jpegData(compressionQuality: 0.7)
                let twoYears = self.expenseDatePicker.date.getRepeatedDatesForTwoYears()
                ExpenseController.shared.createMonthlyExpensesWith(name: name, amount: Double(amount) ?? 00.00, category: selectedExpenseCategory, date: self.expenseDatePicker.date, note: self.expenseNoteTextView.text, image: imageData, repeatedDuration: twoYears)
            }
            self.navigationController?.popViewController(animated: true)
        }
        alertController.addAction(yesSixMonthsAction)
        alertController.addAction(yesOneYearAction)
        alertController.addAction(yesTwoYearAction)
        alertController.addAction(noAction)
        present(alertController, animated: true)
    }
}

// MARK: - Expenses Notification
extension ExpenseDetailTableViewController {
    func presentAlertAskingUserIfRemindedNeeded(){
        let alertController = UIAlertController(title: "EXPENSE REMINDER!", message:"Would you like to set reminder for the bill that needed to be paid?", preferredStyle: .alert)
        let noRemiderAction = UIAlertAction(title: "NO", style: .destructive)
        let yesRemiderAction = UIAlertAction(title: "YES", style: .default) { (action) in
            self.presentAlertAddExpenseNotification()
        }
        alertController.addAction(yesRemiderAction)
        alertController.addAction(noRemiderAction)
        present(alertController, animated: true)
    }
    
    func  presentAlertAddExpenseNotification() {
        guard let name = expenseNameTextField.text, !name.isEmpty else {
            if expenseAmountTextField.text?.isEmpty == true  {
                presentAlertToUser(titleAlert: "EXPENSE'S INPUT NEEDED FOR REMINDER!", messageAlert: "Add name and amount for remider!")
            } else {
                presentAlertToUser(titleAlert: "EXPENSE'S NAME NEEDED FOR REMINDER!", messageAlert: "Add expense's name for your remider!")
            }
            return
        }
        guard let amount = self.expenseAmountTextField.text, !amount.isEmpty else {
            presentAlertToUser(titleAlert: "EXPENSE'S AMOUNT NEEDED FOR REMINDER!", messageAlert: "Add expense's amount for your remider!")
            return
        }
        let amountInString = AmountFormatter.currencyInString(num: Double(amount) ?? 0.0)
        guard let selectedExpenseCategory = selectedExpenseCategory else {return}
        let alertController = UIAlertController(title: "SET REMIDER FOR DUE DATE OF THIS EXPENSE!", message: "Name : \(name.capitalized) \nAmount : \(amountInString) \nCategory : \(selectedExpenseCategory.nameString.capitalized) \nBill Due Date : \(expenseDatePicker.date.dateToString(format: .monthDayYear))", preferredStyle: .alert)
        let noAction = UIAlertAction(title: "CANCEL", style: .destructive)
        let yesRepeatedNotificationAction = UIAlertAction(title: "SET MONTHLY REMINDERS!", style: .default) { (action) in
            self.presentAlertMonthlyRemindersSelection()
        }
        let yesAction = UIAlertAction(title: "SET A REMINDER!", style: .default) { (action) in
            if let expense = self.expense {
                ExpenseController.shared.updateExpenseWithNotificaion(expense, name: name, amount: Double(amount) ?? 00.00, category: selectedExpenseCategory, date: self.expenseDatePicker.date, note: self.expenseNoteTextView.text)
            } else {
                let imageData = self.expenseImageView.image?.jpegData(compressionQuality: 0.7)
                ExpenseController.shared.createExpenseAndNotificationWith(name: name, amount: Double(amount) ?? 00.00, category: selectedExpenseCategory, date: self.expenseDatePicker.date, note: self.expenseNoteTextView.text, image: imageData)
            }
            self.navigationController?.popViewController(animated: true)
        }
        alertController.addAction(yesAction)
        alertController.addAction(yesRepeatedNotificationAction)
        alertController.addAction(noAction)
        present(alertController, animated: true)
    }
    
    func presentAlertMonthlyRemindersSelection() {
        guard let name = expenseNameTextField.text, !name.isEmpty else {
            if expenseAmountTextField.text?.isEmpty == true  {
                presentAlertToUser(titleAlert: "EXPENSE'S INPUT NEEDED FOR REMINDER!", messageAlert: "Add name and amount for remider!")
            } else {
                presentAlertToUser(titleAlert: "EXPENSE'S NAME NEEDED FOR REMINDER!", messageAlert: "Add expense's name for your remider!")
            }
            return
        }
        guard let amount = self.expenseAmountTextField.text, !amount.isEmpty else {
            presentAlertToUser(titleAlert: "EXPENSE'S AMOUNT NEEDED FOR REMINDER!", messageAlert: "Add expense's amount for your remider!")
            return
        }
        let amountInString = AmountFormatter.currencyInString(num: Double(amount) ?? 0.0)
        guard let selectedExpenseCategory = selectedExpenseCategory else {return}
        let alertController = UIAlertController(title: "SET REMINDERS AND MONTHLY EXPENSES!", message: "\nPlease, select how long would you like to set reminders and automatically input expenses monthly? \n\nName : \(name.capitalized) \nAmount : \(amountInString) \nCategory : \(selectedExpenseCategory.nameString.capitalized) \nMonthly Bill Date : \(expenseDatePicker.date.dateToString(format: .onlyDate))", preferredStyle: .alert)
        let noAction = UIAlertAction(title: "CANCEL", style: .destructive)
        let yesSixMonthsAction = UIAlertAction(title: "SET FOR 6 MONTHS!", style: .default) { (action) in
            if let expense = self.expense {
                ExpenseController.shared.updateExpenseWithNotificaion(expense, name: name, amount: Double(amount) ?? 00.00, category: selectedExpenseCategory, date: self.expenseDatePicker.date, note: self.expenseNoteTextView.text)
                let imageData = self.expenseImageView.image?.jpegData(compressionQuality: 0.7)
                let fiveMonths = self.expenseDatePicker.date.getUpdateRepeatedDatesForSixMonths()
                ExpenseController.shared.createMonthlyExpensesAndNotificationsWith(repeatDuration: fiveMonths,name: name, amount: Double(amount) ?? 00.00, category: selectedExpenseCategory, date: self.expenseDatePicker.date, note: self.expenseNoteTextView.text, image: imageData)
            } else {
                let imageData = self.expenseImageView.image?.jpegData(compressionQuality: 0.7)
                let sixMonths = self.expenseDatePicker.date.getRepeatedDatesForSixMonths()
                ExpenseController.shared.createMonthlyExpensesAndNotificationsWith(repeatDuration: sixMonths,name: name, amount: Double(amount) ?? 00.00, category: selectedExpenseCategory, date: self.expenseDatePicker.date, note: self.expenseNoteTextView.text, image: imageData)
            }
            self.navigationController?.popViewController(animated: true)
        }
        let yesOneYearAction = UIAlertAction(title: "SET FOR 1 YEAR!", style: .default) { (action) in
            if let expense = self.expense {
                ExpenseController.shared.updateExpenseWithNotificaion(expense, name: name, amount: Double(amount) ?? 00.00, category: selectedExpenseCategory, date: self.expenseDatePicker.date, note: self.expenseNoteTextView.text)
                let imageData = self.expenseImageView.image?.jpegData(compressionQuality: 0.7)
                let elevenMonths = self.expenseDatePicker.date.getUpdateRepeatedDatesForAYear()
                ExpenseController.shared.createMonthlyExpensesAndNotificationsWith(repeatDuration: elevenMonths,name: name, amount: Double(amount) ?? 00.00, category: selectedExpenseCategory, date: self.expenseDatePicker.date, note: self.expenseNoteTextView.text, image: imageData)
            } else {
                let imageData = self.expenseImageView.image?.jpegData(compressionQuality: 0.7)
                let oneYear = self.expenseDatePicker.date.getRepeatedDatesForAYear()
                ExpenseController.shared.createMonthlyExpensesAndNotificationsWith(repeatDuration: oneYear,name: name, amount: Double(amount) ?? 00.00, category: selectedExpenseCategory, date: self.expenseDatePicker.date, note: self.expenseNoteTextView.text, image: imageData)
            }
            self.navigationController?.popViewController(animated: true)
        }
        let yesTwoYearAction = UIAlertAction(title: "SET FOR 2 YEARS!", style: .default) { (action) in
            if let expense = self.expense {
                ExpenseController.shared.updateExpenseWithNotificaion(expense, name: name, amount: Double(amount) ?? 00.00, category: selectedExpenseCategory, date: self.expenseDatePicker.date, note: self.expenseNoteTextView.text)
                let imageData = self.expenseImageView.image?.jpegData(compressionQuality: 0.7)
                let twentyThreeMonths = self.expenseDatePicker.date.getUpdateRepeatedDatesForTwoYears()
                ExpenseController.shared.createMonthlyExpensesAndNotificationsWith(repeatDuration: twentyThreeMonths,name: name, amount: Double(amount) ?? 00.00, category: selectedExpenseCategory, date: self.expenseDatePicker.date, note: self.expenseNoteTextView.text, image: imageData)
            } else {
                let imageData = self.expenseImageView.image?.jpegData(compressionQuality: 0.7)
                let twoYears = self.expenseDatePicker.date.getRepeatedDatesForTwoYears()
                ExpenseController.shared.createMonthlyExpensesAndNotificationsWith(repeatDuration: twoYears,name: name, amount: Double(amount) ?? 00.00, category: selectedExpenseCategory, date: self.expenseDatePicker.date, note: self.expenseNoteTextView.text, image: imageData)
            }
            self.navigationController?.popViewController(animated: true)
        }
        alertController.addAction(yesSixMonthsAction)
        alertController.addAction(yesOneYearAction)
        alertController.addAction(yesTwoYearAction)
        alertController.addAction(noAction)
        present(alertController, animated: true)
    }
}
