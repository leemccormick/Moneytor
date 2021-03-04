//
//  IncomeListTableViewController.swift
//  Moneytor
//
//  Created by Lee McCormick on 2/22/21.
//

import UIKit

class IncomeListTableViewController: UITableViewController {
    
    // MARK: - Outlets
    @IBOutlet weak var incomeSearchBar: MoneytorSearchBar!
    @IBOutlet weak var activityView: UIView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    // MARK: - Properties
    var isSearching: Bool = false
    var resultsIncomeFromSearching: [SearchableRecordDelegate] = []
    var categoriesSections: [[Income]] {
        return IncomeCategoryController.shared.incomeCategoriesSections
    }
    
    var totalIncomeSearching: Double = TotalController.shared.totalIncome {
        didSet{
            updateFooter(total: totalIncomeSearching)
        }
    }
    
    
    // MARK: - Life Cycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        incomeSearchBar.delegate = self
        fetchAllIncomes()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fetchAllIncomes()
        setupSearchBar()
    }
    
    
    
    func setupSearchBar() {
        if IncomeController.shared.incomes.count == 0 {
            incomeSearchBar.isUserInteractionEnabled = false
            incomeSearchBar.placeholder = "Add New Income..."
        } else {
            incomeSearchBar.isUserInteractionEnabled = true
            incomeSearchBar.placeholder = "Search by name or category..."
        }
    }
//    override func viewWillDisappear(_ animated: Bool) {
//        super.viewWillAppear(animated)
//        fetchAllIncomes()
//    }
    
    // MARK: - Actions
    @IBAction func calendarButtonTapped(_ sender: Any) {
//        TotalController.shared.calculateTotalIncome()
//        TotalController.shared.calculateTotalExpense()
//        TotalController.shared.calculateTotalBalance()
//        let totalBalance = TotalController.shared.totalBalance
//        print("\n TOTAL BALANCE ::: \(totalBalance)")
//let sections = IncomeCategoryController.shared.createAnotherSectionByFetchingIncome()
        //print("----------------- sections:: \(sections)-----------------")
        //let income = IncomeController.shared.fetchIncomesByCategory(category: )
    }
    
    // MARK: - Helper Fuctions
    func fetchAllIncomes() {
        IncomeController.shared.fetchAllIncomes()
        resultsIncomeFromSearching = IncomeController.shared.incomes
        IncomeCategoryController.shared.generateSectionsAndSumEachIncomeCategory()
        TotalController.shared.calculateTotalIncome()
        updateFooter(total: TotalController.shared.totalIncome)
        tableView.reloadData()
    }
    
    func updateFooter(total: Double) {
        let footer = UITableView(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: 40))
        footer.backgroundColor = .mtLightYellow
        
        let lable = UILabel(frame:footer.bounds)
        let totalString = AmountFormatter.currencyInString(num: total)
        lable.text = "TOTAL INCOMES : \(totalString)  "
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
            return resultsIncomeFromSearching.count
        } else {
            return categoriesSections[section].count
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "incomeCell", for: indexPath)
        
        if isSearching {
            guard let income = resultsIncomeFromSearching[indexPath.row] as? Income else {return UITableViewCell()}
            cell.textLabel?.text = "\(income.incomeCategory?.emoji ?? "💵") \(income.incomeNameString)"
            cell.detailTextLabel?.text = income.incomeAmountString
        } else {
            let income = categoriesSections[indexPath.section][indexPath.row]
            cell.textLabel?.text = "\(income.incomeCategory?.emoji ?? "💵") \(income.incomeNameString)"
            cell.detailTextLabel?.text = income.incomeAmountString
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            
            if isSearching {
                guard let income = resultsIncomeFromSearching[indexPath.row] as? Income else {return}
                IncomeController.shared.deleteIncome(income)
                fetchAllIncomes()
                setupSearchBar()
            } else {
                let income = categoriesSections[indexPath.section][indexPath.row]
                IncomeController.shared.deleteIncome(income)
                fetchAllIncomes()
                setupSearchBar() 
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
            return "🔍 SEARCHING INCOMES \t\t\t" + TotalController.shared.totalIncomeSearchResultsInString
        } else {
            if tableView.numberOfRows(inSection: section) == 0 {
                return nil
            }
            
            let incomeDict = IncomeCategoryController.shared.incomeCategoriesTotalDict
            let index = section
            let sectionName = Array(incomeDict)[index].key.uppercased()
            let totalInEachSection = Array(incomeDict)[index].value
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
        if segue.identifier == "toIncomeDetailVC" {
            guard let indexPath = tableView.indexPathForSelectedRow,
                  let destinationVC = segue.destination as? IncomeDetailTableViewController else {return}
            
            if isSearching {
                guard let income = resultsIncomeFromSearching[indexPath.row] as? Income else {return}
                destinationVC.income = income
            } else {
                let income = categoriesSections[indexPath.section][indexPath.row]
                destinationVC.income = income
            }
        }
    }
}
// MARK: - UISearchBarDelegate
extension IncomeListTableViewController: UISearchBarDelegate {
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        if !searchText.isEmpty {
            resultsIncomeFromSearching = IncomeController.shared.incomes.filter {$0.matches(searchTerm: searchText, name: $0.incomeNameString, category: $0.incomeCategory?.name ?? "")}
            
            guard let results = resultsIncomeFromSearching
                    as? [Income] else {return}
            
            TotalController.shared.calculateTotalIncomeFrom(searchArrayResults: results)
            totalIncomeSearching = TotalController.shared.totalIncomeSearchResults
            self.tableView.reloadData()
        } else {
            fetchAllIncomes()
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


/* NOTE NEED Help
 
 - Keyboard need to be hide after done searching on searchbar
 
 
 
 //______________________________________________________________________________________
 */
