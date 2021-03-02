//
//  ExpenseListTableViewController.swift
//  Moneytor
//
//  Created by Lee McCormick on 2/22/21.
//

import UIKit

class ExpenseListTableViewController: UITableViewController {

    
    // MARK: - Outlets
    @IBOutlet weak var expenseSearchBar: MoneytorSearchBar!
    @IBOutlet weak var activityView: UIView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    
    // MARK: - Properties
//    var resultsExpenseFromSearching: [SearchableRecordDelegate] = []
//    var isSearching: Bool = false
//    var dataSource: [SearchableRecordDelegate] {
//        return isSearching ? resultsExpenseFromSearching : ExpenseController.shared.expenses
//    }
    var resultsExpenseFromSearching: [SearchableRecordDelegate] = []
   // var resultsExpenseFromSearching: [[SearchableRecordDelegate]] = [[]]
    var isSearching: Bool = false
    var dataSource: [[SearchableRecordDelegate]] {
           // self.tableView.reloadData()
            //return isSearching ? resultsExpenseFromSearching : ExpenseCategoryController.shared.categoriesSections
        return ExpenseCategoryController.shared.categoriesSections
    }

    var totalExpenseSearching: Double = TotalController.shared.totalExpense {
        didSet{
            updateFooter(total: totalExpenseSearching)
        }
    }
    
    
    // MARK: - Life Cycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        expenseSearchBar.delegate = self
        fetchAllExpenses()

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fetchAllExpenses()
    }

    
    // MARK: - Actions
    @IBAction func calendarButtonTapped(_ sender: Any) {
        print("================calendarButtonTapped========================")
        print("==================\nExpenseCategoryController.shared.expenseCategorie :: \(ExpenseCategoryController.shared.expenseCategories.count)\n=======================")
//        TotalController.shared.calculateTotalExpenseFromEachCatagory()
        ExpenseCategoryController.shared.calculateTotalExpenseFromEachCatagory()
        
        ExpenseCategoryController.shared.fetchAllExpenseCategory()
    }
    
    func fetchAllExpenses(){
        ExpenseController.shared.fetchAllExpenses()
        resultsExpenseFromSearching = ExpenseController.shared.expenses
        ExpenseCategoryController.shared.calculateTotalExpenseFromEachCatagory()
        //resultsExpenseFromSearching = ExpenseCategoryController.shared.categoriesSections
        TotalController.shared.calculateTotalExpense()
        updateFooter(total: TotalController.shared.totalExpense)
        tableView.reloadData()
    }
    
    func updateFooter(total: Double) {
        let footer = UITableView(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: 40))
        footer.backgroundColor = .mtDarkYellow
        let lable = UILabel(frame:footer.bounds)
        let totalString = AmountFormatter.currencyInString(num: total)
        lable.text = "TOTAL EXPENSES : \(totalString)  "
        lable.textAlignment = .center
        lable.textColor = .mtTextDarkBrown
        lable.font = UIFont(name: FontNames.textMoneytorGoodLetter, size: 25)
        footer.addSubview(lable)
        tableView.tableFooterView = footer
    }
    
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        if isSearching {
            return 1
        } else {
            return dataSource.count
        }
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isSearching {
            return resultsExpenseFromSearching.count
        } else {
            return ExpenseCategoryController.shared.categoriesSections[section].count
        }
    }


    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "expenseCell", for: indexPath)
        //guard let expense = dataSource[indexPath.row] as? Expense else {return UITableViewCell()}
        if isSearching {
            guard let expense = resultsExpenseFromSearching[indexPath.row] as? Expense else {return UITableViewCell()}
            cell.textLabel?.text = "\(expense.expenseCategory?.emoji ?? "💸") \(expense.name ?? "")"
            cell.detailTextLabel?.text = expense.expenseAmountString
            
        } else {
        guard let expense = dataSource[indexPath.section][indexPath.row] as? Expense else {return UITableViewCell()}
        cell.textLabel?.text = "\(expense.expenseCategory?.emoji ?? "💸") \(expense.name ?? "")"
        cell.detailTextLabel?.text = expense.expenseAmountString
        }
        
        return cell
    }
  
    
   
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            if isSearching {
                guard let expense = resultsExpenseFromSearching[indexPath.row] as? Expense else {return}
                ExpenseController.shared.deleteExpense(expense)
                        
                
                fetchAllExpenses()
                
            } else {
                guard let expense = dataSource[indexPath.section][indexPath.row] as? Expense else {return}

                ExpenseController.shared.deleteExpense(expense)
                fetchAllExpenses()
                
            }
            //guard let expense = dataSource[indexPath.row] as? Expense else {return}
            
            
            
          //  resultsExpenseFromSearching = ExpenseCategoryController.shared.categoriesSections
            
            tableView.reloadData()
        }
    }
   
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier ==  "toExpenseDetailVC" {
            guard let indexPath = tableView.indexPathForSelectedRow,
                  let destinationVC = segue.destination as? ExpenseDetailTableViewController else {return}
            //guard let expense = dataSource[indexPath.row] as? Expense else {return}
            if isSearching {
                guard let expense = resultsExpenseFromSearching[indexPath.row] as? Expense else {return}
                
                destinationVC.expense = expense
            } else {
                
                guard let expense = dataSource[indexPath.section][indexPath.row] as? Expense else {return}
                
                destinationVC.expense = expense
            }
            


          
        }
    }
}

extension ExpenseListTableViewController: UISearchBarDelegate {

func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
      
    if !searchText.isEmpty {
        resultsExpenseFromSearching = ExpenseController.shared.expenses.filter{$0.matches(searchTerm: searchText, name: $0.expenseNameString, category: $0.expenseCategory?.name ?? "")}
        
        
        //resultsExpenseFromSearching = resultsArray

      guard let results = resultsExpenseFromSearching as? [Expense] else {return}
//
//
   TotalController.shared.calculateTotalExpenseFrom(searchArrayResults: results)
        totalExpenseSearching = TotalController.shared.totalExpenseSearchResults
        print("\n totalExpenseSearching IN SEARCH BAR TEXTDIDCHANGE::: \(totalExpenseSearching)")
       // updateFooter(total: totalExpenseSearching)
            

        
        
       // self.tableView.reloadData()
        
        //{ $0.matches(searchTerm: searchText, name: $0.incomeNameString, catagory: $0.incomeCategory?.name) }
           self.tableView.reloadData()
       } else {
      //  dataSource = ExpenseCategoryController.shared.categoriesSections
      //  guard let results = resultsExpenseFromSearching as? [Expense] else {return}
        //TotalController.shared.calculateTotalExpenseFrom(searchArrayResults: results)
        self.tableView.reloadData()
       }
    //self.tableView.reloadData()
   }

   func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
    searchBar.resignFirstResponder()
    searchBar.text = ""
     isSearching = false
   // resultsExpenseFromSearching = ExpenseCategoryController.shared.categoriesSections
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
     isSearching = false
   }

}

