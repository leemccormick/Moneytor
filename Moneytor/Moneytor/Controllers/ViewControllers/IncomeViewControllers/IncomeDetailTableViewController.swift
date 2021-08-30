//
//  IncomeDetailTableViewController.swift
//  Moneytor
//
//  Created by Lee McCormick on 2/22/21.
//

import UIKit
import Vision
import VisionKit

class IncomeDetailTableViewController: UITableViewController {
    
    // MARK: - Outlets
    @IBOutlet weak var incomeNameTextField: MoneytorTextField!
    @IBOutlet weak var incomeAmountTextField: MoneytorTextField!
    @IBOutlet weak var incomeCategoryPicker: UIPickerView!
    @IBOutlet weak var incomeDatePicker: UIDatePicker!
    @IBOutlet weak var incomeNoteTextView: MoneytorTextView!
    @IBOutlet weak var incomeImageView: UIImageView!
    
    // MARK: - Properties
    var income: Income?
    var selectedIncomeCategory: IncomeCategory?
    let textRecognizationQueue = DispatchQueue.init(label: "TextRecognizationQueue", qos: .userInitiated, attributes: [], autoreleaseFrequency: .workItem, target: nil)
    var requests = [VNRequest]()
    var startedDate: Date?
    var endedDate: Date?
    
    // MARK: - Life Cycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupToHideKeyboardOnTapOnView()
        incomeCategoryPicker.delegate = self
        incomeCategoryPicker.dataSource = self
        incomeNameTextField.delegate = self
        incomeAmountTextField.delegate = self
        incomeNoteTextView.delegate = self
        incomeImageView.enableZoom()
        IncomeCategoryController.shared.fetchAllIncomeCategories()
        if IncomeCategoryController.shared.incomeCategories.count == 0 {
            let newCategory = IncomeCategoryController.shared.createIncomeDefaultCategories(name: "other", emoji: "💵")
            guard let upwrapNewCategory = newCategory else {return}
            selectedIncomeCategory = upwrapNewCategory
        }
        selectedIncomeCategory = IncomeCategoryController.shared.incomeCategories.first
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        IncomeCategoryController.shared.fetchAllIncomeCategories()
        incomeCategoryPicker.reloadAllComponents()
        if ScannerController.shared.hasScanned == true {
            self.incomeNameTextField.text = ScannerController.shared.name
            self.incomeAmountTextField.text = ScannerController.shared.amount
            self.incomeDatePicker.date = ScannerController.shared.date.toDate() ?? Date()
            self.incomeNoteTextView.text = ScannerController
                .shared.note
            if let image = ScannerController.shared.imageScanner {
                self.incomeImageView.image = image
            }
            if let categoryFromScanner = ScannerController.shared.incomeCategory {
                selectedIncomeCategory = categoryFromScanner
                let numberOfRows = IncomeCategoryController.shared.incomeCategories.count
                for row in 0..<numberOfRows {
                    if categoryFromScanner == IncomeCategoryController.shared.incomeCategories[row] {
                        incomeCategoryPicker.selectRow(row, inComponent: 0, animated: true)
                    }
                }
            }
        }
        updateViews()
        tableView.reloadData()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        ScannerController.shared.deleteNameAmountAndNote()
        self.requests = ScannerController.shared.setupVisionForIncomeScanner()
    }
    
    // MARK: - Actions
    @IBAction func saveButtonTapped(_ sender: Any) {
        saveIncome()
    }
    
    @IBAction func scannerButtonTapped(_ sender: Any) {
        scanReceiptForIncomeResult()
    }
    
    @IBAction func scannerButtonOnViewButtonTapped(_ sender: Any) {
        scanReceiptForIncomeResult()
    }
    
    @IBAction func incomeSaveButtonTapped(_ sender: Any) {
        saveIncome()
    }
    
    @IBAction func addCategoryButtonTapped(_ sender: Any) {
        createNewCategory()
    }
    
    @IBAction func addNotifincationButtonTapped(_ sender: Any) {
        presentAlertAskingUserIfRemindedNeeded()
    }
    
    @IBAction func plusAddMoreIncomesButtonTapped(_ sender: Any) {
      //  presentAlertAddAmountOptions()
    }
    
    @IBAction func monthlyIncomesButtonTapped(_ sender: Any) {
       presentAlertMonthlyIncomes()
    }
    
    // MARK: - Helper Fuctions
    func scanReceiptForIncomeResult() {
        ScannerController.shared.deleteNameAmountAndNote()
        let documentCameraController = VNDocumentCameraViewController()
        documentCameraController.delegate = self
        self.present(documentCameraController, animated: true, completion: nil)
    }
    
    func updateViews() {
        guard let income = income else {
            self.navigationItem.title = "Add Income"
            if let startedDate = startedDate,
               let endedDate = endedDate {
                incomeDatePicker.minimumDate = startedDate
                incomeDatePicker.maximumDate = endedDate
            }
            incomeNoteTextView.text = "Take a note for your income here or scan document for income's detail..."
            return
        }
        if let startedDate = startedDate,
           let endedDate = endedDate {
            incomeDatePicker.minimumDate = startedDate
            incomeDatePicker.maximumDate = endedDate
        }
        self.navigationItem.title = "Update Income"
        selectedIncomeCategory = income.incomeCategory ?? IncomeCategoryController.shared.incomeCategories[0]
        incomeNameTextField.text = income.name
        incomeAmountTextField.text = income.incomeAmountStringToUpdate
        incomeDatePicker.date = income.date ?? Date()
        if let note = income.note, note.isEmpty {
            incomeNoteTextView.text = "Take a note for your income here or scan document for income's detail..."
        } else {
            incomeNoteTextView.text = income.note
        }
        let numberOfRows = IncomeCategoryController.shared.incomeCategories.count
        for row in 0..<numberOfRows {
            if income.incomeCategory == IncomeCategoryController.shared.incomeCategories[row] {
                incomeCategoryPicker.selectRow(row, inComponent: 0, animated: true)
            }
        }
        if let image = income.image {
            incomeImageView.image = UIImage(data: image)
        }
    }
    
    func saveIncome() {
        guard let name = incomeNameTextField.text, !name.isEmpty else {
            if incomeAmountTextField.text?.isEmpty == true  {
                presentAlertToUser(titleAlert: "INCOME'S INPUT NEEDED!", messageAlert: "Don't forget to add name and amount!")
            } else {
                presentAlertToUser(titleAlert: "INCOME'S NAME!", messageAlert: "Don't forget to name your income!")
            }
            return
        }
        guard let amount = incomeAmountTextField.text, !amount.isEmpty else {
            presentAlertToUser(titleAlert: "INCOME'S AMOUNT!", messageAlert: "Don't forget to input income's amount!")
            return
        }
        guard let selectedIncomeCategory = selectedIncomeCategory else {return}
        if let income = income {
            IncomeController.shared.updateWith(income, name: name, amount: Double(amount) ?? 00.00, category: selectedIncomeCategory, date: incomeDatePicker.date, note: incomeNoteTextView.text )
        } else {
            let imageData = incomeImageView.image?.jpegData(compressionQuality: 0.7)
            IncomeController.shared.createIncomeWith(name: name, amount: Double(amount) ?? 00.00, category: selectedIncomeCategory, date: incomeDatePicker.date, note: incomeNoteTextView.text, image: imageData)
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
            if incomeImageView.image == nil {
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
            return CGFloat(0.0)
        case 1:
            return CGFloat(0.0)
        case 2:
            return CGFloat(0.0)
        case 3:
            return CGFloat(0.0)
        case 4:
            return CGFloat(40.0)
        case 5:
            if incomeImageView.image == nil {
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
extension IncomeDetailTableViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
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
        pickerLabel?.text = "\(incomeCategory.emoji ?? "💵")  \(incomeCategory.name?.capitalized ?? "other")"
        pickerLabel?.textColor = UIColor.mtTextDarkBrown
        return pickerLabel!
    }
}

// MARK: - UITextFieldDelegate
extension IncomeDetailTableViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        return true
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        return true
    }
}

