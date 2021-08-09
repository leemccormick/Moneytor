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
  
    var startDateIncomeStatement: Date = Date().startDateOfMonth {
        didSet {
            startDateTextField.text = startDateIncomeStatement.dateToString(format: .monthDayYear)
        }
    }
    
    var endDateIncomeStatement: Date = Date().endDateOfMonth {
        didSet {
            startDateTextField.text = startDateIncomeStatement.dateToString(format: .monthDayYear)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .mtBgDarkGolder
        self.navigationController?.navigationBar.isHidden = true
        
 statementStackView.backgroundColor = .mtBgDarkGolder
        statementStackView.addCornerRadius()
        
 endDateTextField.delegate = self
        startDateTextField.delegate = self
    }
    
    
    @IBAction func seeStatementButtonTapped(_ sender: Any) {
    }
    
    
    @IBAction func cancelStatementButtonTapped(_ sender: Any) {
    }
    
    @IBAction func fromDropdownButtonTapped(_ sender: Any) {
        let minDate = DatePickerHelper.shared.dateFrom(day: 01, month: 01, year: 2015)!
        let maxDate = Date().endDateOfMonth
            let today = Date()
            // Create picker object
            let datePicker = DatePicker()
            // Setup
        datePicker.setColors(main: .mtTextLightBrown, background: .mtLightYellow, inactive: .mtDarkOrage)
            datePicker.setup(beginWith: today, min: minDate, max: maxDate) { (selected, date) in
                self.startDateIncomeStatement = date ?? Date()
                if selected, let selectedDate = date {
                    print(selectedDate.string())
                    self.startDateTextField.text = selectedDate.dateToString(format: .full)

                    self.startDateIncomeStatement = selectedDate
                } else {
                    print("Cancelled")
                }
            }
            // Display

       datePicker.show(in: self, on: sender as? UIView)
//        datePicker.show(in: self)
        
    }
    
    @IBAction func fromButtonTapped(_ sender: Any) {
        
        
    }
    
    @IBAction func toButtonTapped(_ sender: Any) {
       
        
    }
    
    
    @IBAction func toDropdownButtonTapped(_ sender: Any) {
        
        let minDate = DatePickerHelper.shared.dateFrom(day: 01, month: 01, year: 2015)!
        let maxDate = Date().endDateOfMonth
            let today = Date()
            // Create picker object
            let datePicker = DatePicker()
            // Setup
        datePicker.setColors(main: .mtTextLightBrown, background: .mtLightYellow, inactive: .mtDarkOrage)
            datePicker.setup(beginWith: today, min: minDate, max: maxDate) { (selected, date) in
//self.endDateIncomeStatement = date ?? Date()
                if selected, let selectedDate = date {
                    print(selectedDate.string())
                    self.endDateTextField.text = selectedDate.dateToString(format: .full)

                    self.endDateIncomeStatement = selectedDate
                } else {
                    print("Cancelled")
                }
            }
            // Display

       datePicker.show(in: self, on: sender as? UIView)
//        datePicker.show(in: self)
    }
}
    
   
