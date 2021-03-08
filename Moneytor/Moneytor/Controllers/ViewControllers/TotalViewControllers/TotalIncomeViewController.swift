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
    @IBOutlet weak var timeSegmentedControl: UISegmentedControl!
    
    // MARK: - Properties
    var totalIncomeString = TotalController.shared.totalIncomeString
    /*    var incomeCategoriesEmoji = IncomeCategoryController.shared.incomeCategoriesEmoji
     var incomeCategoryDict: [Dictionary<String, Double>.Element] = IncomeCategoryController.shared.incomeCategoriesTotalDict {
     didSet {
     setupLineChart(incomeDict: incomeCategoryDict)
     }
     }
     
     //    var incomeCategoriesEmoji = IncomeCategoryController.shared.incomeCategoriesEmoji
     
     */
    var incomeCategoryDict: [Dictionary<String, Double>.Element] = TotalController.shared.totalIncomeDict {
        didSet {
            setupLineChart(incomeDict: incomeCategoryDict)
        }
    }
    
    var weekly = IncomeCategoryController.shared.weekly
    var monthly = IncomeCategoryController.shared.monthly
    var yearly = IncomeCategoryController.shared.yearly
    
    
    let incomes: [Income] = []
    //IncomeCategoryController.shared.generateSectionsCategoiesByTimePeriod(weekly)
    
    //let incomesDicts = IncomeCategoryController.shared.generateCategoryDictionaryByIncomesAndReturnDict(sections: incomes)
    
    var selectedCategory: String = "" {
        didSet {
            updateSectionHeader(selectdCategory: selectedCategory)
        }
    }
    
    
    
    
    // MARK: - Life Cycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        incomeTableView.delegate = self
        incomeTableView.dataSource = self
        lineChartView.delegate = self
        TotalController.shared.generateTotalIncomeDictByMonthly()
        setupLineChart(incomeDict: incomeCategoryDict)
        updateSectionHeader(selectdCategory: selectedCategory)
        updateViewWithtime(time: monthly)
        // TotalController.shared.generateTotalIncomeDictByMonthly()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        timeSegmentedControl.selectedSegmentIndex = 1
        
        updateSectionHeader(selectdCategory: selectedCategory)
        
        updateViewWithtime(time: monthly)
        
        //IncomeCategoryController.shared.generateSectionsAndSumEachIncomeCategory()
        //        incomeCategoryDict = IncomeCategoryController.shared.incomeCategoriesTotalDict
        //        incomeCategoriesEmoji = IncomeCategoryController.shared.incomeCategoriesEmoji
        
        //setupLineChart(incomeDict: incomeCategoryDict)
        
        
    }
    
    func updateViewWithtime(time: Date) {
        //        IncomeCategoryController.shared.generateSectionsCategoiesByTimePeriod
        let incomes = IncomeCategoryController.shared.generateSectionsCategoiesByTimePeriod(time)
        incomeCategoryDict = IncomeCategoryController.shared.generateCategoryDictionaryByIncomesAndReturnDict(sections: incomes)
        //        incomeCategoriesEmoji = IncomeCategoryController.shared.incomeCategoriesEmoji
        setupLineChart(incomeDict: incomeCategoryDict)
        updateSectionHeader(selectdCategory: selectedCategory)
        // return incomesDicts
    }
    
    
    // MARK: - Actions
    
    @IBAction func timeSegmentedControlValuedChanged(_ sender: UISegmentedControl) {
        print("----------------- sender:: \(sender.selectedSegmentIndex)-----------------")
        switch sender.selectedSegmentIndex {
        case 0:
            updateViewWithtime(time: weekly)
            incomeTableView.reloadData()
        case 1:
            updateViewWithtime(time: monthly)
            incomeTableView.reloadData()
        case 2:
            updateViewWithtime(time: yearly)
            incomeTableView.reloadData()
            
        default:
            updateViewWithtime(time: monthly)
            incomeTableView.reloadData()
        }
        
        
    }
    
    // MARK: - Helper Fuctions
    func updateSectionHeader(selectdCategory: String) {
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
       // print("----------------- :: \()-----------------")
       // return incomeCategoryDict.count
        
//        switch timeSegmentedControl.selectedSegmentIndex {
//        case 0:
//            updateViewWithtime(time: weekly)
//            print("-------------------- case 0: \(incomeCategoryDict.count) in \(#function) : ----------------------------\n)")
//        case 1:
//            updateViewWithtime(time: monthly)
//            print("-------------------- case 1: \(incomeCategoryDict.count) in \(#function) : ----------------------------\n)")
//        case 2:
//            updateViewWithtime(time: yearly)
//            print("-------------------- case 2: \(incomeCategoryDict.count) in \(#function) : ----------------------------\n)")
//
//        default:
//            updateViewWithtime(time: monthly)
//            print("-------------------- case 3: \(incomeCategoryDict.count) in \(#function) : ----------------------------\n)")
//        }
        print("-----------------incomeCategoryDict.count before return :: \(incomeCategoryDict.count) in \(#function) :-----------------")
        return incomeCategoryDict.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "incomeCategoryCell", for: indexPath)
        /*
         cell.textLabel?.text = "\(incomeCategoriesEmoji[indexPath.row]) \(incomeCategoryDict[indexPath.row].key.capitalized.dropLast())"
         */
        //
