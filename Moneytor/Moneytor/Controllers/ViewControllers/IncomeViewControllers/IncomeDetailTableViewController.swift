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
    
    // MARK: - Properties
    var income: Income?
    //var selectedIncomeCategory: IncomeCategory = IncomeCategoryController.shared.incomeCategories[0]
    var selectedIncomeCategory: IncomeCategory?
    let textRecognizationQueue = DispatchQueue.init(label: "TextRecognizationQueue", qos: .userInitiated, attributes: [], autoreleaseFrequency: .workItem, target: nil)
    var requests = [VNRequest]()
    
    // MARK: - Life Cycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupToHideKeyboardOnTapOnView()
        incomeCategoryPicker.delegate = self
        incomeCategoryPicker.dataSource = self
        incomeNameTextField.delegate = self
        incomeAmountTextField.delegate = self
        IncomeCategoryController.shared.fetchAllIncomeCategories()
        if IncomeCategoryController.shared.incomeCategories.count == 0 {
            let newCategory = IncomeCategoryController.shared.createIncomeDefaultCategories(name: "_other", emoji: "💵")
            guard let upwrapNewCategory = newCategory else {return}
            selectedIncomeCategory = upwrapNewCategory
        }
        selectedIncomeCategory = IncomeCategoryController.shared.incomeCategories.first
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.incomeNoteTextView.text = "Take a note for your income here or scan document for income's detail..."
        self.incomeNameTextField.text = ScannerController.shared.name
        self.incomeAmountTextField.text = ScannerController.shared.amount
        self.incomeDatePicker.date = ScannerController.shared.date.toDate() ?? Date()
        self.incomeNoteTextView.text = ScannerController
            .shared.note
        IncomeCategoryController.shared.fetchAllIncomeCategories()
        incomeCategoryPicker.reloadAllComponents()
        updateViews()
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
       // IncomeDetailTableViewController.scannerButtonTapped(self.)
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
    
    func scanReceiptForIncomeResult() {
        ScannerController.shared.deleteNameAmountAndNote()
        let documentCameraController = VNDocumentCameraViewController()
        documentCameraController.delegate = self
        self.present(documentCameraController, animated: true, completion: nil)
    }
    
    // MARK: - Helper Fuctions
    func updateViews() {
        guard let income = income else {
            self.navigationItem.title = "Add Income"
            return
        }
        self.navigationItem.title = "Update Income"
        selectedIncomeCategory = income.incomeCategory ?? IncomeCategoryController.shared.incomeCategories[0]
        incomeNameTextField.text = income.name
        incomeAmountTextField.text = income.incomeAmountStringToUpdate
        incomeDatePicker.date = income.date ?? Date()
        incomeNoteTextView.text = income.note
        
        let numberOfRows = IncomeCategoryController.shared.incomeCategories.count
        for row in 0..<numberOfRows {
            if income.incomeCategory == IncomeCategoryController.shared.incomeCategories[row] {
                incomeCategoryPicker.selectRow(row, inComponent: 0, animated: true)
            }
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
            IncomeController.shared.createIncomeWith(name: name, amount: Double(amount) ?? 00.00, category: selectedIncomeCategory, date: incomeDatePicker.date, note: incomeNoteTextView.text)
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
        } else if section == 5{
            return CGFloat(0.0)
        }else {
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
        textField.text = ""
        return true
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        textField.text = ""
        return true
    }
}
// MARK: - Income Notification
extension IncomeDetailTableViewController {
    
    func presentAlertAskingUserIfRemindedNeeded(){
        let alertController = UIAlertController(title: "INCOME REMINDER!", message:"Would you like to get notification when you get paid?", preferredStyle: .alert)
        let noRemiderAction = UIAlertAction(title: "NO", style: .cancel)
        let yesRemiderAction = UIAlertAction(title: "YES", style: .destructive) { (action) in
            self.presentAlertAddIncomeNotification()
        }
        alertController.addAction(noRemiderAction)
        alertController.addAction(yesRemiderAction)
        present(alertController, animated: true)
    }
    