// MARK: - UITextViewDelegate
extension IncomeDetailTableViewController: UITextViewDelegate {
    func textViewDidBeginEditing(_ textView: UITextView) {
        if incomeNoteTextView.text ==  "Take a note for your income here or scan document for income's detail..." {
            textView.text = ""
        }
    }
}

// MARK: - VNDocumentCameraViewControllerDelegate
extension IncomeDetailTableViewController: VNDocumentCameraViewControllerDelegate {
    func documentCameraViewController(_ controller: VNDocumentCameraViewController, didFinishWith scan: VNDocumentCameraScan) {
        controller.dismiss(animated: true, completion: nil)
        for i in 0..<scan.pageCount {
            let scannedImage = scan.imageOfPage(at: i)
            incomeImageView.image = scannedImage
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
        incomeImageView.image = nil
        ScannerController.shared.imageScanner = nil
        presentAlertToUser(titleAlert: "CANCELED!", messageAlert: "Income document scanner have been cancled!")
    }
    
    func documentCameraViewController(_ controller: VNDocumentCameraViewController, didFailWithError error: Error) {
        controller.dismiss(animated: true, completion: nil)
        incomeImageView.image = nil
        ScannerController.shared.imageScanner = nil
        print("\n==== ERROR SCANNING RECEIPE IN \(#function) : \(error.localizedDescription) : \(error) ====\n")
        presentAlertToUser(titleAlert: "ERROR! SCANNING INCOME!", messageAlert: "Please, make sure if you are using camera propertly to scan income!")
    }
}

// MARK: - Category
extension IncomeDetailTableViewController {
    func createNewCategory() {
        let alertController = UIAlertController(title: "Add New Category!",
                                                message: "If you would like to add new income category, please enter a new income category emoji and name." ,preferredStyle: .alert)
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
            let newIncomeCategory = IncomeCategoryController.shared.createIncomeDefaultCategories(name: name, emoji: emoji)
            self.incomeCategoryPicker.reloadAllComponents()
            guard let upwrapNewIncomeCategory = newIncomeCategory else {return}
            let numberOfRows = IncomeCategoryController.shared.incomeCategories.count
            for row in 0..<numberOfRows {
                if upwrapNewIncomeCategory == IncomeCategoryController.shared.incomeCategories[row] {
                    self.incomeCategoryPicker.selectRow(row, inComponent: 0, animated: true)
                }
            }
            self.selectedIncomeCategory = upwrapNewIncomeCategory
        }
        alertController.addAction(doSomethingAction)
        alertController.addAction(dismissAction)
        present(alertController, animated: true)
    }
}

