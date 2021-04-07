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
    
    // MARK: - Life Cycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        pieChartView.delegate = self
        updateViewsByTime(startedTime: Date().startDateOfMonth, endedTime: Date().endDateOfMonth)
        isAppAlreadyLaunched()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
//        activityIndicator.isHidden = false
//        activityIndicator.startAnimating()
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
            updateViewsByTime(startedTime: Date().startDateOfMonth, endedTime: Date().endOfWeek)
        case 2:
            updateViewsByTime(startedTime: self.yearly, endedTime: Date())
        default:
            updateViewsByTime(startedTime: Date().startDateOfMonth, endedTime: Date().endOfWeek)
        }
//        activityIndicator.isHidden = false
//        activityIndicator.startAnimating()
    }

    @IBAction func doccumentButtonTapped(_ sender: Any) {
        let alertController = UIAlertController(title: "Moneytor Document!",
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
    
    @IBAction func totalIncomeButtonTapped(_ sender: Any) {
    
    }
    
    
    @IBAction func totalExpenseButtonTapped(_ sender: Any) {
    
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
}

//MARK : Extension ChartViewDelegate
extension TotalBalanceViewController: ChartViewDelegate  {
    
    func setUpPieChartWith(totalIncome: Double, totalExpense: Double) {
//        activityIndicator.isHidden = false
//        activityIndicator.startAnimating()
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
        print("\n INCOME PERCENT ::: \(incomePercent)")
        let expensePercent: Double = totalExpense / (totalIncome + totalExpense)
        print("\n EXPENSE PERCENT ::: \(expensePercent)")
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

extension TotalBalanceViewController {
    func presentFirstLoginAlert() {
        let alertController = UIAlertController(title: "Welcome to InEx Moneytor!", message: "Add Income and expense to keep tracking your money. If you have used this app before, your income and expense data will be downloaded from your iCloud shortly.", preferredStyle: .alert)
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
