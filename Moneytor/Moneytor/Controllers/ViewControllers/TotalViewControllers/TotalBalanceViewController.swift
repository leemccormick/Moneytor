//
//  TotalBalanceViewController.swift
//  Moneytor
//
//  Created by Lee McCormick on 2/22/21.
//

import UIKit
import Charts

class TotalBalanceViewController: UIViewController {
    
    // MARK: - Outlets
    @IBOutlet weak var pieChartView: PieChartView!
    @IBOutlet weak var totalBalanceLabel: UILabel!
    @IBOutlet weak var totalIncomeButton: UIButton!
    @IBOutlet weak var totalExpenseButton: UIButton!
    @IBOutlet weak var activityView: UIView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var timeSegmentedControl: UISegmentedControl!
    @IBOutlet weak var dateDetailLabel: MoneytorGoodLetterLabel!
    
    // MARK: - Properties
    let weekly = TotalController.shared.weekly
    let monthly = TotalController.shared.monthly
    let yearly = TotalController.shared.yearly
    var startDateIncomeStatement: Date?
    var endDateIncomeStatement: Date?
    let datePicker = UIDatePicker()
    
    // MARK: - Life Cycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        pieChartView.delegate = self
        updateViewsByTime(startedTime: Date().startDateOfMonth, endedTime: Date().endDateOfMonth)
        isAppAlreadyLaunched()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        timeSegmentedControl.selectedSegmentIndex = 1
        TotalController.shared.calculateTotalBalanceBySpecificTime(startedTime: Date().startDateOfMonth, endedTime: Date().endDateOfMonth)
        updateViewsByTime(startedTime: Date().startDateOfMonth, endedTime: Date().endDateOfMonth)
    }
    
    // MARK: - Actions
    @IBAction func timeSegmentedControlValuedChanged(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0:
            updateViewsByTime(startedTime: Date().startOfWeek, endedTime: Date().endOfWeek)
        case 1:
            updateViewsByTime(startedTime: Date().startDateOfMonth, endedTime: Date().endDateOfMonth)
        case 2:
            updateViewsByTime(startedTime: self.yearly, endedTime: Date())
        default:
            updateViewsByTime(startedTime: Date().startDateOfMonth, endedTime: Date().endOfWeek)
        }
    }
    
    @IBAction func doccumentButtonTapped(_ sender: Any) {
        let alertController = UIAlertController(title: "MindMoney Document!",
                                                message: "Learn more about how to scan income and expense amount!" ,preferredStyle: .alert)
        
        let dismissAction = UIAlertAction(title: "Cancel", style: .cancel)
        let IncomeAction = UIAlertAction(title: "Income Document!", style: .default) { (action) in
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let expenseDocVC = storyboard.instantiateViewController(identifier: "incomeDocStoryBoardID")
            expenseDocVC.modalPresentationStyle = .pageSheet
            self.present(expenseDocVC, animated: true, completion: nil)
        }
        let expenseAction = UIAlertAction(title: "Expense Document!", style: .default) { (action) in
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let expenseDocVC = storyboard.instantiateViewController(identifier: "expenseDocStoryBoardID")
            expenseDocVC.modalPresentationStyle = .pageSheet
            self.present(expenseDocVC, animated: true, completion: nil)
        }
        alertController.addAction(dismissAction)
        alertController.addAction(IncomeAction)
        alertController.addAction(expenseAction)
        present(alertController, animated: true)
    }
    
    @IBAction func seeIncomeStatementBarButtonTapped(_ sender: Any) {
        presentAlertGoToIncomeStatement()
    }
    
    // MARK: - Helper Fuctions
    func updateViewsByTime(startedTime: Date, endedTime: Date) {
        activityIndicator.isHidden = false
        activityIndicator.startAnimating()
        TotalController.shared.calculateTotalExpensesBySpecificTime(startedTime: startedTime, endedTime: endedTime)
        TotalController.shared.calculateTotalIncomesBySpecificTime(startedTime: startedTime, endedTime: endedTime)
        TotalController.shared.calculateTotalBalanceBySpecificTime(startedTime: startedTime, endedTime: endedTime)
        
        let totalIncome = TotalController.shared.totalIncomeBySpecificTime
        let totalExpense = TotalController.shared.totalExpenseBySpecificTime
        let totalIncomeCurrencyStr = TotalController.shared.totalIncomeBySpecificTimeString
        let totalExpenseCurrencyStr = TotalController.shared.totalExpensesBySpecificTimeString
        let totalBalanceStr = TotalController.shared.totalBalanceBySpecificTimeString
        dateDetailLabel.text = "\(startedTime.dateToString(format: .monthDayYear)) - \(endedTime.dateToString(format: .monthDayYear))"
        totalBalanceLabel.text = totalBalanceStr
        totalIncomeButton.setTitle(totalIncomeCurrencyStr, for: .normal)
        totalExpenseButton.setTitle(totalExpenseCurrencyStr, for: .normal)
        setUpPieChartWith(totalIncome: totalIncome, totalExpense: totalExpense)
    }
    
    
    // MARK: - Income Statement
    //================================================WORKING ON THIS STATEMENT FOR VERSION ===========
    // =======Update Category Name ==================
    // =========== Add Paid by Credit Card ==================
    func presentAlertGoToIncomeStatement() {
        print("\n\n\n\n\n=================== GO TO INCOME STATMENT======================IN \(#function)\n\n\n\n")
        
        let alertController = UIAlertController(title: "Income Statement",
                                                message: "If you would like to see your income statement by specific date, please enter the start date and end date for the income statement." ,preferredStyle: .alert)
        alertController.addTextField { [self] (startDateTextField) in
            startDateTextField.placeholder = "Start Date"
            startDateTextField.keyboardAppearance = .dark
            //textField.keyboardType = .decimalPad
            self.createDatePicker(textField: startDateTextField)
            
            startDateTextField.text = startDateIncomeStatement?.dateToString(format: .short) ?? Date().dateToString(format: .short)
            
        }
        
        alertController.addTextField { [self] (endDateTextField) in
            endDateTextField.placeholder = "End Date"
            endDateTextField.keyboardAppearance = .dark
            self.createDatePicker(textField: endDateTextField)
            endDateTextField.text = endDateIncomeStatement?.dateToString(format: .short) ?? Date().dateToString(format: .short)
            
            
        }
        
        
        let seeStatementAction = UIAlertAction(title: "See Statement", style: .default) { (action) in
            self.goToTotalIncomeStatementVC()
        }
        let dismissAction = UIAlertAction(title: "Cancel", style: .destructive)
        
        alertController.addAction(seeStatementAction)
        alertController.addAction(dismissAction)
        
        present(alertController, animated: true)
    }
    
    func goToTotalIncomeStatementVC() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let totalIncomeStatementVC = storyboard.instantiateViewController(identifier: "totalIncomeStatementNavigationStoryBoardID")
        totalIncomeStatementVC.modalPresentationStyle = .pageSheet
        self.present(totalIncomeStatementVC, animated: true, completion: nil)
    }
    
    func createDatePicker(textField: UITextField) {
        //let datePicker = UIDatePicker()
        datePicker.datePickerMode = .date
        datePicker.preferredDatePickerStyle = .wheels
        datePicker.calendar = .current
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        
        let saveButton = UIBarButtonItem(barButtonSystemItem: .save, target: nil, action: #selector(saveButtonTapped))
        toolbar.setItems([saveButton], animated: true)
        textField.inputAccessoryView = toolbar
        textField.inputView = datePicker
    }
    
    @objc func saveButtonTapped() {
        startDateIncomeStatement = datePicker.date
        endDateIncomeStatement = datePicker.date
        
        self.view.endEditing(true)
    }
}
//================================================WORKING ON THIS STATEMENT FOR VERSION ===========

