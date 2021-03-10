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
    
    // MARK: - Properties
    let weekly = TotalController.shared.weekly
    let monthly = TotalController.shared.monthly
    let yearly = TotalController.shared.yearly
   
    // MARK: - Life Cycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        pieChartView.delegate = self
        updateViewsByTime(monthly)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        timeSegmentedControl.selectedSegmentIndex = 1
        TotalController.shared.calculateTotalBalanceBySpecificTime(monthly)
        updateViewsByTime(monthly)
    }
    
    // MARK: - Actions
    
    
    @IBAction func timeSegmentedControlValuedChanged(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0:
            updateViewsByTime(weekly)
        case 1:
            updateViewsByTime(monthly)
        case 2:
            updateViewsByTime(yearly)
        default:
            updateViewsByTime(monthly)
        }
        
    }
    
    
    @IBAction func calendarButtonTapped(_ sender: Any) {
       // presentAlertForSpecificDateToDisplayTotalBalance()
    }
    
    @IBAction func totalIncomeButtonTapped(_ sender: Any) {
    }
    
    
    @IBAction func totalExpenseButtonTapped(_ sender: Any) {
    }
    
    // MARK: - Helper Fuctions
    func updateViewsByTime(_ time: Date) {
        TotalController.shared.calculateTotalExpensesBySpecificTime(time)
        TotalController.shared.calculateTotalIncomesBySpecificTime(time)
        TotalController.shared.calculateTotalBalanceBySpecificTime(time)
       
        let totalIncome = TotalController.shared.totalIncomeBySpecificTime
        let totalExpense = TotalController.shared.totalExpenseBySpecificTime
       // let totalBalance = TotalController.shared.totalBalanceBySpecificTime
       
        let totalIncomeCurrencyStr = TotalController.shared.totalIncomeBySpecificTimeString
        let totalExpenseCurrencyStr = TotalController.shared.totalExpensesBySpecificTimeString
        
        let totalBalanceStr = TotalController.shared.totalBalanceBySpecificTimeString
        totalBalanceLabel.text = totalBalanceStr
        totalIncomeButton.setTitle(totalIncomeCurrencyStr, for: .normal)
        totalExpenseButton.setTitle(totalExpenseCurrencyStr, for: .normal)
        setUpPieChartWith(totalIncome: totalIncome, totalExpense: totalExpense)
    }
}

//MARK : Extension ChartViewDelegate
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

