//
//  ExpenseListTableViewController.swift
//  Moneytor
//
//  Created by Lee McCormick on 2/22/21.
//

import UIKit

class ExpenseListTableViewController: UITableViewController {

    
    // MARK: - Outlets
    @IBOutlet weak var expenseSearchBar: UISearchBar!
    @IBOutlet weak var activityView: UIView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    // MARK: - Life Cycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
//        let tap = UITapGestureRecognizer(target: self.view, action: #selector(UIView.endEditing))
//        view.addGestureRecognizer(tap)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        ExpenseController.shared.fetchAllExpenses()
        tableView.reloadData()
    }

    
    // MARK: - Actions
    
    @IBAction func calendarButtonTapped(_ sender: Any) {
    }
    
    // MARK: - Table view data source

//    override func numberOfSections(in tableView: UITableView) -> Int {
//        // #warning Incomplete implementation, return the number of sections
//        return 0
//    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return ExpenseController.shared.expenses.count
    }


    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "expenseCell", for: indexPath)
      let expense = ExpenseController.shared.expenses[indexPath.row] 
        cell.textLabel?.text = "\(expense.expenseCategory?.emoji ?? "💸") \(expense.name ?? "")"
        cell.detailTextLabel?.text = expense.expenseAmountString
        return cell
    }
  
    
   
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let expense = ExpenseController.shared.expenses[indexPath.row]
            ExpenseController.shared.deleteExpense(expense)
            tableView.reloadData()
        }
    }
   
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier ==  "toExpenseDetailVC" {
            guard let indexPath = tableView.indexPathForSelectedRow,
                  let destinationVC = segue.destination as? ExpenseDetailTableViewController else {return}
            let expense = ExpenseController.shared.expenses[indexPath.row]
            destinationVC.expense = expense
        }
    }
}
