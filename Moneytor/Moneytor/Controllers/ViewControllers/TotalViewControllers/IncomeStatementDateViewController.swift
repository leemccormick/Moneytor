//
//  IncomeStatementDateViewController.swift
//  Moneytor
//
//  Created by Lee on 7/31/21.
//

import UIKit

class IncomeStatementDateViewController: UIViewController {
    
    // MARK: - Outlets
    @IBOutlet weak var statementStackView: UIStackView!
    @IBOutlet weak var incomeTitelLable: UILabel!
    @IBOutlet weak var incomeStatementPromptLable: UILabel!
    @IBOutlet weak var startDateTextField: UITextField!
    @IBOutlet weak var endDateTextField: UITextField!
    @IBOutlet weak var seeStatementButton: UIButton!
    @IBOutlet weak var cancelStatementButton: UIButton!
    
    let savedStartDateButton = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(savedStartDateButtonTapped))
    let savedEndDateButton = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(savedEndDateButtonTapped))

    var startDateIncomeStatement: Date = Date().startDateOfMonth {
        didSet {
            startDateTextField.text = startDateIncomeStatement.dateToString(format: .monthDayYear)
        }
    }
    var endDateIncomeStatement: Date?
    let datePicker = UIDatePicker()
    

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .none
        self.navigationController?.navigationBar.isHidden = true
        statementStackView.backgroundColor = .mtLightYellow
        statementStackView.addCornerRadius()
        createDatePicker(textField: startDateTextField, button: savedStartDateButton)
createDatePicker(textField: endDateTextField, button: savedEndDateButton)    }
    
    
    @IBAction func seeStatementButtonTapped(_ sender: Any) {
    }
    
    
    @IBAction func cancelStatementButtonTapped(_ sender: Any) {
    }
    
    
    
    /*func presentAlertGoToIncomeStatement() {
        print("\n\n\n\n\n=================== GO TO INCOME STATMENT======================IN \(#function)\n\n\n\n")
       
        let alertController = UIAlertController(title: "Income Statement",
                                                message: "If you would like to see your income statement by specific date, please enter the start date and end date for the income statement." ,preferredStyle: .alert)
        alertController.addTextField { [self] (startDateTextField) in
            startDateTextField.placeholder = "Start Date"
            startDateTextField.keyboardAppearance = .dark
         
         self.createDatePicker(textField: startDateTextField)
           // guard let starDate = self.startDateIncomeStatement.dateToString(format: .monthDayYear) else {return}
          //  startDateTextField.text = starDate
            
        }
        

        
        
        let seeStatementAction = UIAlertAction(title: "See Statement", style: .default) { (action) in
           // self.goToTotalIncomeStatementVC()
        }
        let dismissAction = UIAlertAction(title: "Cancel", style: .destructive)
        alertController.addAction(seeStatementAction)
        alertController.addAction(dismissAction)
        
        present(alertController, animated: true)
    }
    
*/
    
    
    func createDatePicker(textField: UITextField, button: UIBarButtonItem)  {
        //let datePicker = UIDatePicker()
        datePicker.datePickerMode = .date
        datePicker.preferredDatePickerStyle = .wheels
        datePicker.calendar = .current
        datePicker.maximumDate = Date()
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
    
        
       // let savedStartDateButton = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(savedStartDateButtonTapped))
        toolbar.setItems([button], animated: true)
        textField.inputAccessoryView = toolbar
     self.datePicker.addTarget(self, action: #selector(dateValueChange), for: .valueChanged)
        textField.inputView = datePicker
        //textField.text = datePicker.date.dateToString(format: .monthDayYear)
     
    }
    
    @objc func savedStartDateButtonTapped() {
        print("===================saveButtonTappedsaveButtonTapped======================")
        startDateIncomeStatement = datePicker.date
        startDateTextField.text = datePicker.date.dateToString(format: .monthDayYear)
       // startDateIncomeStatement = datePicker.date
        print("\n=================== startDateIncomeStatement :: \(startDateIncomeStatement)======================IN \(#function)\n")
    }
    
    @objc func savedEndDateButtonTapped() {
        print("===================saveButtonTappedsaveButtonTapped======================")
        endDateIncomeStatement = datePicker.date
        endDateTextField.text = datePicker.date.dateToString(format: .monthDayYear)
       // startDateIncomeStatement = datePicker.date
        print("\n=================== startDateIncomeStatement :: \(startDateIncomeStatement)======================IN \(#function)\n")
    }
    
    @objc func dateValueChange() {
        startDateIncomeStatement = datePicker.date
        startDateTextField.text = datePicker.date.dateToString(format: .monthDayYear)
       // startDateIncomeStatement = datePicker.date
       // startDateIncomeStatement = datePicker.date
        print("\n=================== startDateIncomeStatement:: \(startDateIncomeStatement)======================IN \(#function)\n")
    }
    
    func updateTextFieldWithDate(_ textFiled: UITextField, date: Date) {
        textFiled.text = date.dateToString(format: .monthDayYear)
    }
}
