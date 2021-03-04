//
//  TotalExpenseViewController.swift
//  Moneytor
//
//  Created by Lee McCormick on 3/3/21.
//

import UIKit
import Charts

class TotalExpenseViewController: UIViewController {
    
    // MARK: - Outlets
    @IBOutlet weak var expenseTableView: UITableView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var expenseCatagorySearchBar: UISearchBar!
    @IBOutlet var barChartView: BarChartView!
    
    // MARK: - Properties
    var expenseCategoryDict: [Dictionary<String, Double>.Element] = ExpenseCategoryController.shared.expenseCategoriesTotalDict {
        didSet {
            setupBarChart(expenseDict: expenseCategoryDict)
        }
    }
    var totalExpenseString = TotalController.shared.totalExpenseString
    var expenseCategoryEmoji = ExpenseCategoryController.shared.expenseCategoriesEmojis
    
    
    
    var isSearching: Bool = false
    var selectedCategory: String = "" {
        didSet {
            updateSection(selectdCategory: selectedCategory)
        }
    }
    
    var resultsExpenseCategoryFromSearching: [Dictionary<String, Double>.Element] = ExpenseCategoryController.shared.expenseCategoriesTotalDict
    
    var selectedExpenseInfo: [Dictionary<String, Double>.Element] = []
    
    
    func updateSection(selectdCategory: String) {
        let header = UITableView(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: 40))
       // header.backgroundColor = .mtLightYellow
        
        
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
        expenseTableView.tableHeaderView = header
    }
    
    
    
    
    
    
    // MARK: - Life Cycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        expenseTableView.delegate = self
        expenseTableView.dataSource = self
        expenseCatagorySearchBar.delegate = self
        barChartView.delegate = self
        setupBarChart(expenseDict: expenseCategoryDict)
        updateSection(selectdCategory: selectedCategory)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        ExpenseCategoryController.shared.generateSectionsAndSumEachExpenseCategory()
        expenseCategoryDict = ExpenseCategoryController.shared.expenseCategoriesTotalDict
        expenseCategoryEmoji = ExpenseCategoryController.shared.expenseCategoriesEmojis
        setupBarChart(expenseDict: expenseCategoryDict)
        
        updateSection(selectdCategory: selectedCategory)
       // expenseTableView.selectRow(at: , animated: true, scrollPosition: <#T##UITableView.ScrollPosition#>)
//        expenseTableView.scrollToNearestSelectedRow(at: .middle, animated: true)
//        expenseTableView.selectionFollowsFocus = true
       // expenseTableView.selectRow(at: <#T##IndexPath?#>, animated: <#T##Bool#>, scrollPosition: <#T##UITableView.ScrollPosition#>)
       // expenseTableView.reloadRows(at: <#T##[IndexPath]#>, with: <#T##UITableView.RowAnimation#>)
    }
}

// MARK: - UITableViewDelegate, UITableViewDataSource
extension TotalExpenseViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return expenseCategoryDict.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "expenseCategoryCell", for: indexPath)
        cell.textLabel?.text = "\(expenseCategoryEmoji[indexPath.row]) \(expenseCategoryDict[indexPath.row].key.capitalized.dropLast())"
        cell.detailTextLabel?.text = AmountFormatter.currencyInString(num: expenseCategoryDict[indexPath.row].value)
        
//        if selectedCategory == expenseCategoryDict[indexPath.row].key {
//            expenseTableView.selectRow(at: indexPath, animated: true, scrollPosition: .none)
//        }
        return cell
    }
    
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

//        let indexPath = IndexPath(row: 0, section: 0)
        
        if selectedCategory == "\(expenseCategoryDict[indexPath.row].key) \(AmountFormatter.currencyInString(num:  expenseCategoryDict[indexPath.row].value))" {
        
        expenseTableView.selectRow(at: indexPath, animated: true, scrollPosition: .none)
        expenseTableView.delegate?.tableView!(expenseTableView, didSelectRowAt: indexPath)
        
    }

    }
    
//    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
//        var header = ""
//        for dict in expenseCategoryDict {
//            if selectedCategory == dict.key {
//                header = "\(selectedCategory)"
//            }
//        }
//        return header
//    }
//
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if selectedCategory == "" {
            return CGFloat(0.0)
        } else {
        return CGFloat(40.0)
        }
    }
    
    
    
    
    func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        return "TOTAL EXPENSES : \(totalExpenseString)"
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


extension TotalExpenseViewController: UISearchBarDelegate {
    
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        
        for name in expenseCategoryDict {
            print("\n\n----------------- selectedCategory searchBar:: \(selectedCategory)-----------------")
            if selectedCategory == name.key {
                selectedExpenseInfo.append(name)
            }
        }
        print("----------------- selectedExpenseInfo:: \(selectedExpenseInfo)-----------------")
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        searchBar.text = ""
        isSearching = false
        expenseTableView.reloadData()
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        isSearching = true
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        isSearching = false
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        isSearching = false
    }
}



extension TotalExpenseViewController: ChartViewDelegate {
    
