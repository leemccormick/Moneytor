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
    var isSearching: Bool = false
    var resultsExpenseFromSearching: [SearchableRecordDelegate] = []
    var categoriesSections: [[Expense]] {
        return ExpenseCategoryController.shared.expenseCategoriesSections
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
        ExpenseCategoryController.shared.generateSectionsAndSumEachExpenseCategory()
        ExpenseCategoryController.shared.fetchAllExpenseCategories()
    }
    
    // MARK: - Helper Fuctions
    func fetchAllExpenses(){
        ExpenseController.shared.fetchAllExpenses()
        resultsExpenseFromSearching = ExpenseController.shared.expenses
        ExpenseCategoryController.shared.generateSectionsAndSumEachExpenseCategory()
        TotalController.shared.calculateTotalExpense()
        updateFooter(total: TotalController.shared.totalExpense)
        tableView.reloadData()
    }
    
    func updateFooter(total: Double) {
        let footer = UITableView(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: 40))
        footer.backgroundColor = .mtLightYellow
        let lable = UILabel(frame:footer.bounds)
        let totalString = AmountFormatter.currencyInString(num: total)
        lable.text = "TOTAL EXPENSES : \(totalString)  "
        lable.textAlignment = .center
        lable.textColor = .mtTextDarkBrown
        lable.font = UIFont(name: FontNames.textMoneytorGoodLetter, size: 25)
        footer.addSubview(lable)
        tableView.tableFooterView = footer
    }
    
    // MARK: - Table view data source and Table view delegate
    override func numberOfSections(in tableView: UITableView) -> Int {
        if isSearching {
            return 1
        } else {
            return categoriesSections.count
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isSearching {
            return resultsExpenseFromSearching.count
        } else {
            return categoriesSections[section].count
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "expenseCell", for: indexPath)
        
        if isSearching {
            guard let expense = resultsExpenseFromSearching[indexPath.row] as? Expense else {return UITableViewCell()}
            cell.textLabel?.text = "\(expense.expenseCategory?.emoji ?? "💸") \(expense.name ?? "")"
            cell.detailTextLabel?.text = expense.expenseAmountString
            
        } else {
            let expense = categoriesSections[indexPath.section][indexPath.row]
            cell.textLabel?.text = "\(expense.expenseCategory?.emoji ?? "💸") \(expense.name ?? "")"
            cell.detailTextLabel?.text = expense.expenseAmountString
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            
            if isSearching {
                guard let expense = resultsExpenseFromSearching[indexPath.row] as? Expense else {return}
                ExpenseController.shared.deleteExpense(expense)
                fetchAllExpenses()
            } else {
                let expense = categoriesSections[indexPath.section][indexPath.row]
                ExpenseController.shared.deleteExpense(expense)
                fetchAllExpenses()
            }
            tableView.reloadData()
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        
        if categoriesSections[section].count <= 0 {
            return CGFloat(0.01)
        } else {
            return CGFloat(30.0)
        }
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        if isSearching {
            return "🔍 SEARCHING EXPENSES \t\t\t" + TotalController.shared.totalExpenseSearchResultsInString
        } else {
            if tableView.numberOfRows(inSection: section) == 0 {
                return nil
            }
            
            let expenseDict = ExpenseCategoryController.shared.expenseCategoriesTotalDict
            let index = section
            let sectionName = Array(expenseDict)[index].key.uppercased()
            let totalInEachSection = Array(expenseDict)[index].value
            let totalInEachSectionInString = AmountFormatter.currencyInString(num: totalInEachSection)
            return "\(sectionName)  \(totalInEachSectionInString)"
        }
    }
    
    override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        view.tintColor = UIColor.mtDarkYellow
        let header = view as! UITableViewHeaderFooterView
        header.textLabel?.textColor = UIColor.mtTextLightBrown
        header.textLabel?.font = UIFont(name: FontNames.textMoneytorGoodLetter, size: 20)
        header.textLabel?.textAlignment = .center
    }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier ==  "toExpenseDetailVC" {
            guard let indexPath = tableView.indexPathForSelectedRow,
                  let destinationVC = segue.destination as? ExpenseDetailTableViewController else {return}
            if isSearching {
                guard let expense = resultsExpenseFromSearching[indexPath.row] as? Expense else {return}
                destinationVC.expense = expense
            } else {
                let expense = categoriesSections[indexPath.section][indexPath.row]
                destinationVC.expense = expense
            }
        }
    }
}

// MARK: - UISearchBarDelegate
extension ExpenseListTableViewController: UISearchBarDelegate {
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        if !searchText.isEmpty {
            resultsExpenseFromSearching = ExpenseController.shared.expenses.filter{$0.matches(searchTerm: searchText, name: $0.expenseNameString, category: $0.expenseCategory?.name ?? "")}
            
            guard let results = resultsExpenseFromSearching as? [Expense] else {return}
            
            TotalController.shared.calculateTotalExpenseFrom(searchArrayResults: results)
            totalExpenseSearching = TotalController.shared.totalExpenseSearchResults
            self.tableView.reloadData()
        } else {
            fetchAllExpenses()
        }
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        searchBar.text = ""
        isSearching = false
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

