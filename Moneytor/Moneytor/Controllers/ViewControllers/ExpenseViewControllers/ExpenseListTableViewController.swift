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
    
    
    // MARK: - Properties
    var resultsExpenseFromSearching: [SearchableRecordDelegate] = []
    var isSearching: Bool = false
    var dataSource: [SearchableRecordDelegate] {
        return isSearching ? resultsExpenseFromSearching : ExpenseController.shared.expenses
    }
    
    
    
    // MARK: - Life Cycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        expenseSearchBar.delegate = self
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
        return dataSource.count
        //return ExpenseController.shared.expenses.count
    }


    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "expenseCell", for: indexPath)
        guard let expense = dataSource[indexPath.row] as? Expense else {return UITableViewCell()}
        cell.textLabel?.text = "\(expense.expenseCategory?.emoji ?? "💸") \(expense.name ?? "")"
        cell.detailTextLabel?.text = expense.expenseAmountString
        return cell
    }
  
    
   
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            guard let expense = dataSource[indexPath.row] as? Expense else {return}
            ExpenseController.shared.deleteExpense(expense)
            tableView.reloadData()
        }
    }
   
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier ==  "toExpenseDetailVC" {
            guard let indexPath = tableView.indexPathForSelectedRow,
                  let destinationVC = segue.destination as? ExpenseDetailTableViewController else {return}
            guard let expense = dataSource[indexPath.row] as? Expense else {return}
            destinationVC.expense = expense
        }
    }
}

extension ExpenseListTableViewController: UISearchBarDelegate {

func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
       if !searchText.isEmpty {
        resultsExpenseFromSearching = ExpenseController.shared.expenses.filter {$0.matches(searchTerm: searchText, name: $0.expenseNameString, category: $0.expenseCategory?.name ?? "")}
        
        //{ $0.matches(searchTerm: searchText, name: $0.incomeNameString, catagory: $0.incomeCategory?.name) }
           self.tableView.reloadData()
       } else {
        resultsExpenseFromSearching = ExpenseController.shared.expenses
           self.tableView.reloadData()
       }
   }

   func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
    searchBar.resignFirstResponder() //Resign the keyboard when user done.
    searchBar.text = ""
     isSearching = false
//           resultsArray = ContactController.shared.contacts
    resultsExpenseFromSearching = ExpenseController.shared.expenses
    self.tableView.reloadData()
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
    //self.incomeSearchBar.endEditing(true)
     isSearching = false
   }

}
