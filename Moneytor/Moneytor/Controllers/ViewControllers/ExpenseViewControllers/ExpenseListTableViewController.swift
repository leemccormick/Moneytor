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
    let daily = ExpenseCategoryController.shared.daily
    let weekly = ExpenseCategoryController.shared.weekly
    let monthly = ExpenseCategoryController.shared.monthly
    var isSearching: Bool = false
    var resultsExpenseFromSearching: [SearchableRecordDelegate] = []
    var categoriesSectionsByDay: [[Expense]] = []
    var categoriesSectionsByWeek: [[Expense]] = []
    var categoriesSectionsByMonth: [[Expense]] = []
    var totalExpenseSearching: Double = 0.0 {
        didSet{
            updateFooter(total: totalExpenseSearching)
        }
    }
    
    // MARK: - Life Cycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        expenseSearchBar.delegate = self
        categoriesSectionsByDay =  ExpenseCategoryController.shared.generateSectionsCategoiesByTimePeriod(start: daily, end: Date())
        categoriesSectionsByWeek =  ExpenseCategoryController.shared.generateSectionsCategoiesByTimePeriod(start: Date().startOfWeek, end: Date().endOfWeek)
        categoriesSectionsByMonth  =  ExpenseCategoryController.shared.generateSectionsCategoiesByTimePeriod(start: Date().startDateOfMonth, end: Date().endDateOfMonth)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        expenseSearchBar.selectedScopeButtonIndex = 1
        categoriesSectionsByWeek = fetchExpensesBySpecificTime(start: Date().startOfWeek, end: Date().endDateOfMonth)
        tableView.reloadData()
    }
    
    // MARK: - Actions
    @IBAction func expenseAddButtonTapped(_ sender: Any) {
        isSearching = false
    }
    
    @IBAction func expenseDocumentScannerButtonTapped(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let expenseDocVC = storyboard.instantiateViewController(identifier: "expenseDocStoryBoardID")
        expenseDocVC.modalPresentationStyle = .pageSheet 
        self.present(expenseDocVC, animated: true, completion: nil)
    }
    
    // MARK: - Helper Fuctions
    func fetchAllExpenses(){
        ExpenseController.shared.fetchAllExpenses()
        resultsExpenseFromSearching = ExpenseController.shared.expenses
        updateFooter(total: TotalController.shared.totalExpenseSearchResults)
        tableView.reloadData()
    }
    
    func fetchExpensesBySpecificTime(start: Date, end: Date) -> [[Expense]] {
        let newCategoriesSections = ExpenseCategoryController.shared.generateSectionsCategoiesByTimePeriod(start: start, end: end)
        TotalController.shared.calculateTotalExpensesBySpecificTime(startedTime: start, endedTime: end)
        updateFooter(total: TotalController.shared.totalExpenseBySpecificTime)
        tableView.reloadData()
        return newCategoriesSections
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
    
    func configurateSectionTitle(categoriesSections: [[Expense]], section: Int) -> String {
        if tableView.numberOfRows(inSection: section) == 0 {
            return ""
        } else {
            var total = 0.0
            var name = ""
            var totalExpenseInEachSections: [Double] = []
            var sectionNames: [String] = []
            for section in categoriesSections {
                total = 0.0
                for expense in section {
                    
                    total += expense.expenseAmountInDouble
                    name = expense.expenseCategory?.nameString ?? ""
                    
                }
                totalExpenseInEachSections.append(total)
                sectionNames.append(name)
            }
            let categoryName = sectionNames[section]
            let categoryTotal = totalExpenseInEachSections[section]
            let categoryTotalString = AmountFormatter.currencyInString(num: categoryTotal)
            return "\(categoryName.uppercased()) \(categoryTotalString)"
        }
    }
    
    // MARK: - Table view data source and Table view delegate
    override func numberOfSections(in tableView: UITableView) -> Int {
        if isSearching {
            return 1
        } else {
            switch expenseSearchBar.selectedScopeButtonIndex {
            case 0:
                return categoriesSectionsByDay.count
            case 1:
                return categoriesSectionsByWeek.count
            case 2:
                return categoriesSectionsByMonth.count
            default:
                return 0
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isSearching {
            return resultsExpenseFromSearching.count
        } else {
            switch expenseSearchBar.selectedScopeButtonIndex {
            case 0:
                return categoriesSectionsByDay[section].count
            case 1:
                return categoriesSectionsByWeek[section].count
            case 2:
                return categoriesSectionsByMonth[section].count
            default:
                return 0
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var returnCell = UITableViewCell()
        if isSearching {
            let searchcCell = tableView.dequeueReusableCell(withIdentifier: "expenseCell", for: indexPath)
            guard let expense = resultsExpenseFromSearching[indexPath.row] as? Expense else {return UITableViewCell()}
            searchcCell.textLabel?.numberOfLines = 0
            searchcCell.textLabel?.text = "\(expense.expenseCategory?.emoji ?? "💵") \(expense.expenseNameString.capitalized) \n\(expense.expenseDateText)"
            searchcCell.detailTextLabel?.text = expense.expenseAmountString
            returnCell = searchcCell
        } else  {
            let scopeCell = tableView.dequeueReusableCell(withIdentifier: "expenseNotSearchingCell", for: indexPath)
            switch expenseSearchBar.selectedScopeButtonIndex {
            case 0:
                let expense = categoriesSectionsByDay[indexPath.section][indexPath.row]
                scopeCell.textLabel?.numberOfLines = 0
                scopeCell.textLabel?.text = "\(expense.expenseCategory?.emoji ?? "💵") \(expense.expenseNameString.capitalized) \n\(expense.expenseDateText)"
                scopeCell.detailTextLabel?.text = expense.expenseAmountString
                returnCell = scopeCell
            case 1:
                let expense = categoriesSectionsByWeek[indexPath.section][indexPath.row]
                scopeCell.textLabel?.numberOfLines = 0
                scopeCell.textLabel?.text = "\(expense.expenseCategory?.emoji ?? "💵") \(expense.expenseNameString.capitalized) \n\(expense.expenseDateText)"
                scopeCell.detailTextLabel?.text = expense.expenseAmountString
                returnCell = scopeCell
            case 2:
                let expense = categoriesSectionsByMonth[indexPath.section][indexPath.row]
                scopeCell.textLabel?.numberOfLines = 0
                scopeCell.textLabel?.text = "\(expense.expenseCategory?.emoji ?? "💵") \(expense.expenseNameString.capitalized) \n\(expense.expenseDateText)"
                scopeCell.detailTextLabel?.text = expense.expenseAmountString
                returnCell = scopeCell
            default:
                returnCell = UITableViewCell()
            }
        }
        return returnCell
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            if isSearching == true {
                guard let expense = self.resultsExpenseFromSearching[indexPath.row] as? Expense else {return}
                let alertController = UIAlertController(title: "Are you sure to delete this Expense?", message: "Name : \(expense.expenseNameString) \nAmount : \(expense.expenseAmountString) \nCategory : \(expense.expenseCategory!.nameString.capitalized) \nDate : \(expense.expenseDateText)", preferredStyle: .actionSheet)
                let dismissAction = UIAlertAction(title: "Cancel", style: .cancel)
                let deleteAction = UIAlertAction(title: "Delete", style: .destructive) { (_) in
                    ExpenseController.shared.deleteExpense(expense)
                    self.fetchAllExpenses()
                }
                alertController.addAction(dismissAction)
                alertController.addAction(deleteAction)
                present(alertController, animated: true)
                
            } else {
                switch expenseSearchBar.selectedScopeButtonIndex {
                case 0:
                    let expense = self.categoriesSectionsByDay[indexPath.section][indexPath.row]
                    let alertController = UIAlertController(title: "Are you sure to delete this Expense?", message: "Name : \(expense.expenseNameString) \nAmount : \(expense.expenseAmountString) \nCategory : \(expense.expenseCategory?.nameString ?? "_Other")  \nDate : \(expense.expenseDateText)", preferredStyle: .actionSheet)
                    let dismissAction = UIAlertAction(title: "Cancel", style: .cancel)
                    let deleteAction = UIAlertAction(title: "Delete", style: .destructive) { (_) in
                        
                        ExpenseController.shared.deleteExpense(expense)
                        //  guard let indexToDelete = self.categoriesSectionsByDay[indexPath.section][indexPath.row] else {return}
                        // print("\n===================indexToDelete : \(indexToDelete) IN \(#function) ======================\n")
                        self.categoriesSectionsByDay[indexPath.section].remove(at: indexPath.row)
                        tableView.deleteRows(at: [indexPath], with: .fade)
                        tableView.reloadData()
                        self.categoriesSectionsByDay = self.fetchExpensesBySpecificTime(start: self.daily, end: Date())
                    }
                    alertController.addAction(dismissAction)
                    alertController.addAction(deleteAction)
                    present(alertController, animated: true)
                    
                case 1:
                    let expense = self.categoriesSectionsByWeek[indexPath.section][indexPath.row]
                    let alertController = UIAlertController(title: "Are you sure to delete this Expense?", message: "Name : \(expense.expenseNameString) \nAmount : \(expense.expenseAmountString) \nCategory : \(expense.expenseCategory?.nameString ?? "_Other") \nDate : \(expense.expenseDateText)", preferredStyle: .actionSheet)
                    let dismissAction = UIAlertAction(title: "Cancel", style: .cancel)
                    let deleteAction = UIAlertAction(title: "Delete", style: .destructive) { (_) in
                        
                        ExpenseController.shared.deleteExpense(expense)
                        //guard let indexToDelete = self.categoriesSectionsByWeek.firstIndex(of: [expense]) else {return}
                        //print("\n===================indexToDelete : \(indexToDelete) IN \(#function) ======================\n")
                        
                        self.categoriesSectionsByWeek[indexPath.section].remove(at: indexPath.row)
                        tableView.deleteRows(at: [indexPath], with: .fade)
                        tableView.reloadData()
                        self.categoriesSectionsByWeek = self.fetchExpensesBySpecificTime(start: Date().startOfWeek, end: Date().endOfWeek)
                        
                    }
                    alertController.addAction(dismissAction)
                    alertController.addAction(deleteAction)
                    present(alertController, animated: true)
                case 2:
                    let expense = self.categoriesSectionsByMonth[indexPath.section][indexPath.row]
                    let alertController = UIAlertController(title: "Are you sure to delete this Expense?", message: "Name : \(expense.expenseNameString) \nAmount : \(expense.expenseAmountString) \nCategory : \(expense.expenseCategory?.nameString ?? "_Other") \nDate : \(expense.expenseDateText)", preferredStyle: .actionSheet)
                    
                    let dismissAction = UIAlertAction(title: "Cancel", style: .cancel)
                    let deleteAction = UIAlertAction(title: "Delete", style: .destructive) { (_) in
                        
                        ExpenseController.shared.deleteExpense(expense)
                        //                                        guard let indexToDelete = self.categoriesSectionsByMonth.firstIndex(of: [expense]) else {return}
                        //                                        print("\n===================indexToDelete : \(indexToDelete) IN \(#function) ======================\n")
                        
                        self.categoriesSectionsByMonth[indexPath.section].remove(at: indexPath.row)
                        tableView.deleteRows(at: [indexPath], with: .fade)
                        tableView.reloadData()
                        self.categoriesSectionsByMonth = self.fetchExpensesBySpecificTime(start: Date().startDateOfMonth, end: Date().endDateOfMonth)
                        
                    }
                    alertController.addAction(dismissAction)
                    alertController.addAction(deleteAction)
                    present(alertController, animated: true)
                default:
                    print("\n===================ERROR! DELETED EXPENSE IN\(#function) ======================\n")
                }
            }
        }
    }
    
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if isSearching {
            return CGFloat(30.0)
        } else {
            switch expenseSearchBar.selectedScopeButtonIndex {
            case 0:
                if categoriesSectionsByDay[section].count == 0 {
                    return CGFloat(0.01)
                } else {
                    return CGFloat(30.0)
                }
            case 1:
                if categoriesSectionsByWeek[section].count == 0 {
                    return CGFloat(0.01)
                } else {
                    return CGFloat(30.0)
                }
            case 2:
                if categoriesSectionsByMonth[section].count == 0 {
                    return CGFloat(0.01)
                } else {
                    return CGFloat(30.0)
                }
            default:
                return 0
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        if isSearching {
            return "🔍 SEARCHING EXPENSES \t\t\t" + AmountFormatter.currencyInString(num: totalExpenseSearching)
        } else {
            switch expenseSearchBar.selectedScopeButtonIndex {
            case 0:
                let title = configurateSectionTitle(categoriesSections: categoriesSectionsByDay, section: section)
                tableView.reloadData()
                return title
            case 1:
                let title = configurateSectionTitle(categoriesSections: categoriesSectionsByWeek, section: section)
                return title
            case 2:
                let title = configurateSectionTitle(categoriesSections: categoriesSectionsByMonth, section: section)
                return title
            default:
                return ""
            }
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
            print("Row #: \(indexPath) \(#function)")
            if isSearching {
                guard let expense = resultsExpenseFromSearching[indexPath.row] as? Expense else {return}
                destinationVC.expense = expense
            }
        }
        
        
        if segue.identifier ==  "toExpenseDetailVCByScopeBar" {
            guard let indexPath = tableView.indexPathForSelectedRow,
                  let destinationVC = segue.destination as? ExpenseDetailTableViewController else {return}
            print("Row #: \(indexPath) \(#function)")
            switch expenseSearchBar.selectedScopeButtonIndex {
            case 0:
                let expense = categoriesSectionsByDay[indexPath.section][indexPath.row]
                destinationVC.expense = expense
            case 1:
                let expense = categoriesSectionsByWeek[indexPath.section][indexPath.row]
                destinationVC.expense = expense
            case 2:
                let expense = categoriesSectionsByMonth[indexPath.section][indexPath.row]
                destinationVC.expense = expense
            default:
                print("\n===================ERROR! IN \(#function) ======================\n")
            }
        }
        
    }
    
}

// MARK: - UISearchBarDelegate
extension ExpenseListTableViewController: UISearchBarDelegate {
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if !searchText.isEmpty {
            fetchAllExpenses()
            resultsExpenseFromSearching = ExpenseController.shared.expenses.filter{$0.matches(searchTerm: searchText, name: $0.expenseNameString, category: $0.expenseCategory?.name ?? "", date: $0.expenseDateText)}
            
            guard let results = resultsExpenseFromSearching as? [Expense] else {return}
            if !results.isEmpty {
                TotalController.shared.calculateTotalExpenseFrom(searchArrayResults: results)
                totalExpenseSearching = TotalController.shared.totalExpenseSearchResults
                self.tableView.reloadData()
            } else {
                totalExpenseSearching = 0.0
                self.tableView.reloadData()
            }
            self.tableView.reloadData()
        } else if searchText == "" {
            resultsExpenseFromSearching = []
            totalExpenseSearching = 0.0
            self.tableView.reloadData()
        }
    }
    
    func searchBar(_ searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
        
        switch expenseSearchBar.selectedScopeButtonIndex {
        case 0:
            categoriesSectionsByDay = fetchExpensesBySpecificTime(start: daily, end: Date())
            tableView.reloadData()
        case 1:
            categoriesSectionsByWeek = fetchExpensesBySpecificTime(start: Date().startOfWeek, end: Date().endOfWeek)
            tableView.reloadData()
        case 2:
            categoriesSectionsByMonth = fetchExpensesBySpecificTime(start: Date().startDateOfMonth, end: Date().endDateOfMonth)
            tableView.reloadData()
        default:
            tableView.reloadData()
        }
    }
    
    func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool {
        searchBar.showsScopeBar = false
        isSearching = true
        return true
    }
    
    func searchBarShouldEndEditing(_ searchBar: UISearchBar) -> Bool {
        searchBar.showsScopeBar = true
        isSearching = false
        return true
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        searchBar.text = ""
        isSearching = false
        self.tableView.reloadData()
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        isSearching = true
        resultsExpenseFromSearching = []
        tableView.reloadData()
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


/*
 
 @IBOutlet weak var expenseSearchBar: MoneytorSearchBar!
 @IBOutlet weak var activityView: UIView!
 @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
 
 // MARK: - Properties
 let daily = ExpenseCategoryController.shared.daily
 let weekly = ExpenseCategoryController.shared.weekly
 let monthly = ExpenseCategoryController.shared.monthly
 var isSearching: Bool = false
 var resultsExpenseFromSearching: [SearchableRecordDelegate] = []
 var sectionsExpenseDict = [Dictionary<String, Double>.Element]()
 var categoriesSections: [[Expense]] =  ExpenseCategoryController.shared.generateSectionsCategoiesByTimePeriod(start: Date().startOfWeek, end: Date().endOfWeek)
 var totalExpenseSearching: Double = 0.0 {
 didSet{
 updateFooter(total: totalExpenseSearching)
 }
 }
 
 // MARK: - Life Cycle Methods
 override func viewDidLoad() {
 super.viewDidLoad()
 expenseSearchBar.delegate = self
 self.tableView.allowsSelection = true
 }
 
 override func viewWillAppear(_ animated: Bool) {
 super.viewWillAppear(animated)
 expenseSearchBar.selectedScopeButtonIndex = 1
 fetchExpensesBySpecificTime(start: Date().startOfWeek, end: Date().endDateOfMonth)
 tableView.reloadData()
 }
 
 // MARK: - Actions
 @IBAction func expenseAddButtonTapped(_ sender: Any) {
 isSearching = false
 }
 
 @IBAction func expenseDocumentScannerButtonTapped(_ sender: Any) {
 let storyboard = UIStoryboard(name: "Main", bundle: nil)
 let expenseDocVC = storyboard.instantiateViewController(identifier: "expenseDocStoryBoardID")
 expenseDocVC.modalPresentationStyle = .pageSheet
 self.present(expenseDocVC, animated: true, completion: nil)
 }
 
 // MARK: - Helper Fuctions
 func fetchAllExpenses(){
 ExpenseController.shared.fetchAllExpenses()
 resultsExpenseFromSearching = ExpenseController.shared.expenses
 updateFooter(total: TotalController.shared.totalExpenseSearchResults)
 tableView.reloadData()
 }
 
 func fetchExpensesBySpecificTime(start: Date, end: Date) {
 categoriesSections = ExpenseCategoryController.shared.generateSectionsCategoiesByTimePeriod(start: start, end: end)
 TotalController.shared.calculateTotalExpensesBySpecificTime(startedTime: start, endedTime: end)
 updateFooter(total: TotalController.shared.totalExpenseBySpecificTime)
 sectionsExpenseDict = ExpenseCategoryController.shared.generateCategoryDictionaryByExpensesAndReturnDict(sections: categoriesSections)
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
 var returnCell = UITableViewCell()
 
 if isSearching {
 let searchcCell = tableView.dequeueReusableCell(withIdentifier: "expenseCell", for: indexPath)
 guard let expense = resultsExpenseFromSearching[indexPath.row] as? Expense else {return UITableViewCell()}
 searchcCell.textLabel?.numberOfLines = 0
 searchcCell.textLabel?.text = "\(expense.expenseCategory?.emoji ?? "💵") \(expense.expenseNameString.capitalized) \n\(expense.expenseDateText)"
 searchcCell.detailTextLabel?.text = expense.expenseAmountString
 returnCell = searchcCell
 } else {
 let scopeCell = tableView.dequeueReusableCell(withIdentifier: "expenseNotSearchingCell", for: indexPath)
 if !categoriesSections[indexPath.section].isEmpty {
 
 let expense = categoriesSections[indexPath.section][indexPath.row]
 scopeCell.textLabel?.numberOfLines = 0
 scopeCell.textLabel?.text = "\(expense.expenseCategory?.emoji ?? "💵") \(expense.expenseNameString.capitalized) \n\(expense.expenseDateText)"
 scopeCell.detailTextLabel?.text = expense.expenseAmountString
 
 returnCell = scopeCell
 }
 }
 return returnCell
 }
 
 override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
 if editingStyle == .delete {
 
 if self.isSearching == false {
 let expense = self.categoriesSections[indexPath.section][indexPath.row]
 let alertController = UIAlertController(title: "Are you sure to delete this Expense?", message: "Name : \(expense.expenseNameString) \nAmount : \(expense.expenseAmountString) \nCategory : \(expense.expenseCategory!.nameString.capitalized) \nDate : \(expense.expenseDateText)", preferredStyle: .actionSheet)
 let dismissAction = UIAlertAction(title: "Cancel", style: .cancel)
 let deleteAction = UIAlertAction(title: "Delete", style: .destructive) { (_) in
 
 ExpenseController.shared.deleteExpense(expense)
 
 
 if self.expenseSearchBar.selectedScopeButtonIndex == 0 {
 self.fetchExpensesBySpecificTime(start: self.daily, end: Date())
 } else if self.expenseSearchBar.selectedScopeButtonIndex == 2 {
 self.fetchExpensesBySpecificTime(start: Date().startDateOfMonth, end: Date().endDateOfMonth)
 } else {
 self.fetchExpensesBySpecificTime(start: Date().startOfWeek, end: Date().endOfWeek)
 }
 }
 alertController.addAction(dismissAction)
 alertController.addAction(deleteAction)
 present(alertController, animated: true)
 } else if self.isSearching == true {
 guard let expense = self.resultsExpenseFromSearching[indexPath.row] as? Expense else {return}
 let alertController = UIAlertController(title: "Are you sure to delete this Expense?", message: "Name : \(expense.expenseNameString) \nAmount : \(expense.expenseAmountString) \nCategory : \(expense.expenseCategory!.nameString.capitalized) \nDate : \(expense.expenseDateText)", preferredStyle: .actionSheet)
 let dismissAction = UIAlertAction(title: "Cancel", style: .cancel)
 let deleteAction = UIAlertAction(title: "Delete", style: .destructive) { (_) in
 ExpenseController.shared.deleteExpense(expense)
 self.fetchAllExpenses()
 }
 alertController.addAction(dismissAction)
 alertController.addAction(deleteAction)
 present(alertController, animated: true)
 
 }
 tableView.reloadData()
 }
 }
 
 override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
 if isSearching {
 return CGFloat(30.0)
 } else {
 if categoriesSections[section].count == 0 {
 return CGFloat(0.01)
 } else {
 return CGFloat(30.0)
 }
 }
 }
 
 override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
 
 if isSearching {
 return "🔍 SEARCHING EXPENSES \t\t\t" + AmountFormatter.currencyInString(num: totalExpenseSearching)
 } else {
 if tableView.numberOfRows(inSection: section) == 0 {
 return nil
 } else {
 if self.expenseSearchBar.selectedScopeButtonIndex == 0 {
 self.fetchExpensesBySpecificTime(start: self.daily, end: Date())
 var total = 0.0
 var name = ""
 var totalExpenseInEachSections: [Double] = []
 var sectionNames: [String] = []
 for section in categoriesSections {
 total = 0.0
 for expense in section {
 total += expense.amount as! Double
 name = expense.expenseCategory?.nameString ?? ""
 }
 totalExpenseInEachSections.append(total)
 sectionNames.append(name)
 }
 let categoryName = sectionNames[section]
 let categoryTotal = totalExpenseInEachSections[section]
 let categoryTotalString = AmountFormatter.currencyInString(num: categoryTotal)
 return "\(categoryName.uppercased()) \(categoryTotalString)"
 } else if self.expenseSearchBar.selectedScopeButtonIndex == 2 {
 self.fetchExpensesBySpecificTime(start: Date().startDateOfMonth, end: Date().endDateOfMonth)
 var total = 0.0
 var name = ""
 var totalExpenseInEachSections: [Double] = []
 var sectionNames: [String] = []
 for section in categoriesSections {
 total = 0.0
 for expense in section {
 total += expense.amount as! Double
 name = expense.expenseCategory?.nameString ?? ""
 }
 totalExpenseInEachSections.append(total)
 sectionNames.append(name)
 }
 let categoryName = sectionNames[section]
 let categoryTotal = totalExpenseInEachSections[section]
 let categoryTotalString = AmountFormatter.currencyInString(num: categoryTotal)
 return "\(categoryName.uppercased()) \(categoryTotalString)"
 } else {
 self.fetchExpensesBySpecificTime(start: Date().startOfWeek, end: Date().endOfWeek)
 var total = 0.0
 var name = ""
 var totalExpenseInEachSections: [Double] = []
 var sectionNames: [String] = []
 for section in categoriesSections {
 total = 0.0
 for expense in section {
 total += expense.amount as! Double
 name = expense.expenseCategory?.nameString ?? ""
 }
 totalExpenseInEachSections.append(total)
 sectionNames.append(name)
 }
 let categoryName = sectionNames[section]
 let categoryTotal = totalExpenseInEachSections[section]
 let categoryTotalString = AmountFormatter.currencyInString(num: categoryTotal)
 return "\(categoryName.uppercased()) \(categoryTotalString)"}
 }
 
 }
 }
 
 override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
 print("Row #: \(indexPath) \(#function)")
 tableView.deselectRow(at: indexPath, animated: true)
 guard let detailVC = UIStoryboard(name: "Main", bundle: nil)  .instantiateViewController(withIdentifier: "expenseDetailVCStoryBoard") as? ExpenseDetailTableViewController else {return}
 
 let nav = UINavigationController(rootViewController: self)
 nav.navigationItem.backBarButtonItem?.isEnabled = true
 detailVC.expense = categoriesSections[indexPath.section][indexPath.row]
 
 nav.modalPresentationStyle = .fullScreen
 present(nav, animated: true, completion: nil)
 
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
 print("Row #: \(indexPath) \(#function)")
 if isSearching == true {
 guard let expense = resultsExpenseFromSearching[indexPath.row] as? Expense else {return}
 destinationVC.expense = expense
 }
 }
 //toExpenseDetailVCByScopeBar
 
 if segue.identifier ==  "toExpenseDetailVCByScopeBar" {
 guard let indexPath = tableView.indexPathForSelectedRow,
 let destinationVC = segue.destination as? ExpenseDetailTableViewController else {return}
 print("Row #: \(indexPath) \(#function)")
 if isSearching == false {
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
 fetchAllExpenses()
 resultsExpenseFromSearching = ExpenseController.shared.expenses.filter{$0.matches(searchTerm: searchText, name: $0.expenseNameString, category: $0.expenseCategory?.name ?? "", date: $0.expenseDateText)}
 
 guard let results = resultsExpenseFromSearching as? [Expense] else {return}
 if !results.isEmpty {
 TotalController.shared.calculateTotalExpenseFrom(searchArrayResults: results)
 totalExpenseSearching = TotalController.shared.totalExpenseSearchResults
 self.tableView.reloadData()
 } else {
 totalExpenseSearching = 0.0
 self.tableView.reloadData()
 }
 self.tableView.reloadData()
 } else if searchText == "" {
 resultsExpenseFromSearching = []
 totalExpenseSearching = 0.0
 self.tableView.reloadData()
 }
 }
 
 func searchBar(_ searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
 if selectedScope == 0 {
 categoriesSections = ExpenseCategoryController.shared.generateSectionsCategoiesByTimePeriod(start: self.daily, end: Date())
 self.fetchExpensesBySpecificTime(start: self.daily, end: Date())
 self.tableView.allowsSelection = true
 } else if selectedScope == 2 {
 categoriesSections = ExpenseCategoryController.shared.generateSectionsCategoiesByTimePeriod(start: Date().startDateOfMonth, end: Date().endDateOfMonth)
 self.fetchExpensesBySpecificTime(start: Date().startDateOfMonth, end: Date().endDateOfMonth)
 self.tableView.allowsSelection = true
 
 } else {
 categoriesSections =  ExpenseCategoryController.shared.generateSectionsCategoiesByTimePeriod(start: Date().startOfWeek, end: Date().endOfWeek)
 self.fetchExpensesBySpecificTime(start: Date().startOfWeek, end: Date().endOfWeek)
 self.tableView.allowsSelection = true
 
 }
 }
 
 func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool {
 searchBar.showsScopeBar = false
 isSearching = true
 return true
 }
 
 func searchBarShouldEndEditing(_ searchBar: UISearchBar) -> Bool {
 searchBar.showsScopeBar = true
 isSearching = false
 return true
 }
 
 func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
 searchBar.resignFirstResponder()
 searchBar.text = ""
 isSearching = false
 self.tableView.reloadData()
 }
 
 func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
 isSearching = true
 resultsExpenseFromSearching = []
 tableView.reloadData()
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
 
 
 */
