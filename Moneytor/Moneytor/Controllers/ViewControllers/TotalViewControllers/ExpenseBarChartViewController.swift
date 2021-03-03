//
//  ExpenseBarChartViewController.swift
//  Moneytor
//
//  Created by Lee McCormick on 2/23/21.
//

import UIKit
import Charts

class ExpenseBarChartViewController: UIViewController {

    // MARK: - Outlets
    @IBOutlet var barChartView: BarChartView!
 
    
    
    
    // MARK: - Properties
    var expenseCategoriesSum = [2,3,4,5,6,73,12,5]
    var expenseDictionary: [Dictionary<String, Double>.Element] = ExpenseCategoryController.shared.expenseCategoriesTotalDict {
        didSet {
            
            setupBarChart(expenseDict: expenseDictionary)
            //loadViewIfNeeded()

        }
    }
    
    
    // MARK: - Life Cycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        barChartView.delegate = self
        setupBarChart(expenseDict: expenseDictionary)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        ExpenseCategoryController.shared.fetchAllExpenseCategories()
       // Income
        ExpenseCategoryController.shared.generateSectionsAndSumEachExpenseCategory()
        expenseDictionary = ExpenseCategoryController.shared.expenseCategoriesTotalDict
        setupBarChart(expenseDict: expenseDictionary)
        print("----------------- :: viewWillAppear-----------------")

    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.popViewController(animated: true)
    }
    

}

extension ExpenseBarChartViewController:  ChartViewDelegate {
    
    func setupBarChart(expenseDict: [Dictionary<String, Double>.Element]){
        
        //setup data
        barChartView.noDataText = "No Expense Data available for Chart."
       // var labels: [String] = []
        var dataEntries: [BarChartDataEntry] = []
        
        var i = 0
        for expenseCategory in expenseDict {
            let dataEntry = BarChartDataEntry(x: Double(i), y: Double(expenseCategory.value), data: nil)
                        dataEntries.append(dataEntry)
                        let chartDataSet = BarChartDataSet(entries: dataEntries, label: nil)
            chartDataSet.colors = ChartColorTemplates.pastel()
                        chartDataSet.drawValuesEnabled = true
            
                        let charData = BarChartData(dataSet: chartDataSet)
                        charData.setDrawValues(true)
                        charData.setValueFont(.boldSystemFont(ofSize: 10))
                        barChartView.data = charData
            i += 1
            
        }
        
        
//        for i in 0..<self.expenseCategoriesSum.count {
//            let dataEntry = BarChartDataEntry(x: Double(i), y: self.sumArr[i], data: catagotiesArr[i])
//            labels.append(catagotiesArr[i])
//            dataEntries.append(dataEntry)
//            let chartDataSet = BarChartDataSet(entries: dataEntries, label: labels[i])
//            chartDataSet.colors = ChartColorTemplates.colorful()
//            chartDataSet.drawValuesEnabled = true
//
//            let charData = BarChartData(dataSet: chartDataSet)
//            charData.setDrawValues(true)
//            charData.setValueFont(.boldSystemFont(ofSize: 10))
//            barChartView.data = charData
//
//        }
        
        
        //setup BarChartView
        let yAxis = barChartView.leftAxis
        yAxis.labelFont = .boldSystemFont(ofSize: 12)
        yAxis.setLabelCount(6, force: false)
        yAxis.labelTextColor = .brown
        yAxis.axisLineColor = .brown
        yAxis.labelPosition = .outsideChart
            
        barChartView.legend.enabled = false
        barChartView.isUserInteractionEnabled = true
        barChartView.pinchZoomEnabled = false
        barChartView.doubleTapToZoomEnabled = false
        barChartView.dragEnabled = false
        barChartView.dragDecelerationEnabled = false
       /// barChartView.xAxis.valueFormatter = IndexAxisValueFormatter(values:labels)
        barChartView.xAxis.granularityEnabled = true
        barChartView.xAxis.granularity = 1.0
        barChartView.leftAxis.forceLabelsEnabled = true
        barChartView.rightAxis.forceLabelsEnabled = true
        barChartView.xAxis.granularityEnabled = true
        barChartView.animate(xAxisDuration: 3.0, yAxisDuration: 3.0, easingOption: .easeInOutBounce)
        barChartView.chartDescription?.text = ""
        barChartView.leftAxis.drawGridLinesEnabled = true
        barChartView.rightAxis.drawGridLinesEnabled = true
        barChartView.xAxis.drawGridLinesEnabled = false
        barChartView.rightAxis.enabled = false
        barChartView.drawGridBackgroundEnabled = true
        barChartView.xAxis.drawLabelsEnabled = true
    }
    
    func chartValueSelected(_ chartView: ChartViewBase, entry: ChartDataEntry, highlight: Highlight) {
        
//        let data: String  = entry.data! as! String
//        switch data {
//        case "🍔":
//            lableBackgroundSetUp(lableSelected:  totalFood)
//        case "🛒":
//            lableBackgroundSetUp(lableSelected: totalGrocery)
//        case "🛍":
//            lableBackgroundSetUp(lableSelected: totalShopping)
//        case "🎬":
//            lableBackgroundSetUp(lableSelected: totalEntertainment)
//        case "🚘":
//            lableBackgroundSetUp(lableSelected: totalTransportation)
//        case "📞":
//            lableBackgroundSetUp(lableSelected: totalUtility)
//        case "💸":
//            lableBackgroundSetUp(lableSelected: totalOther)
//        case "💪":
//            lableBackgroundSetUp(lableSelected: totalHealth)
//        default:
//            lableBackgroundSetUp(lableSelected: nil)
//            print("Error, Setting background for lables.")
            
  //      }
    }
}


