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
            return 1
        case 1:
            return 1
        case 2:
            return 3
        case 3:
            return 1
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
            return CGFloat(40.0)
        case 1:
            return CGFloat(40.0)
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
                let imageData = self.incomeImageView.image?.jpegData(compressionQuality: 0.7)
                IncomeController.shared.createIncomeAndNotificationWith(name: name, amount: Double(amount) ?? 00.00, category: selectedIncomeCategory, date: self.incomeDatePicker.date, note: self.incomeNoteTextView.text, image: imageData)
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
        let dismissAction = UIAlertAction(title: "Cancel", style: .cancel)
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
        alertController.addAction(dismissAction)
        alertController.addAction(doSomethingAction)
        present(alertController, animated: true)
    }
}
