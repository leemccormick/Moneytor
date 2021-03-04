//
//  TotalIncomeViewController.swift
//  Moneytor
//
//  Created by Lee McCormick on 3/3/21.
//

import UIKit
import Charts

class TotalIncomeViewController: UIViewController {
    
    // MARK: - Outlets
    @IBOutlet weak var incomeTableView: UITableView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var lineChartView: LineChartView!
    
    // MARK: - Properties
    var totalIncomeString = TotalController.shared.totalIncomeString
    var incomeCategoriesEmoji = IncomeCategoryController.shared.incomeCategoriesEmoji
    var incomeCategoryDict: [Dictionary<String, Double>.Element] = IncomeCategoryController.shared.incomeCategoriesTotalDict {
        didSet {
            setupLineChart(incomeDict: incomeCategoryDict)
        }
    }
    var selectedCategory: String = "" {
        didSet {
            updateSection(selectdCategory: selectedCategory)
        }
    }
    
    // MARK: - Life Cycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        incomeTableView.delegate = self
        incomeTableView.dataSource = self
        lineChartView.delegate = self
        setupLineChart(incomeDict: incomeCategoryDict)
        updateSection(selectdCategory: selectedCategory)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        IncomeCategoryController.shared.generateSectionsAndSumEachIncomeCategory()
        incomeCategoryDict = IncomeCategoryController.shared.incomeCategoriesTotalDict
        incomeCategoriesEmoji = IncomeCategoryController.shared.incomeCategoriesEmoji
        setupLineChart(incomeDict: incomeCategoryDict)
        updateSection(selectdCategory: selectedCategory)
    }
    
    // MARK: - Helper Fuctions
    func updateSection(selectdCategory: String) {
        let header = UITableView(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: 40))
        if selectdCategory == "" {
            header.backgroundColor = .mtBgDarkGolder
        } else {
            header.backgroundColor = .mtDarkYellow
        }
        let lable = UILabel(frame:header.bounds)
        lable.text = "\(selectdCategory) "
        lable.textAlignment = .center
        lable.textColor = .mtTextLightBrown
        lable.font = UIFont(name: FontNames.textMoneytorGoodLetter, size: 25)
        header.addSubview(lable)
        incomeTableView.tableHeaderView = header
    }
}


// MARK: - UITableViewDelegate, UITableViewDataSource
extension TotalIncomeViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return incomeCategoryDict.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "incomeCategoryCell", for: indexPath)
        
        cell.textLabel?.text = "\(incomeCategoriesEmoji[indexPath.row]) \(incomeCategoryDict[indexPath.row].key.capitalized.dropLast())"
        cell.detailTextLabel?.text = AmountFormatter.currencyInString(num: incomeCategoryDict[indexPath.row].value)
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if selectedCategory == "" {
            return CGFloat(0.01)
        } else {
            return CGFloat(40.0)
        }
    }
    
    func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        return "TOTAL INCOMES : \(totalIncomeString)"
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return CGFloat(40.0)
    }
    
    func tableView(_ tableView: UITableView, willDisplayFooterView view: UIView, forSection section: Int) {
        view.tintColor = UIColor.mtLightYellow
        let footer = view as! UITableViewHeaderFooterView
        footer.textLabel?.textColor = UIColor.mtTextDarkBrown
        footer.textLabel?.font = UIFont(name: FontNames.textMoneytorGoodLetter, size: 25)
        footer.textLabel?.textAlignment = .center
    }
}

extension TotalIncomeViewController: ChartViewDelegate {
    
    
    

    
    func setupLineChart(incomeDict: [Dictionary<String, Double>.Element]) {
        
        lineChartView.noDataText = "No Income Data available for Chart."
        lineChartView.noDataTextAlignment = .center
        lineChartView.noDataTextColor = .mtTextLightBrown
        var yValues: [ChartDataEntry] = []
        var i = 0
        var sumIncome = 0.0
        for incomeCatagory in incomeDict {
            sumIncome += incomeCatagory.value
            i += 1
            yValues.append(ChartDataEntry(x: Double(i), y: sumIncome, data: incomeCatagory.key))
            print("-----------------incomeCatagory.value :: \(incomeCatagory.value)-----------------")
            print("----------------- incomeCatagory.key:: \(incomeCatagory.key)-----------------")
        }
        
        let dataSet = LineChartDataSet(entries: yValues)
        
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
        lineChartView.xAxis.valueFormatter = IndexAxisValueFormatter(values: incomeCategoriesEmoji)
        
        
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
        
    }
    
    func chartValueSelected(_ chartView: ChartViewBase, entry: ChartDataEntry, highlight: Highlight) {
    
        //        let data: String  = entry.data! as! String
        
        
        let data: String  = entry.data! as! String
        let value: Double = entry.y
        
        let valueString = AmountFormatter.currencyInString(num: value)
        
        selectedCategory = "\(data.capitalized)  \(valueString)"
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
}


