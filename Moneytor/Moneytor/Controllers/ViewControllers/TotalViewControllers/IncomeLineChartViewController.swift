//
//  IncomeLineChartViewController.swift
//  Moneytor
//
//  Created by Lee McCormick on 2/23/21.
//

import UIKit
import Charts

class IncomeLineChartViewController: UIViewController {

    // MARK: - Outlets
    @IBOutlet var lineChartView: LineChartView!

    // MARK: - Properties
    var incomeCategoriesSum = [123.00,1246, 3300,467676]
    var incomeDictionary: [Dictionary<String, Double>.Element] = IncomeCategoryController.shared.incomeCategoriesTotalDict {
        didSet {
            
            setupLineChart(incomeDict: incomeDictionary)
            //loadViewIfNeeded()

        }
    }
    
//    var incomeDictionary: [String : Double] = IncomeCategoryController.shared.incomeCategoriesTotalDict {
//        didSet {
//
//            setupLineChart(incomeDict: incomeDictionary)
//            //loadViewIfNeeded()
//
//        }
//    }
    
    var yValues: [ChartDataEntry] = []
    
    // MARK: - Life Cycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        lineChartView.delegate = self
//        setupLineChart()
//        IncomeCategoryController.shared.fetchAllIncomeCategories()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
       // IncomeCategoryController.shared.fetchAllIncomeCategories()
       // Income
        IncomeCategoryController.shared.generateSectionsAndSumEachIncomeCategory()
        incomeDictionary = IncomeCategoryController.shared.incomeCategoriesTotalDict
        setupLineChart(incomeDict: incomeDictionary)
        print("----------------- :: viewWillAppear-----------------")

    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.popViewController(animated: true)
    }
}





// MARK: - ChartViewDelegate
extension IncomeLineChartViewController: ChartViewDelegate {
    
    func chartValueSelected(_ chartView: ChartViewBase, entry: ChartDataEntry, highlight: Highlight) {
        
//        let data: String  = entry.data! as! String
//        switch data {
//        case "cash":
//            lableBackgroundSetUp(lableSelected:  totalCash)
//        case "credit":
//            lableBackgroundSetUp(lableSelected: totalCreditCard)
//        case "bankAccount":
//            lableBackgroundSetUp(lableSelected: totalBankAccount)
//        case "other":
//            lableBackgroundSetUp(lableSelected: totalOther)
//        default:
//            lableBackgroundSetUp(lableSelected: nil)
//            print("Error, Setting background for lables.")
//        }
    }
    
    func setupLineChart(incomeDict: [Dictionary<String, Double>.Element]) {
        
        lineChartView.noDataText = "No Income Data available for Chart."
        lineChartView.noDataTextAlignment = .center
        lineChartView.noDataTextColor = .mtTextLightBrown

        let yAxis = lineChartView.leftAxis
        yAxis.labelFont = UIFont(name: FontNames.textMoneytorGoodLetter, size: 14) ?? .boldSystemFont(ofSize: 12)
        yAxis.setLabelCount(5, force: true)
        yAxis.labelTextColor = .mtTextLightBrown
        yAxis.axisLineColor = .mtDarkBlue
        yAxis.labelPosition = .outsideChart
        lineChartView.animate(xAxisDuration: 2.5)
        lineChartView.legend.enabled = false
        lineChartView.leftAxis.axisMinimum = 0
        lineChartView.isUserInteractionEnabled = true
        lineChartView.pinchZoomEnabled = false
        lineChartView.doubleTapToZoomEnabled = false
        lineChartView.dragEnabled = true
        lineChartView.dragDecelerationEnabled = true
        lineChartView.xAxis.granularityEnabled = true
        lineChartView.animate(xAxisDuration: 3.0, yAxisDuration: 3.0, easingOption: .easeInOutBounce)
        lineChartView.chartDescription?.text = "Growth Income"
        lineChartView.chartDescription?.textColor = .mtLightYellow
        lineChartView.chartDescription?.font = UIFont(name: FontNames.textTitleBoldMoneytor, size: 14) ?? .boldSystemFont(ofSize: 12)
        lineChartView.leftAxis.drawGridLinesEnabled = true
        lineChartView.rightAxis.drawGridLinesEnabled = true
        lineChartView.xAxis.drawGridLinesEnabled = false
        lineChartView.rightAxis.enabled = false
        lineChartView.rightAxis.axisLineColor = .mtDarkBlue
        lineChartView.drawGridBackgroundEnabled = true
        lineChartView.xAxis.drawLabelsEnabled = false
       // lineChartView.backgroundColor =
       //lineChartView.drawEntryLabelsEnabled = true
        
        //set data for lineChart
        
   var i = 0
        var sumIncome = 0.0
        for incomeCatagory in incomeDict {
             sumIncome += incomeCatagory.value
             i += 1
            yValues.append(ChartDataEntry(x: Double(i), y: sumIncome, data: incomeCatagory.key))
            print("-----------------incomeCatagory.value :: \(incomeCatagory.value)-----------------")
            print("----------------- incomeCatagory.key:: \(incomeCatagory.key)-----------------")
            }
 
        let dataSet = LineChartDataSet(entries: yValues, label: "Subscribers")
        
        dataSet.drawCirclesEnabled = true
        dataSet.mode = .stepped
        dataSet.lineWidth = 4
        dataSet.setColor(.mtTextLightBrown)
        dataSet.fill = Fill(color: .mtDarkBlue)
        dataSet.fillAlpha = 0.9
        dataSet.drawFilledEnabled = true
        dataSet.drawHorizontalHighlightIndicatorEnabled = true
        dataSet.highlightColor = .mtDarkYellow
        dataSet.colors = ChartColorTemplates.pastel()
        let lineChartData = LineChartData(dataSet: dataSet)
        lineChartData.setDrawValues(true)
        lineChartData.setValueFont(UIFont(name: FontNames.textMoneytorGoodLetter, size: 12) ?? .boldSystemFont(ofSize: 12))
        lineChartData.setValueTextColor(.mtDarkBlue)
        lineChartView.data = lineChartData
    }
}

