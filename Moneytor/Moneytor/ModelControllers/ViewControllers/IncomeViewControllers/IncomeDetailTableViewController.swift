//
//  IncomeDetailTableViewController.swift
//  Moneytor
//
//  Created by Lee McCormick on 2/22/21.
//

import UIKit

class IncomeDetailTableViewController: UITableViewController {
    
    // MARK: - Outlets
    
    
    @IBOutlet weak var incomeNameTextField: MoneytorTextField!
    
    @IBOutlet weak var incomeAmount: MoneytorTextField!
    
    
    @IBOutlet weak var incomeCategoryPicker: UIPickerView!
    // MARK: - Properties
    
    
    @IBOutlet weak var incomeDatePicker: UIDatePicker!
    
    
    

    // MARK: - Life Cycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        let tap = UITapGestureRecognizer(target: self.view, action: #selector(UIView.endEditing))
        view.addGestureRecognizer(tap)
    }
    
    // MARK: - Actions
    
    @IBAction func saveButtonTapped(_ sender: Any) {
    }
    
    @IBAction func trashButtonTapped(_ sender: Any) {
    }
    
    
    @IBAction func incomeSaveButtonTapped(_ sender: Any) {
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
    
}