//        switch timeSegmentedControl.selectedSegmentIndex {
//        case 0:
//            updateViewWithtime(time: weekly)
//        case 1:
//            updateViewWithtime(time: monthly)
//        case 2:
//            updateViewWithtime(time: yearly)
//
//        default:
//            updateViewWithtime(time: monthly)
//        }
//
        //        if timeSegmentedControl.selectedSegmentIndex == 0 {
        //            updateViewWithtime(time: weekly)
        //        } else if timeSegmentedControl.selectedSegmentIndex == 2 {
        //            updateViewWithtime(time: yearly)
        //        } else {
        //            updateViewWithtime(time: monthly)
        //        }
        //
//        if indexPath.row < incomeCategoryDict.count {
//            print("----------------- indexPath.row:: \(indexPath.row)-----------------")
//
//            let incomeDict = incomeCategoryDict[indexPath.row]
//            print("-------------------- incomeDict: \(incomeDict) in \(#function) : ----------------------------\n)")
//            print("-----------------incomeDict :: \(incomeDict)-----------------")
//
        let incomeCategory = incomeCategoryDict[indexPath.row]
        
        print("--------------------incomeCategoryDict.count : \(incomeCategoryDict.count) in \(#function) : ----------------------------\n)")
        print("-------------------- incomeCategory: \(incomeCategory) , indexPath.row ::\(indexPath.row) in \(#function) : ----------------------------\n)")
        cell.textLabel?.text = incomeCategory.key
            cell.detailTextLabel?.text = AmountFormatter.currencyInString(num: incomeCategory.value)
        
       // }
        
        //  cell.textLabel?.text = incomeCategoryDict[indexPath.row].key
        // cell.textLabel?.text = "Fix total Income here.."
        
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
        var total = 0.0
        for incomeCategory in incomeCategoryDict {
            total += incomeCategory.value
        }
        let totalIncomeStr = AmountFormatter.currencyInString(num: total)
        return "TOTAL INCOMES : \(totalIncomeStr)"
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
        var newIncomeCategoryEmojiToDisplay: [String] = []
        
        if incomeDict.count == 1 {
            yValues.append(ChartDataEntry(x: Double(-1), y: 0, data: ""))
            for incomeCatagory in incomeDict {
                
                if incomeCatagory.value != 0 {
                    
                    sumIncome += incomeCatagory.value
                    yValues.append(ChartDataEntry(x: Double(i), y: sumIncome, data: incomeCatagory.key))
                    
                    newIncomeCategoryEmojiToDisplay.append(incomeCatagory.key.lastCharacterAsString())
                    i += 1
                }
            }
        } else  {
            
            
            for incomeCatagory in incomeDict {
                if incomeCatagory.value != 0 {
                    
                    sumIncome += incomeCatagory.value
                    yValues.append(ChartDataEntry(x: Double(i), y: sumIncome, data: incomeCatagory.key))
                    
                    newIncomeCategoryEmojiToDisplay.append(incomeCatagory.key.lastCharacterAsString())
                    i += 1
                }
            }
        }
        
        
        //print("-------------------- : incomeDict\(incomeDict) in \(#function) : ----------------------------\n)")
        let dataSet = LineChartDataSet(entries: yValues)
        dataSet.drawCirclesEnabled = true
        dataSet.mode = .linear
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
        
        let yAxis = lineChartView.leftAxis
        yAxis.labelFont = UIFont(name: FontNames.textMoneytorGoodLetter, size: 14) ?? .boldSystemFont(ofSize: 12)
        yAxis.setLabelCount(5, force: true)
        yAxis.labelTextColor = .mtTextLightBrown
        yAxis.axisLineColor = .mtDarkBlue
        yAxis.labelPosition = .outsideChart
        
        lineChartView.leftAxis.axisMinimum = 0
        lineChartView.leftAxis.axisMaximum = sumIncome + (sumIncome * 0.1)
        lineChartView.xAxis.valueFormatter = IndexAxisValueFormatter(values: newIncomeCategoryEmojiToDisplay)
        newIncomeCategoryEmojiToDisplay = []
        lineChartView.xAxis.granularityEnabled = true
        lineChartView.xAxis.drawGridLinesEnabled = false
        lineChartView.xAxis.drawLabelsEnabled = true
        lineChartView.xAxis.labelFont = .boldSystemFont(ofSize: 20)
        lineChartView.isUserInteractionEnabled = true
        lineChartView.pinchZoomEnabled = false
        lineChartView.doubleTapToZoomEnabled = false
        lineChartView.dragEnabled = true
        lineChartView.dragDecelerationEnabled = true
        lineChartView.animate(xAxisDuration: 3.0, yAxisDuration: 3.0, easingOption: .easeInOutBounce)
        lineChartView.chartDescription?.text = "Growth Income"
        lineChartView.chartDescription?.textColor = .mtLightYellow
        lineChartView.chartDescription?.font = UIFont(name: FontNames.textTitleBoldMoneytor, size: 14) ?? .boldSystemFont(ofSize: 12)
        lineChartView.leftAxis.drawGridLinesEnabled = true
        lineChartView.rightAxis.drawGridLinesEnabled = true
        lineChartView.rightAxis.enabled = false
        lineChartView.rightAxis.axisLineColor = .mtDarkBlue
        lineChartView.drawGridBackgroundEnabled = true
        lineChartView.animate(xAxisDuration: 2.5)
        lineChartView.legend.enabled = false
        
    }
    
    
    func chartValueSelected(_ chartView: ChartViewBase, entry: ChartDataEntry, highlight: Highlight) {
        
        let data: String  = entry.data! as! String
        
        for income in incomeCategoryDict {
            let incomeCategoryValue = AmountFormatter.currencyInString(num: income.value)
            
            if income.key == data {
                selectedCategory = "\(data.capitalized)  \(incomeCategoryValue)"
            }
        }
    }
}
