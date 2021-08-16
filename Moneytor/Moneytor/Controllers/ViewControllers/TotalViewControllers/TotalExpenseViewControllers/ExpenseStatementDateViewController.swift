//
//  expenseStatementDateViewController.swift
//  Moneytor
//
//  Created by Lee on 8/16/21.
//

import UIKit
import Charts
import DatePicker

class ExpenseStatementDateViewController: UIViewController, UITextFieldDelegate {

    // MARK: - Outlets
    @IBOutlet weak var statementStackView: UIStackView!
    @IBOutlet weak var expenseTitelLable: UILabel!
    @IBOutlet weak var expenseStatementPromptLable: UILabel!
    @IBOutlet weak var startDateTextField: UITextField!
    @IBOutlet weak var endDateTextField: UITextField!
    @IBOutlet weak var seeStatementButton: UIButton!
    @IBOutlet weak var cancelStatementButton: UIButton!
    @IBOutlet weak var barChartView: BarChartView!
    @IBOutlet weak var expenseTableView: UITableView!
    
    // MARK: - Properties
    var totalExpenseString = TotalController.shared.totalExpenseString
    var expenseCategoryDict: [Dictionary<String, Double>.Element] = TotalController.shared.totalExpenseDictByMonthly{
        didSet {
            setupBarChart(expenseDict: expenseCategoryDict)
        }
    }
    var selectedCategory: String = "" {
        didSet {
            updateSectionHeader(selectdCategory: selectedCategory)
        }
    }
    var startDateIncomeStatement: Date = Date().startDateOfMonth {
        didSet {
            startDateTextField.text = startDateIncomeStatement.dateToString(format: .monthDayYear)
        }
    }
    
    var endDateIncomeStatement: Date = Date().endDateOfMonth {
        didSet {
            endDateTextField.text = endDateIncomeStatement.dateToString(format: .monthDayYear)
        }
    }
    
