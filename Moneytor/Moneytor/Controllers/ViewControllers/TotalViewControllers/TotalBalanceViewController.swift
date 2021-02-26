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
    
    
//    // MARK: - Properties
//    var totalBalance: Double = TotalController.shared.totalBalance {
//        didSet {
//            loadViewIfNeeded()
//            totalBalanceLabel.text = "\(totalBalance)"
//
//        }
//    }
//
//    var totalIncome: Double = 0.0 {
//    didSet {
//        totalIncome = TotalController.shared.totalIncome
//        setUpPieChartWith(totalIncome: totalIncome, totalExpense: totalExpense)
//        }
//    }
//
//    var totalExpense: Double = 0.0 {
//        didSet {
//            setUpPieChartWith(totalIncome: totalIncome, totalExpense: totalExpense)
//        }
//    }
    
    
    
    // MARK: - Life Cycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
//
//        TotalController.shared.calculateTotalIncome()
//        TotalController.shared.calculateTotalExpense()
     //   TotalController.shared.calculateTotalBalance()
//        print("\n ::: totalIncome in ViewDidLoad TotalBalance Controller : \(totalIncome)")
//        print("\n ::: totalExpense in ViewDidLoad TotalBalance Controller : \(totalExpense)")
//        print("\n ::: totalBalance in ViewDidLoad TotalBalance Controller : \(totalBalance)")

        pieChartView.delegate = self
             // setUpPieChartWith(totalIncome: <#T##Double#>, totalExpense: <#T##Double#>)()

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //totalBalanceLabel.text = "1000000000000"
        TotalController.shared.calculateTotalBalance()

         // TotalController.shared.calculateTotalIncome()
//          TotalController.shared.calculateTotalExpense()
//         TotalController.shared.calculateTotalBalance()
//          print("\n ::: totalIncome in viewWillAppear TotalBalance Controller : \(totalIncome)")
//          print("\n ::: totalExpense in viewWillAppear TotalBalance Controller : \(totalExpense)")
//          print("\n ::: totalBalance in viewWillAppear TotalBalance Controller : \(totalBalance)")
       // totalBalanceLabel.text = "\(TotalController.shared.totalBalance)"

       // print(totalBalance)
        updateViews()
    }
    
    // MARK: - Actions
    @IBAction func totalIncomeButtonTapped(_ sender: Any) {
    }
    
    
    @IBAction func totalExpenseButtonTapped(_ sender: Any) {
    }
    
// MARK: - Helper Fuctions
    func updateViews() {
        let totalIncome = TotalController.shared.totalIncome
        let totalExpense = TotalController.shared.totalExpense
        let totalBalanceStr = TotalController.shared.totalBalanceString
        let totalIncomeCurrencyStr = TotalController.shared.totalIncomeString
        let totalExpenseCurrencyStr = TotalController.shared.totalExpenseString
        totalBalanceLabel.text = totalBalanceStr
        totalIncomeButton.setTitle(totalIncomeCurrencyStr, for: .normal)
        totalExpenseButton.setTitle(totalExpenseCurrencyStr, for: .normal)
        setUpPieChartWith(totalIncome: totalIncome, totalExpense: totalExpense)
    }

}


//MARK : Extension ChartViewDelegate

extension TotalBalanceViewController: ChartViewDelegate  {
    
    func setUpPieChartWith(totalIncome: Double, totalExpense: Double) {
        
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
        let incomePercent: Double = totalIncome / (totalIncome + totalExpense)
        print("\n INCOME PERCENT ::: \(incomePercent)")
        let expensePercent: Double = totalExpense / (totalIncome + totalExpense)
        print("\n EXPENSE PERCENT ::: \(expensePercent)")
        let incomePercentString = AmountFormatter.percentInString(num: incomePercent)
        let expensePercentString = AmountFormatter.percentInString(num: expensePercent)
//
//        var strIncomePercent : String {
//            Formatter.numberFormatterInPercent.string(for: incomePercent)!
//        }
//        var strExpensePercent : String {
//            Formatter.numberFormatterInPercent.string(for: expensePercent)!
//        }
        
        
        var entries: [PieChartDataEntry] = Array()
        entries.append(PieChartDataEntry(value: incomePercent, label: "Income \(incomePercentString)"))
        entries.append(PieChartDataEntry(value: expensePercent, label: "Expense \(expensePercentString)"))
        
        let dataSet = PieChartDataSet(entries: entries, label: "")
        dataSet.colors = ChartColorTemplates.pastel()
        dataSet.drawValuesEnabled = false
        
        pieChartView.data = PieChartData(dataSet: dataSet)
    }
}