// MARK: - Income Notification
extension IncomeDetailTableViewController {
    func presentAlertAskingUserIfRemindedNeeded(){
        let alertController = UIAlertController(title: "INCOME REMINDER!", message:"Would you like to get notification when you get paid?", preferredStyle: .alert)
        let noRemiderAction = UIAlertAction(title: "NO", style: .destructive)
        let yesRemiderAction = UIAlertAction(title: "YES", style: .default) { (action) in
            self.presentAlertAddIncomeNotification()
        }
        alertController.addAction(yesRemiderAction)
        alertController.addAction(noRemiderAction)
        present(alertController, animated: true)
    }
    
    func  presentAlertAddIncomeNotification() {
        guard let name = incomeNameTextField.text, !name.isEmpty else {
            if incomeAmountTextField.text?.isEmpty == true  {
                presentAlertToUser(titleAlert: "INCOME'S INPUT NEEDED FOR REMINDER!", messageAlert: "Add name and amount for remider!")
            } else {
                presentAlertToUser(titleAlert: "INCOME'S NAME NEEDED FOR REMINDER!", messageAlert: "Add income's name for your remider!")
            }
            return
        }
        guard let amount = self.incomeAmountTextField.text, !amount.isEmpty else {
            presentAlertToUser(titleAlert: "INCOME'S AMOUNT NEEDED FOR REMINDER!!", messageAlert: "Add income's amount for your remider!")
            return
        }
        let amountInString = AmountFormatter.currencyInString(num: Double(amount) ?? 0.0)
        guard let selectedIncomeCategory = selectedIncomeCategory else {return}
        
        let alertController = UIAlertController(title: "SET REMIDER FOR DUE DATE OF THIS INCOME!", message: "Name : \(name.capitalized) \nAmount : \(amountInString) \nCategory : \(selectedIncomeCategory.nameString.capitalized) \nPay Day : \(expenseDatePicker.date.dateToString(format: .monthDayYear))", preferredStyle: .alert)
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
        let alertController = UIAlertController(title: "SET REMINDERS AND MONTHLY EXPENSES!", message: "\nPlease, select how long would you like to set reminders and automatically input expenses monthly? \n\nName : \(name.capitalized) \nAmount : \(amountInString) \nCategory : \(selectedExpenseCategory.nameString.capitalized) \nMothly Paid Date : \(expenseDatePicker.date.dateToString(format: .onlyDate))", preferredStyle: .alert)
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


// MARK: - Monthly Expenses
extension IncomeDetailTableViewController {
    func presentAlertMonthlyIncomes(){
        let alertController = UIAlertController(title: "MONTHLY INCOMES!", message:"Would you like to set this income to be automatically input monthly?", preferredStyle: .alert)
        let noRemiderAction = UIAlertAction(title: "NO", style: .destructive)
        let yesRemiderAction = UIAlertAction(title: "YES", style: .default) { (action) in
            self.presentAlertAddMonthlyIncomes()
        }
        alertController.addAction(yesRemiderAction)
        alertController.addAction(noRemiderAction)
        present(alertController, animated: true)
    }
    
    func presentAlertAddMonthlyIncomes() {
        guard let name = incomeNameTextField.text, !name.isEmpty else {
            if incomeAmountTextField.text?.isEmpty == true  {
                presentAlertToUser(titleAlert: "INCOME'S INPUT NEEDED!", messageAlert: "Add name and amount for setting an income to be automatically input monthly!")
            } else {
                presentAlertToUser(titleAlert: "INCOME'S NAME NEEDED!", messageAlert: "Add income's name for setting an income to be automatically input monthly!")
            }
            return
        }
        guard let amount = self.incomeAmountTextField.text, !amount.isEmpty else {
            presentAlertToUser(titleAlert: "INCOME'S AMOUNT NEEDED!", messageAlert: "Add income's amount for setting an income to be automatically input monthly!")
            return
        }
        let amountInString = AmountFormatter.currencyInString(num: Double(amount) ?? 0.0)
        guard let selectedIncomeCategory = selectedIncomeCategory else {return}
        let alertController = UIAlertController(title: "SET INCOME MONTHLY INPUT!", message: "Name : \(name.capitalized) \nAmount : \(amountInString) \nCategory : \(selectedIncomeCategory.nameString.capitalized) \nMothly Paid Date : \(incomeDatePicker.date.dateToString(format: .onlyDate))", preferredStyle: .alert)
        let noAction = UIAlertAction(title: "CANCEL", style: .destructive)
        let yesSixMonthsAction = UIAlertAction(title: "SET FOR 6 MONTHS!", style: .default) { (action) in
            if let income = self.income {
                IncomeController.shared.updateWith(income, name: name, amount: Double(amount) ?? 00.00, category: selectedIncomeCategory, date: self.incomeDatePicker.date, note: self.incomeNoteTextView.text)
                let imageData = self.incomeImageView.image?.jpegData(compressionQuality: 0.7)
                let fiveMonths = self.incomeDatePicker.date.getUpdateRepeatedDatesForSixMonths()
                IncomeController.shared.createMonthlyIncomesWith(name: name, amount: Double(amount) ?? 00.00, category: selectedIncomeCategory, date: self.incomeDatePicker.date, note: self.incomeNoteTextView.text, image: imageData, repeatedDuration: fiveMonths)
            } else {
                let imageData = self.incomeImageView.image?.jpegData(compressionQuality: 0.7)
                let sixMonths = self.incomeDatePicker.date.getRepeatedDatesForSixMonths()
                IncomeController.shared.createMonthlyIncomesWith(name: name, amount: Double(amount) ?? 00.00, category: selectedIncomeCategory, date: self.incomeDatePicker.date, note: self.incomeNoteTextView.text, image: imageData, repeatedDuration: sixMonths)
            }
            self.navigationController?.popViewController(animated: true)
        }
        let yesOneYearAction = UIAlertAction(title: "SET FOR 1 YEAR!", style: .default) { (action) in
            if let income = self.income {
                IncomeController.shared.updateWith(income, name: name, amount: Double(amount) ?? 00.00, category: selectedIncomeCategory, date: self.incomeDatePicker.date, note: self.incomeNoteTextView.text)
                let imageData = self.incomeImageView.image?.jpegData(compressionQuality: 0.7)
                let elevenMonths = self.incomeDatePicker.date.getUpdateRepeatedDatesForAYear()
                IncomeController.shared.createMonthlyIncomesWith(name: name, amount: Double(amount) ?? 00.00, category: selectedIncomeCategory, date: self.incomeDatePicker.date, note: self.incomeNoteTextView.text, image: imageData, repeatedDuration: elevenMonths)
            } else {
                let imageData = self.incomeImageView.image?.jpegData(compressionQuality: 0.7)
                let oneYear = self.incomeDatePicker.date.getRepeatedDatesForAYear()
                IncomeController.shared.createMonthlyIncomesWith(name: name, amount: Double(amount) ?? 00.00, category: selectedIncomeCategory, date: self.incomeDatePicker.date, note: self.incomeNoteTextView.text, image: imageData, repeatedDuration: oneYear)
            }
            self.navigationController?.popViewController(animated: true)
        }
        let yesTwoYearAction = UIAlertAction(title: "SET FOR 2 YEARS!", style: .default) { (action) in
            if let income = self.income {
                IncomeController.shared.updateWith(income, name: name, amount: Double(amount) ?? 00.00, category: selectedIncomeCategory, date: self.incomeDatePicker.date, note: self.incomeNoteTextView.text)
                let imageData = self.incomeImageView.image?.jpegData(compressionQuality: 0.7)
                let twentyThreeMonths = self.incomeDatePicker.date.getUpdateRepeatedDatesForTwoYears()
                IncomeController.shared.createMonthlyIncomesWith(name: name, amount: Double(amount) ?? 00.00, category: selectedIncomeCategory, date: self.incomeDatePicker.date, note: self.incomeNoteTextView.text, image: imageData, repeatedDuration: twentyThreeMonths)
            } else {
                let imageData = self.incomeImageView.image?.jpegData(compressionQuality: 0.7)
                let twoYears = self.incomeDatePicker.date.getRepeatedDatesForTwoYears()
                IncomeController.shared.createMonthlyIncomesWith(name: name, amount: Double(amount) ?? 00.00, category: selectedIncomeCategory, date: self.incomeDatePicker.date, note: self.incomeNoteTextView.text, image: imageData, repeatedDuration: twoYears)
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
