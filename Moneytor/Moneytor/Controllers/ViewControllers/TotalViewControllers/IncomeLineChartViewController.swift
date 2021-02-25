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
    var yValues: [ChartDataEntry] = []
    
    // MARK: - Life Cycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        lineChartView.delegate = self
        setupLineChart()
    }
    

}


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
    
    func setupLineChart() {
        
        //set LineChart View
        lineChartView.noDataText = "No Income Data available for Chart."
        lineChartView.noDataTextAlignment = .center
        lineChartView.noDataTextColor = .black
        lineChartView.rightAxis.enabled = false
        let yAxis = lineChartView.leftAxis
        yAxis.labelFont = .boldSystemFont(ofSize: 12)
        yAxis.setLabelCount(6, force: false)
        yAxis.labelTextColor = .brown
        yAxis.axisLineColor = .brown
        yAxis.labelPosition = .outsideChart
        lineChartView.animate(xAxisDuration: 2.5)
        lineChartView.legend.enabled = false
        lineChartView.isUserInteractionEnabled = true
        lineChartView.pinchZoomEnabled = false
        lineChartView.doubleTapToZoomEnabled = false
        lineChartView.dragEnabled = false
        lineChartView.dragDecelerationEnabled = false
        lineChartView.xAxis.granularityEnabled = true
        lineChartView.animate(xAxisDuration: 3.0, yAxisDuration: 3.0, easingOption: .easeInOutBounce)
        lineChartView.chartDescription?.text = ""
        lineChartView.leftAxis.drawGridLinesEnabled = true
        lineChartView.rightAxis.drawGridLinesEnabled = true
        lineChartView.xAxis.drawGridLinesEnabled = false
        lineChartView.rightAxis.enabled = false
        lineChartView.drawGridBackgroundEnabled = true
        lineChartView.xAxis.drawLabelsEnabled = false
        
        //set data for lineChart
        
   var i = 0
//        for incomeCatagory in incomeCategoriesSum {
//            sumArrPlus += incomeCatagory.sum
//            i += 1
//            yValues.append(ChartDataEntry(x: Double(i), y: sumArrPlus, data: incomeCatagory.category.rawValue))
//        }

        for incomeCatagory in incomeCategoriesSum {
//            sumArrPlus += incomeCatagory.sum
          i += 1
            yValues.append(ChartDataEntry(x: Double(i), y: incomeCatagory, data: nil))
        }
        
        let dataSet = LineChartDataSet(entries: yValues, label: "Subscribers")
        
        dataSet.drawCirclesEnabled = false
        dataSet.mode = .linear
        dataSet.lineWidth = 3
        dataSet.setColor(.brown)
        dataSet.fill = Fill(color: .yellow)
        dataSet.fillAlpha = 0.8
        dataSet.drawFilledEnabled = true
        dataSet.drawHorizontalHighlightIndicatorEnabled = false
        dataSet.highlightColor = .systemRed
        dataSet.colors = ChartColorTemplates.material()
        
        let lineChartData = LineChartData(dataSet: dataSet)
        lineChartData.setDrawValues(true)
        lineChartData.setValueFont(.boldSystemFont(ofSize: 12))
        
        lineChartView.data = lineChartData
    }
}

