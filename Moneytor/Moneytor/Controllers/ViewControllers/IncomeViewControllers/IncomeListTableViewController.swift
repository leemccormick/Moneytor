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
    var resultsIncomeFromSearching: [SearchableRecordDelegate] = []
    var isSearching: Bool = false
    
    
    var dataSource: [SearchableRecordDelegate] {
        return isSearching ? resultsIncomeFromSearching : IncomeController.shared.incomes
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
        //TotalController.shared.calculateTotalIncome()
        //  IncomeCategoryController.shared.generateIncomeCategories()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fetchAllIncome()
    }
    
    
    
    // MARK: - Actions
    
    @IBAction func calendarButtonTapped(_ sender: Any) {
        TotalController.shared.calculateTotalIncome()
        TotalController.shared.calculateTotalExpense()
        TotalController.shared.calculateTotalBalance()
        let totalBalance = TotalController.shared.totalBalance
        print("\n TOTAL BALANCE ::: \(totalBalance)")
        
    }
    
    
    // MARK: - Helper Fuctions
    func fetchAllIncome() {
        IncomeController.shared.fetchAllIncomes()
        resultsIncomeFromSearching = IncomeController.shared.incomes
        TotalController.shared.calculateTotalIncome()
        updateFooter(total: TotalController.shared.totalIncome)
        tableView.reloadData()
    }
    
    func updateFooter(total: Double) {
        let footer = UITableView(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: 40))
        footer.backgroundColor = .mtDarkYellow
        
        let lable = UILabel(frame:footer.bounds)
        let totalString = AmountFormatter.currencyInString(num: total)
        lable.text = "TOTAL INCOMES : \(totalString)  "
        lable.textAlignment = .center
        lable.textColor = .mtTextDarkBrown
        lable.font = UIFont(name: FontNames.textMoneytorGoodLetter, size: 25)
        footer.addSubview(lable)
        tableView.tableFooterView = footer
    }
    
    
    
    // MARK: - Table view data source
    
    //    override func numberOfSections(in tableView: UITableView) -> Int {
    //        return dataSource.count
    //    }
    //
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.count
        
        //return IncomeController.shared.incomes.count
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "incomeCell", for: indexPath)
        //let income = IncomeController.shared.incomes[indexPath.row]
        guard let income = dataSource[indexPath.row] as? Income else {return UITableViewCell()}
        cell.textLabel?.text = "\(income.incomeCategory?.emoji ?? "💵") \(income.incomeNameString)"
        cell.detailTextLabel?.text = income.incomeAmountString
        // Configure the cell...
        return cell
    }
    
    
    
    
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            guard let income = dataSource[indexPath.row] as? Income else {return}
            IncomeController.shared.deleteIncome(income)
            tableView.reloadData()
        }
    }
    
    
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toIncomeDetailVC" {
            guard let indexPath = tableView.indexPathForSelectedRow,
                  let destinationVC = segue.destination as? IncomeDetailTableViewController else {return}
            guard let income = dataSource[indexPath.row] as? Income else {return}
            destinationVC.income = income
        }
    }
    
    
}


extension IncomeListTableViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if !searchText.isEmpty {
            
            resultsIncomeFromSearching = IncomeController.shared.incomes.filter {$0.matches(searchTerm: searchText, name: $0.incomeNameString, category: $0.incomeCategory?.name ?? "")}
            
            
            
            guard let results = resultsIncomeFromSearching
                    as? [Income] else {return}
            
            TotalController.shared.calculateTotalIncomeFrom(searchArrayResults: results)
            
            totalIncomeSearching = TotalController.shared.totalIncomeSearchResults
            print("\n totalIncomeSearching IN SEARCH BAR TEXTDIDCHANGE::: \(totalIncomeSearching)")
                
             
            self.tableView.reloadData()
        } else {
            resultsIncomeFromSearching = IncomeController.shared.incomes
            guard let results = resultsIncomeFromSearching as? [Income] else {return}
            TotalController.shared.calculateTotalIncomeFrom(searchArrayResults: results)
            totalIncomeSearching = TotalController.shared.totalIncomeSearchResults
            self.tableView.reloadData()
        }
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        searchBar.text = ""
        isSearching = false
   
        resultsIncomeFromSearching = IncomeController.shared.incomes
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
    
    //    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
    //        self.incomeSearchBar.endEditing(true)    }
    //
}


/* NOTE NEED Help
 
 - Keyboard need to be hide after done searching on searchbar
 
 
 
 //______________________________________________________________________________________
 */
