//
//  IncomeStatementDateViewController.swift
//  Moneytor
//
//  Created by Lee on 7/31/21.
//

import UIKit
import DatePicker
import Charts

class IncomeStatementDateViewController: UIViewController, UITextFieldDelegate {
    
    // MARK: - Outlets
    @IBOutlet weak var statementStackView: UIStackView!
    @IBOutlet weak var incomeTitelLable: UILabel!
    @IBOutlet weak var incomeStatementPromptLable: UILabel!
    @IBOutlet weak var startDateTextField: UITextField!
    @IBOutlet weak var endDateTextField: UITextField!
    @IBOutlet weak var seeStatementButton: UIButton!
    @IBOutlet weak var cancelStatementButton: UIButton!
    @IBOutlet weak var incomeLineChartView: LineChartView!
    @IBOutlet weak var incomeTableView: UITableView!
    
    // MARK: - Properties
    var totalIncomeString = TotalController.shared.totalIncomeString
    var incomeCategoryDict: [Dictionary<String, Double>.Element] = [] {
        didSet {
            setupLineChart(incomeDict: incomeCategoryDict)
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
        incomeTableView.delegate = self
        incomeTableView.dataSource = self
        incomeLineChartView.delegate = self
        setupLineChart(incomeDict: incomeCategoryDict)
        updateSectionHeader(selectdCategory: selectedCategory)
        updateViewWithtime(start: startDateIncomeStatement, end: endDateIncomeStatement)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.isHidden = true
        setupViews()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "SegueToStatementDetailsVC" {
            guard let destinationVC = segue.destination as? IncomeStatementDetailsTableViewController else {return}
            let startDateToSend = startDateIncomeStatement
            let endDateToSend = endDateIncomeStatement
            destinationVC.startDateIncomeStatement = startDateToSend
            destinationVC.endDateIncomeStatement = endDateToSend
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
                        self?.presentAlertToUser(titleAlert: "Start Date Error!", messageAlert: "The start date must be before the end date for income statement.")
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
                        self?.presentAlertToUser(titleAlert: "End Date Error!", messageAlert: "The start date must be before the end date for income statement.")
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
        let incomes = IncomeCategoryController.shared.generateSectionsCategoiesByTimePeriod(start: start, end: end)
        incomeCategoryDict = IncomeCategoryController.shared.generateCategoryDictionaryByIncomesAndReturnDict(sections: incomes)
        setupLineChart(incomeDict: incomeCategoryDict)
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

// MARK: - ChartViewDelegate
extension IncomeStatementDateViewController: ChartViewDelegate {
    func setupLineChart(incomeDict: [Dictionary<String, Double>.Element]) {
        var yValues: [ChartDataEntry] = []
        var i = 0
        var sumIncome = 0.0
        var newIncomeCategoryEmojiToDisplay: [String] = []
        
        if incomeDict.count == 1 {
            yValues.append(ChartDataEntry(x: Double(-1), y: 0, data: ""))
            for incomeCatagory in incomeDict {
                if incomeCatagory.value != 0 {
                    sumIncome += incomeCatagory.value
                    yValues.append(ChartDataEntry(x: Double(i), y: sumIncome.round(to: 2), data: incomeCatagory.key))
                    newIncomeCategoryEmojiToDisplay.append(incomeCatagory.key.lastCharacterAsString())
                    i += 1
                }
            }
        } else  {
            for incomeCatagory in incomeDict {
                if incomeCatagory.value != 0 {
                    sumIncome += incomeCatagory.value
                    yValues.append(ChartDataEntry(x: Double(i), y: sumIncome.round(to: 2), data: incomeCatagory.key))
                    newIncomeCategoryEmojiToDisplay.append(incomeCatagory.key.firstCharacterAsString)
                    i += 1
                }
            }
        }
        
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
        incomeLineChartView.data = lineChartData
        incomeLineChartView.noDataText = "No Income Data available for Chart."
        incomeLineChartView.noDataTextAlignment = .center
        incomeLineChartView.noDataTextColor = .mtTextLightBrown
        let yAxis = incomeLineChartView.leftAxis
        yAxis.labelFont = UIFont(name: FontNames.textMoneytorGoodLetter, size: 14) ?? .boldSystemFont(ofSize: 12)
        yAxis.setLabelCount(5, force: true)
        yAxis.labelTextColor = .mtTextLightBrown
        yAxis.axisLineColor = .mtDarkBlue
        yAxis.labelPosition = .outsideChart
        incomeLineChartView.leftAxis.axisMinimum = 0
        incomeLineChartView.leftAxis.axisMaximum = sumIncome + (sumIncome * 0.1)
        incomeLineChartView.xAxis.valueFormatter = IndexAxisValueFormatter(values: newIncomeCategoryEmojiToDisplay)
        incomeLineChartView.xAxis.granularityEnabled = true
        incomeLineChartView.xAxis.drawGridLinesEnabled = false
        incomeLineChartView.xAxis.drawLabelsEnabled = true
        incomeLineChartView.xAxis.labelFont = .boldSystemFont(ofSize: 20)
        incomeLineChartView.isUserInteractionEnabled = true
        incomeLineChartView.pinchZoomEnabled = false
        incomeLineChartView.doubleTapToZoomEnabled = false
        incomeLineChartView.dragEnabled = true
        incomeLineChartView.dragDecelerationEnabled = true
        incomeLineChartView.animate(xAxisDuration: 3.0, yAxisDuration: 3.0, easingOption: .easeInOutBounce)
        incomeLineChartView.chartDescription?.text = "Growth Income"
        incomeLineChartView.chartDescription?.textColor = .mtLightYellow
        incomeLineChartView.chartDescription?.font = UIFont(name: FontNames.textTitleBoldMoneytor, size: 14) ?? .boldSystemFont(ofSize: 12)
        incomeLineChartView.leftAxis.drawGridLinesEnabled = true
        incomeLineChartView.rightAxis.drawGridLinesEnabled = true
        incomeLineChartView.rightAxis.enabled = false
        incomeLineChartView.rightAxis.axisLineColor = .mtDarkBlue
        incomeLineChartView.drawGridBackgroundEnabled = true
        incomeLineChartView.animate(xAxisDuration: 2.5)
        incomeLineChartView.legend.enabled = false
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

// MARK: - UITableViewDelegate, UITableViewDataSource
extension IncomeStatementDateViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return incomeCategoryDict.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "incomeCategoryCell", for: indexPath)
        let incomeCategory = incomeCategoryDict[indexPath.row]
        cell.textLabel?.text = incomeCategory.key
        cell.detailTextLabel?.text = AmountFormatter.currencyInString(num: incomeCategory.value)
        cell.selectionStyle = .none
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return CGFloat(0.0)
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