    // MARK: - Life Cycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .mtBgDarkGolder
        self.navigationController?.navigationBar.isHidden = true
        statementStackView.backgroundColor = .mtBgDarkGolder
        statementStackView.addCornerRadius()
        endDateTextField.delegate = self
        startDateTextField.delegate = self
        expenseTableView.delegate = self
        expenseTableView.dataSource = self
        barChartView.delegate = self
        setupBarChart(expenseDict: expenseCategoryDict)
        updateSectionHeader(selectdCategory: selectedCategory)
        updateViewWithtime(start: startDateIncomeStatement, end: endDateIncomeStatement)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.isHidden = true
        setupViews()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "SegueToExpenseStatementDetailsVC" {
            guard let destinationVC = segue.destination as? ExpenseStatementDetailsTableViewController else {return}
            let startDateToSend = startDateIncomeStatement
            let endDateToSend = endDateIncomeStatement
//            destinationVC.startDateIncomeStatement = startDateToSend
//            destinationVC.endDateIncomeStatement = endDateToSend
        }
    }
    
    // MARK: - Actions
    @IBAction func seeStatementButtonTapped(_ sender: Any) {
    }
    
    @IBAction func cancelStatementButtonTapped(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func fromDropdownButtonTapped(_ sender: Any) {
        showStartDatePicker()
    }
    
    @IBAction func fromButtonTapped(_ sender: Any) {
        showStartDatePicker()
    }
    
    @IBAction func toButtonTapped(_ sender: Any) {
        showEndDatePicker()
    }
    
    @IBAction func toDropdownButtonTapped(_ sender: Any) {
        showEndDatePicker()
    }
    
    // MARK: - Helper Fuctions
    func showStartDatePicker() {
        let minDate = DatePickerHelper.shared.dateFrom(day: 01, month: 01, year: 2015)!
        let maxDate = Date().endDateOfMonth
        let today = Date()
        let datePicker = DatePicker()
        datePicker.setColors(main: .mtTextLightBrown, background: .mtLightYellow, inactive: .mtDarkOrage)
        datePicker.setup(beginWith: today, min: minDate, max: maxDate) { [weak self] (selected, date) in
            if selected, let selectedDate = date {
                if let endDate = self?.endDateIncomeStatement {
                    if selectedDate <= endDate {
                        self?.startDateTextField.text = selectedDate.dateToString(format: .monthDayYear)
                        self?.startDateIncomeStatement = selectedDate
                        self?.updateViewWithtime(start: selectedDate, end: endDate)
                        self?.incomeTableView.reloadData()
                    } else {
                        self?.presentAlertToUser(titleAlert: "Start Date Error!", messageAlert: "The start date must be before the end date for expense statement.")
                    }
                }
            } else {
                print("Cancelled")
            }
        }
        datePicker.show(in: self)
    }
    
    func showEndDatePicker() {
        let minDate = DatePickerHelper.shared.dateFrom(day: 01, month: 01, year: 2015)!
        let maxDate = Date().endDateOfMonth
        let today = Date()
        let datePicker = DatePicker()
        datePicker.setColors(main: .mtTextLightBrown, background: .mtLightYellow, inactive: .mtDarkOrage)
        datePicker.setup(beginWith: today, min: minDate, max: maxDate) { [weak self] (selected, date) in
            if selected, let selectedDate = date {
                if let startDate = self?.startDateIncomeStatement {
                    if startDate <= selectedDate {
                        self?.endDateTextField.text = selectedDate.dateToString(format: .monthDayYear)
                        self?.endDateIncomeStatement = selectedDate
                        self?.updateViewWithtime(start: startDate, end: selectedDate)
                        self?.incomeTableView.reloadData()
                    } else {
                        self?.presentAlertToUser(titleAlert: "End Date Error!", messageAlert: "The start date must be before the end date for expense statement.")
                    }
                }
            } else {
                print("Cancelled")
            }
        }
        datePicker.show(in: self)
    }
    
    func setupViews(){
        startDateTextField.isUserInteractionEnabled = false
        endDateTextField.isUserInteractionEnabled = false
        startDateTextField.text = startDateIncomeStatement.dateToString(format: .monthDayYear)
        endDateTextField.text = endDateIncomeStatement.dateToString(format: .monthDayYear)
        
        if endDateIncomeStatement >= startDateIncomeStatement {
            updateViewWithtime(start: startDateIncomeStatement, end: endDateIncomeStatement)
        } else {
            updateViewWithtime(start: Date().startDateOfMonth, end: Date().endDateOfMonth)
        }
    }
    
    func updateViewWithtime(start: Date, end: Date) {
        let expenses = ExpenseCategoryController.shared.generateSectionsCategoiesByTimePeriod(start: start, end: end)
        expenseCategoryDict = ExpenseCategoryController.shared.generateCategoryDictionaryByExpensesAndReturnDict(sections: expenses)
      setupBarChart(expenseDict: expenseCategoryDict)
    }
    
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
extension ExpenseStatementDateViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return expenseCategoryDict.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "expenseCategoryCell", for: indexPath)
        let expenseCategory = expenseCategoryDict[indexPath.row]
        cell.textLabel?.text = expenseCategory.key
        cell.detailTextLabel?.text = AmountFormatter.currencyInString(num: expenseCategory.value)
        cell.selectionStyle = .none
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return CGFloat(0.0)
    }
    
    func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        var total = 0.0
        for expenseCategory in expenseCategoryDict {
            total += expenseCategory.value
        }
        let totalExpenseStr = AmountFormatter.currencyInString(num: total)
        return "TOTAL EXPENSES : \(totalExpenseStr)"
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

// MARK: - ChartViewDelegate
extension ExpenseStatementDateViewController: ChartViewDelegate {
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
                newExpenseCategoryEmojiToDisplay.append(expenseCategory.key.firstCharacterAsString)
                i += 1
            }
        }
        
        barChartView.xAxis.valueFormatter = IndexAxisValueFormatter(values: newExpenseCategoryEmojiToDisplay)
        barChartView.xAxis.granularityEnabled = true
        barChartView.xAxis.granularity = 1.0
        barChartView.xAxis.drawGridLinesEnabled = false
        barChartView.xAxis.drawLabelsEnabled = true
        barChartView.xAxis.labelFont = .boldSystemFont(ofSize: 16)
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
        barChartView.leftAxis.forceLabelsEnabled = true
        barChartView.animate(xAxisDuration: 3.0, yAxisDuration: 3.0, easingOption: .easeInOutBounce)
        barChartView.leftAxis.drawGridLinesEnabled = true
        barChartView.rightAxis.drawGridLinesEnabled = true
        barChartView.rightAxis.enabled = false
        barChartView.drawGridBackgroundEnabled = true
    }
    
    func chartValueSelected(_ chartView: ChartViewBase, entry: ChartDataEntry, highlight: Highlight) {
        let data: String  = entry.data! as! String
        let value: Double = entry.y
        let valueString = AmountFormatter.currencyInString(num: value)
        selectedCategory = "\(data.capitalized)  \(valueString)"
    }
}

