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
    var categoriesSections: [[Income]] =  IncomeCategoryController.shared.incomeCategoriesSections
    var totalIncomeSearching: Double = TotalController.shared.totalIncome {
        didSet{
            updateFooter(total: totalIncomeSearching)
        }
    }
    let daily = Calendar.current.date(byAdding: .day, value: -1, to: Date())!
    let weekly = Calendar.current.date(byAdding: .day, value: -7, to: Date())!
    let monthly = Calendar.current.date(byAdding: .month, value: -1, to: Date())!
    
    // MARK: - Life Cycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        incomeSearchBar.delegate = self
        //fetchAllIncomes()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        incomeSearchBar.selectedScopeButtonIndex = 1
        fetchIncomesBySpecificTime(time: weekly)
         
       
        //tableView.reloadData()
    }
    
    // MARK: - Actions
    @IBAction func calendarButtonTapped(_ sender: Any) {
        categoriesSections = IncomeCategoryController.shared.generateSectionsCategoiesByTimePeriod(daily)
    }
    
    // MARK: - Helper Fuctions
    func fetchAllIncomes() {
        IncomeController.shared.fetchAllIncomes()
        resultsIncomeFromSearching = IncomeController.shared.incomes
        setupSearchBar(incomeCount: resultsIncomeFromSearching.count)
       IncomeCategoryController.shared.generateSectionsAndSumEachIncomeCategory()
        categoriesSections = IncomeCategoryController.shared.generateSectionsCategoiesByTimePeriod(weekly)
        TotalController.shared.calculateTotalIncomesBySpecificTime(weekly)
        updateFooter(total: TotalController.shared.totalIncomeBySpecificTime)
        
        tableView.reloadData()
    }
    
    func fetchIncomesBySpecificTime(time: Date) {
        let incomes = IncomeController.shared.fetchIncomesFromTimePeriod(time)
       // resultsIncomeFromSearching = IncomeController.shared.incomes
        setupSearchBar(incomeCount: incomes.count)
       IncomeCategoryController.shared.generateSectionsAndSumEachIncomeCategory()
        
        categoriesSections = IncomeCategoryController.shared.generateSectionsCategoiesByTimePeriod(time)
        TotalController.shared.calculateTotalIncomesBySpecificTime(time)
        updateFooter(total: TotalController.shared.totalIncomeBySpecificTime)
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
    
    func setupSearchBar(incomeCount: Int) {
        if incomeCount == 0 {
            incomeSearchBar.isUserInteractionEnabled = false
            incomeSearchBar.placeholder = "Add New Income..."
        } else {
            incomeSearchBar.isUserInteractionEnabled = true
            incomeSearchBar.placeholder = "Search by name or category..."
        }
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
               
            } else {
                let income = categoriesSections[indexPath.section][indexPath.row]
                IncomeController.shared.deleteIncome(income)
                
                if incomeSearchBar.selectedScopeButtonIndex == 0 {
                    fetchIncomesBySpecificTime(time: daily)
                } else if  incomeSearchBar.selectedScopeButtonIndex == 2 {
                    fetchIncomesBySpecificTime(time: monthly)
                } else {
                    fetchIncomesBySpecificTime(time: weekly)
                }
                
               
              
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
            
            let totalInEachSection = incomeDict[index].value
            let totalInEachSectionInString = AmountFormatter.currencyInString(num: totalInEachSection)
            
            
            print("\n\n\n----------------- sectionName :: \(sectionName)-----------------")
            return "\(sectionName.dropLast())  \(totalInEachSectionInString)"
            
            // return ""
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
            //searchBar.showsScopeBar = true
            resultsIncomeFromSearching = IncomeController.shared.incomes.filter {$0.matches(searchTerm: searchText, name: $0.incomeNameString, category: $0.incomeCategory?.nameString ?? "")}
            
            guard let results = resultsIncomeFromSearching
                    as? [Income] else {return}
            
            if !results.isEmpty {
                
                TotalController.shared.calculateTotalIncomeFrom(searchArrayResults: results)
                totalIncomeSearching = TotalController.shared.totalIncomeSearchResults
            } else {
                totalIncomeSearching = 0.0
            }
            
            self.tableView.reloadData()
        } else if searchText == "" {
            resultsIncomeFromSearching = []
            self.tableView.reloadData()
        }
    }
    
    func searchBar(_ searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
        print(selectedScope)
        
        if selectedScope == 0 {
            //daily
            categoriesSections = IncomeCategoryController.shared.generateSectionsCategoiesByTimePeriod(daily)
            fetchIncomesBySpecificTime(time: daily)
            // categoriesSections = IncomeCategoryController.shared.incomeCategoriesSections
        } else if selectedScope == 2 {
            // mounthly
            categoriesSections = IncomeCategoryController.shared.generateSectionsCategoiesByTimePeriod(monthly)
            fetchIncomesBySpecificTime(time: monthly)
            // categoriesSections = IncomeCategoryController.shared.incomeCategoriesSections
            
        } else {
            // weekly
            categoriesSections =  IncomeCategoryController.shared.generateSectionsCategoiesByTimePeriod(weekly)
            fetchIncomesBySpecificTime(time: weekly)
        }
    }
    
    func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool {
        searchBar.showsScopeBar = false
        // totalIncomeSearching = 0.0
        return true
    }
    
    func searchBarShouldEndEditing(_ searchBar: UISearchBar) -> Bool {
        searchBar.showsScopeBar = true
        //totalIncomeSearching = 0.0
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
        resultsIncomeFromSearching = []
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


/* NOTE NEED Help
 
 - Keyboard need to be hide after done searching on searchbar
 
 
 
 //______________________________________________________________________________________
 */
