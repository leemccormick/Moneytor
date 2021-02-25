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
    
    
    // MARK: - Properties
    
    
    
    // MARK: - Life Cycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        pieChartView.delegate = self
        setUpPieChart()
    }
    
    // MARK: - Actions
    @IBAction func totalIncomeButtonTapped(_ sender: Any) {
    }
    
    
    @IBAction func totalExpenseButtonTapped(_ sender: Any) {
    }
    


}


//MARK : Extension ChartViewDelegate

extension TotalBalanceViewController: ChartViewDelegate  {
    
    func setUpPieChart() {
        
        //setup pieview
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
        
        //set up data for pieView
//        let incomePercent: Double = totalIncomes / (totalIncomes + totalExpenses)
//        let expensePercent: Double = totalExpenses / (totalIncomes + totalExpenses)
//
//        var strIncomePercent : String {
//            Formatter.numberFormatterInPercent.string(for: incomePercent)!
//        }
//        var strExpensePercent : String {
//            Formatter.numberFormatterInPercent.string(for: expensePercent)!
//        }
        var entries: [PieChartDataEntry] = Array()
        entries.append(PieChartDataEntry(value: 1000.00, label: "Income \n\(75)"))
        entries.append(PieChartDataEntry(value: 250.00, label: "Expense \n\(25)"))
        
        let dataSet = PieChartDataSet(entries: entries, label: "")
        dataSet.colors = ChartColorTemplates.pastel()
        dataSet.drawValuesEnabled = false
        
        pieChartView.data = PieChartData(dataSet: dataSet)
    }
}


