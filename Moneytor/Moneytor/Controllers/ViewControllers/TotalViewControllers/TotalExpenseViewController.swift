//
//  TotalExpenseViewController.swift
//  Moneytor
//
//  Created by Lee McCormick on 3/3/21.
//

import UIKit

class TotalExpenseViewController: UIViewController {
    
    // MARK: - Outlets
    @IBOutlet weak var expenseTableView: UITableView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    // MARK: - Properties
    var expenseCategoryDict: [Dictionary<String, Double>.Element] = ExpenseCategoryController.shared.expenseCategoriesTotalDict
    var totalExpenseString = TotalController.shared.totalExpenseString
    
    
    // MARK: - Life Cycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        expenseTableView.delegate = self
        expenseTableView.dataSource = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        ExpenseCategoryController.shared.generateSectionsAndSumEachExpenseCategory()
        expenseCategoryDict = ExpenseCategoryController.shared.expenseCategoriesTotalDict
    }
}

// MARK: - UITableViewDelegate, UITableViewDataSource
extension TotalExpenseViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return expenseCategoryDict.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "expenseCategoryCell", for: indexPath)
        cell.textLabel?.text = expenseCategoryDict[indexPath.row].key.capitalized
        cell.detailTextLabel?.text = AmountFormatter.currencyInString(num: expenseCategoryDict[indexPath.row].value)
        return cell
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