    func setupBarChart(expenseDict: [Dictionary<String, Double>.Element]){
        
        var dataEntries: [BarChartDataEntry] = []
        var i = 0
        
        var newExpenseCategoryEmojiToDisplay: [String] = []
    
        for expenseCategory in expenseDict {
            
            if expenseCategory.value != 0.0 {
                let dataEntry = BarChartDataEntry(x: Double(i), y: Double(expenseCategory.value), data: expenseCategory.key)
                dataEntries.append(dataEntry)
                let chartDataSet = BarChartDataSet(entries: dataEntries)
                chartDataSet.colors = ChartColorTemplates.pastel()
                chartDataSet.drawValuesEnabled = false
                let charData = BarChartData(dataSet: chartDataSet)
                charData.setDrawValues(true)
                charData.setValueFont(UIFont(name: FontNames.textMoneytorGoodLetter, size: 12) ?? .boldSystemFont(ofSize: 12))
                charData.setValueTextColor(.mtDarkBlue)
                barChartView.data = charData
    
               
                
                newExpenseCategoryEmojiToDisplay.append(expenseCategory.key.lastCharacterAsString())
                print("----------------- :newExpenseCategoryEmojiToDisplay: \(newExpenseCategoryEmojiToDisplay)-----------------")
                i += 1
            }
        }
        
        print("-----------------newExpenseCategoryEmojiToDisplay.count\(newExpenseCategoryEmojiToDisplay.count)------------------")
        
        barChartView.xAxis.valueFormatter = IndexAxisValueFormatter(values: newExpenseCategoryEmojiToDisplay)
        newExpenseCategoryEmojiToDisplay = []

        let yAxis = barChartView.leftAxis
        yAxis.labelFont = UIFont(name: FontNames.textMoneytorGoodLetter, size: 14) ?? .boldSystemFont(ofSize: 12)
        yAxis.setLabelCount(6, force: true)
        yAxis.labelTextColor = .mtTextLightBrown
        yAxis.axisLineColor = .mtDarkBlue
        yAxis.labelPosition = .outsideChart
        
        barChartView.noDataText = "No Expense Data available for Chart."
        barChartView.leftAxis.axisMinimum = 0
        barChartView.legend.enabled = false
        barChartView.isUserInteractionEnabled = true
        barChartView.pinchZoomEnabled = false
        barChartView.doubleTapToZoomEnabled = false
        barChartView.dragEnabled = false
        barChartView.dragDecelerationEnabled = false
        
     
        
      
        
        
        barChartView.xAxis.granularityEnabled = true
        barChartView.xAxis.granularity = 1.0
        barChartView.leftAxis.forceLabelsEnabled = true
        barChartView.xAxis.granularityEnabled = true
        barChartView.animate(xAxisDuration: 3.0, yAxisDuration: 3.0, easingOption: .easeInOutBounce)
        barChartView.leftAxis.drawGridLinesEnabled = true
        barChartView.rightAxis.drawGridLinesEnabled = true
        barChartView.xAxis.drawGridLinesEnabled = false
        barChartView.rightAxis.enabled = false
        barChartView.drawGridBackgroundEnabled = true
        barChartView.xAxis.drawLabelsEnabled = true
    }
    
    func chartValueSelected(_ chartView: ChartViewBase, entry: ChartDataEntry, highlight: Highlight) {
        
        let data: String  = entry.data! as! String
        let value: Double = entry.y
        
        print(data)
        let valueString = AmountFormatter.currencyInString(num: value)
        
        selectedCategory = "\(data.capitalized)  \(valueString)"
        print("----------------- ::data \(data)-----------------")
        print("----------------- ::selectedCatagory \(selectedCategory)-----------------")
        
        
        
//        for dict in expenseCategoryDict {
//            if selectedCategory == dict.key {
//              //  expenseTableView.selectRow(at: expenseCategoryDict[inde], animated: <#T##Bool#>, scrollPosition: <#T##UITableView.ScrollPosition#>)
//            }
//        }
//
        
//        let indexPath = IndexPath(row: 0, section: 0)
//        expenseTableView.selectRow(at: indexPath, animated: true, scrollPosition: .bottom)
//        expenseTableView.delegate?.tableView!(expenseTableView, didSelectRowAt: indexPath)
//
//
//        let totalRows = expenseTableView.numberOfRows(inSection: 0)
//            for row in 0..<totalRows {
//                expenseTableView.selectRow(at: NSIndexPath(row: row, section: 0) as IndexPath, animated: false, scrollPosition: UITableView.ScrollPosition.none)
//            }
        // expenseTableView.selectRow(at: , animated: true, scrollPosition: <#T##UITableView.ScrollPosition#>)
 //        expenseTableView.scrollToNearestSelectedRow(at: .middle, animated: true)
 //        expenseTableView.selectionFollowsFocus = true
        // expenseTableView.selectRow(at: <#T##IndexPath?#>, animated: <#T##Bool#>, scrollPosition: <#T##UITableView.ScrollPosition#>)
        // expenseTableView.reloadRows(at: <#T##[IndexPath]#>, with: <#T##UITableView.RowAnimation#>)
        
    }
}
