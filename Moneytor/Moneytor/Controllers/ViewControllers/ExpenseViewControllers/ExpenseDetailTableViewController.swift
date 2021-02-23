//
//  ExpenseDetailTableViewController.swift
//  Moneytor
//
//  Created by Lee McCormick on 2/22/21.
//

import UIKit

class ExpenseDetailTableViewController: UITableViewController {

    // MARK: - Outlets
    
    @IBOutlet weak var expenseNameTextField: MoneytorTextField!
    @IBOutlet weak var expenseAmountTextField: MoneytorTextField!
    @IBOutlet weak var expenseCategoryPicker: UIPickerView!
    @IBOutlet weak var expenseDatePicker: UIDatePicker!
    
    // MARK: - Life Cycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        let tap = UITapGestureRecognizer(target: self.view, action: #selector(UIView.endEditing))
        view.addGestureRecognizer(tap)
    }

    
    // MARK: - Actions
    
    @IBAction func saveButtonTapped(_ sender: Any) {
    }
    
    @IBAction func saveExpenseButtonTapped(_ sender: Any) {
    }
    
    
    @IBAction func scannerButtonTapped(_ sender: Any) {
    }
    
   // MARK: - Table View
    override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        view.tintColor = UIColor.mtBgGolder
          let header = view as! UITableViewHeaderFooterView
        header.textLabel?.textColor = UIColor.mtTextLightBrown
        header.textLabel?.font = UIFont(name: FontNames.textTitleBoldMoneytor, size: 20)
      }
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 4 {
            return CGFloat(0.0)
        } else {
            return CGFloat(40.0)
        }
      }

      
    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // toScannerVC
   }

}