// MARK: -  ChartViewDelegate
extension TotalBalanceViewController: ChartViewDelegate  {
    
    func setUpPieChartWith(totalIncome: Double, totalExpense: Double) {
        pieChartView.noDataText = "No Data available! Enter data of your expense and income."
        pieChartView.chartDescription?.enabled = false
        pieChartView.drawHoleEnabled = false
        pieChartView.rotationAngle = 0
        pieChartView.rotationEnabled = true
        pieChartView.isUserInteractionEnabled = true
        pieChartView.entryLabelFont = UIFont(name: FontNames.textMoneytorGoodLetter, size: 20)!
        pieChartView.entryLabelColor = UIColor.yellow
        pieChartView.drawEntryLabelsEnabled = true
        pieChartView.legend.textColor = UIColor.brown
        pieChartView.legend.font = UIFont(name: FontNames.textMoneytorGoodLetter, size: 20)!
        pieChartView.legend.verticalAlignment = .bottom
        pieChartView.legend.horizontalAlignment = .center
        
        let incomePercent: Double = totalIncome / (totalIncome + totalExpense)
        let expensePercent: Double = totalExpense / (totalIncome + totalExpense)
        let incomePercentString = AmountFormatter.percentInString(num: incomePercent)
        let expensePercentString = AmountFormatter.percentInString(num: expensePercent)
        
        var entries: [PieChartDataEntry] = Array()
        entries.append(PieChartDataEntry(value: incomePercent, label: "Income \(incomePercentString)", data: "income"))
        entries.append(PieChartDataEntry(value: expensePercent, label: "Expense \(expensePercentString)", data: "expense"))
        
        let dataSet = PieChartDataSet(entries: entries, label: "")
        dataSet.colors = ChartColorTemplates.pastel()
        dataSet.drawValuesEnabled = false
        pieChartView.data = PieChartData(dataSet: dataSet)
        activityIndicator.stopAnimating()
        activityIndicator.isHidden = true
    }
    
    func chartValueSelected(_ chartView: ChartViewBase, entry: ChartDataEntry, highlight: Highlight) {
        
        let data: String  = entry.data! as! String
        
        if data == "income" {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let totalIncomeVC = storyboard.instantiateViewController(identifier: "totalIncomeVCStoryBoardId")
            totalIncomeVC.modalPresentationStyle = .popover
            self.present(totalIncomeVC, animated: true, completion: nil)
            
        } else {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let totalIncomeVC = storyboard.instantiateViewController(identifier: "totalExpenseVCStoryBoardId")
            totalIncomeVC.modalPresentationStyle = .popover
            self.present(totalIncomeVC, animated: true, completion: nil)
        }
    }
}

// MARK: - Alert For FirstLunch
extension TotalBalanceViewController {
    func presentFirstLoginAlert() {
        let alertController = UIAlertController(title: "Welcome to MindMoney!", message: "Add Income and expense to keep tracking your money. If you have used this app before, your income and expense data will be downloaded from your iCloud shortly.", preferredStyle: .alert)
        let dismissAction = UIAlertAction(title: "Ok", style: .cancel)
        alertController.addAction(dismissAction)
        present(alertController, animated: true)
    }
    
    func isAppAlreadyLaunched() {
        let hasBeenLaunched = UserDefaults.standard.bool(forKey: "hasBeenLaunched")
        if hasBeenLaunched {
            return
        } else {
            presentFirstLoginAlert()
            UserDefaults.standard.set(true, forKey: "hasBeenLaunched")
        }
    }
}