    func  presentAlertAddIncomeNotification() {
        guard let name = incomeNameTextField.text, !name.isEmpty else {
            if incomeAmountTextField.text?.isEmpty == true  {
                presentAlertToUser(titleAlert: "INCOME'S INPUT NEEDED FOR NOTIFICATION!", messageAlert: "Add name and amount for remider!")
            } else {
                presentAlertToUser(titleAlert: "INCOME'S NAME NEEDED FOR NOTIFICATION!", messageAlert: "Add income's name for your remider!")
            }
            return
        }
        guard let amount = self.incomeAmountTextField.text, !amount.isEmpty else {
            presentAlertToUser(titleAlert: "INCOME'S AMOUNT NEEDED FOR NOTIFICATION!!", messageAlert: "Add income's amount for your remider!")
            return
        }
        
        guard let selectedIncomeCategory = selectedIncomeCategory else {return}
        
        let alertController = UIAlertController(title: "SET REMIDER FOR THIS INCOME!", message: "Name : \(name.capitalized) \nAmount : \(amount) \nCategory : \(selectedIncomeCategory.nameString.capitalized) \nPaid Date : \(incomeDatePicker.date.dateToString(format: .monthDayYear))", preferredStyle: .alert)
        let noAction = UIAlertAction(title: "CANCEL", style: .cancel)
        let yesAction = UIAlertAction(title: "YES, SET REMINDER!", style: .destructive) { (action) in
            guard let selectedIncomeCategory = self.selectedIncomeCategory else {return}
            if let income = self.income {
                IncomeController.shared.updateIncomeWithNotification(income, name: name, amount: Double(amount) ?? 00.00, category: selectedIncomeCategory, date: self.incomeDatePicker.date, note: self.incomeNoteTextView.text)
            } else {
                IncomeController.shared.createIncomeAndNotificationWith(name: name, amount: Double(amount) ?? 00.00, category: selectedIncomeCategory, date: self.incomeDatePicker.date, note: self.incomeNoteTextView.text)
            }
            self.navigationController?.popViewController(animated: true)
        }
        alertController.addAction(yesAction)
        alertController.addAction(noAction)
        present(alertController, animated: true)
    }
}

// MARK: - VNDocumentCameraViewControllerDelegate
extension IncomeDetailTableViewController: VNDocumentCameraViewControllerDelegate {
    func documentCameraViewController(_ controller: VNDocumentCameraViewController, didFinishWith scan: VNDocumentCameraScan) {
        controller.dismiss(animated: true, completion: nil)
        for i in 0..<scan.pageCount {
            let scannedImage = scan.imageOfPage(at: i)
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
        presentAlertToUser(titleAlert: "CANCELED!", messageAlert: "Income document scanner have been cancled!")
        
//        let alertController = UIAlertController(title: "CANCEL! INCOME SCANNER!", message: "", preferredStyle: .alert)
//        let cancelAction = UIAlertAction(title: "CANCEL", style: .destructive) { (action) in
//
//        }
//        alertController.addAction(cancelAction)
//        present(alertController, animated: true)
    }
    
    func documentCameraViewController(_ controller: VNDocumentCameraViewController, didFailWithError error: Error) {
        
        controller.dismiss(animated: true, completion: nil)
        print("\n==== ERROR SCANNING RECEIPE IN \(#function) : \(error.localizedDescription) : \(error) ====\n")
        presentAlertToUser(titleAlert: "ERROR! SCANNING INCOME!", messageAlert: "Please, make sure if you are using camera propertly to scan income!")
        
//        let alertController = UIAlertController(title: "ERROR! SCANNING INCOME!", message: "Please, make sure if you are using camera propertly to scan income!", preferredStyle: .alert)
//        let cancelAction = UIAlertAction(title: "OK", style: .destructive) { (action) in
//            controller.dismiss(animated: true, completion: nil)
//        }
//        alertController.addAction(cancelAction)
//        present(alertController, animated: true)
      
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
       // textField.
    }
    
    alertController.addTextField { (nameTextFiled) in
        nameTextFiled.placeholder = "Enter a name for category..."
        nameTextFiled.keyboardAppearance = .dark
        nameTextFiled.keyboardType = .default
       // textField.
    }
    let dismissAction = UIAlertAction(title: "Cancel", style: .cancel)
    let doSomethingAction = UIAlertAction(title: "Add New Category", style: .default) { (action) in
        //DO SOMETHING HERE....
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
    alertController.addAction(dismissAction)
    alertController.addAction(doSomethingAction)
    present(alertController, animated: true)
}
}
