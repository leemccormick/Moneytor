//
//  IncomeStatementDetailsTableViewController.swift
//  Moneytor
//
//  Created by Lee on 8/9/21.
//

import UIKit

class IncomeStatementDetailsTableViewController: UITableViewController {

    @IBOutlet weak var incomeSearchBar: MoneytorSearchBar!
    // MARK: - Properties
//    let daily = IncomeCategoryController.shared.daily
//    let weekly = IncomeCategoryController.shared.weekly
//    let monthly = IncomeCategoryController.shared.monthly
    var isSearching: Bool = false
    var resultsIncomeFromSearching: [SearchableRecordDelegate] = []
//    var categoriesSectionsByDay: [[Income]] = []
//    var categoriesSectionsByWeek: [[Income]] = []
    var categoriesSections: [[Income]] = []
    var startDateIncomeStatement: Date?
    var endDateIncomeStatement: Date?
//    var totalIncomeSearching: Double = 0.0 {
//        didSet {
//            updateFooter(total: totalIncomeSearching)
//        }
////    }
//    let textRecognizationQueue = DispatchQueue.init(label: "TextRecognizationQueue", qos: .userInitiated, attributes: [], autoreleaseFrequency: .workItem, target: nil)
//    var requests = [VNRequest]()
//
    // MARK: - Life Cycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        incomeSearchBar.delegate = self
//        categoriesSectionsByDay = IncomeCategoryController.shared.generateSectionsCategoiesByTimePeriod(start: daily, end: Date())
//        categoriesSectionsByWeek = IncomeCategoryController.shared.generateSectionsCategoiesByTimePeriod(start: Date().startOfWeek, end: Date().endOfWeek)
        
//        categoriesSections = IncomeCategoryController.shared.generateSectionsCategoiesByTimePeriod(start: startDateIncomeStatement, end: endDateIncomeStatement)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        guard let startDateIncome = startDateIncomeStatement,
              let endDateIncome = endDateIncomeStatement else {return}
        categoriesSections = IncomeCategoryController.shared.generateSectionsCategoiesByTimePeriod(start: startDateIncome, end: endDateIncome)
        tableView.reloadData()
    }
    
    // MARK: - Actions
//    @IBAction func incomeScannerButtonTapped(_ sender: Any) {
//        scanReceiptForIncomeResult()
//        ScannerController.shared.deleteNameAmountAndNote()
//        self.requests = ScannerController.shared.setupVisionForIncomeScanner()
//    }
//
    // MARK: - Helper Fuctions
//    func scanReceiptForIncomeResult() {
//        ScannerController.shared.deleteNameAmountAndNote()
//        let documentCameraController = VNDocumentCameraViewController()
//        documentCameraController.delegate = self
//        self.present(documentCameraController, animated: true, completion: nil)
//    }
//
//    func fetchAllIncomes(){
//        IncomeController.shared.fetchAllIncomes()
//        resultsIncomeFromSearching = IncomeController.shared.incomes
//        updateFooter(total: TotalController.shared.totalIncomeSearchResults)
//        tableView.reloadData()
//    }
    
    func fetchIncomesBySpecificTime(start: Date, end: Date) -> [[Income]] {
        let newCategoriesSections = IncomeCategoryController.shared.generateSectionsCategoiesByTimePeriod(start: start, end: end)
        TotalController.shared.calculateTotalIncomesBySpecificTime(startedTime: start, endedTime: end)
        updateFooter(total: TotalController.shared.totalIncomeBySpecificTime)
        tableView.reloadData()
        return newCategoriesSections
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
    
    func configurateSectionTitle(categoriesSections: [[Income]], section: Int) -> String {
        var total = 0.0
        var name = ""
        var totalIncomeInEachSections: [Double] = []
        var sectionNames: [String] = []
        for section in categoriesSections {
            total = 0.0
            for income in section {
                total += income.incomeAmountInDouble
                name = income.incomeCategory?.nameString ?? ""
            }
            totalIncomeInEachSections.append(total)
            sectionNames.append(name)
        }
        let categoryName = sectionNames[section]
        let categoryTotal = totalIncomeInEachSections[section]
        let categoryTotalString = AmountFormatter.currencyInString(num: categoryTotal)
        return "\(categoryName.uppercased()) \(categoryTotalString)"
    }
}

// MARK: - Table view data source
extension IncomeStatementDetailsTableViewController {
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
        var returnCell = UITableViewCell()
        if isSearching {
            let searchCell = tableView.dequeueReusableCell(withIdentifier: "incomeSearchCell", for: indexPath)
            guard let income = resultsIncomeFromSearching[indexPath.row] as? Income else {return UITableViewCell()}
            searchCell.textLabel?.numberOfLines = 0
            searchCell.textLabel?.text = "\(income.incomeCategory?.emoji ?? "💵") \(income.incomeNameString.capitalized) \n\(income.incomeDateText)"
            searchCell.detailTextLabel?.text = income.incomeAmountString
            searchCell.selectionStyle = .none
            returnCell = searchCell
        } else {
                let statementCell = tableView.dequeueReusableCell(withIdentifier: "incomeStementCell", for: indexPath)
                let income = categoriesSections[indexPath.section][indexPath.row]
            statementCell.textLabel?.numberOfLines = 0
            statementCell.textLabel?.text = "\(income.incomeCategory?.emoji ?? "💵") \(income.incomeNameString.capitalized) \n\(income.incomeDateText)"
            statementCell.detailTextLabel?.text = income.incomeAmountString
            statementCell.selectionStyle = .none
                returnCell = statementCell
        }
        return returnCell
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            if isSearching == true {
                guard let income = self.resultsIncomeFromSearching[indexPath.row] as? Income else {return}
                let alertController = UIAlertController(title: "Are you sure to delete this income?", message: "Name : \(income.incomeNameString) \nAmount : \(income.incomeAmountString) \nCategory : \(income.incomeCategory!.nameString.capitalized) \nDate : \(income.incomeDateText)", preferredStyle: .actionSheet)
                let dismissAction = UIAlertAction(title: "Cancel", style: .cancel)
                let deleteAction = UIAlertAction(title: "Delete", style: .destructive) { (_) in
                    IncomeController.shared.deleteIncome(income)
              //      self.fetchAllIncomes()
                }
                alertController.addAction(dismissAction)
                alertController.addAction(deleteAction)
                present(alertController, animated: true)
                
            } else {
            
                    let income = self.categoriesSections[indexPath.section][indexPath.row]
                    let alertController = UIAlertController(title: "Are you sure to delete this income?", message: "Name : \(income.incomeNameString) \nAmount : \(income.incomeAmountString) \nCategory : \(income.incomeCategory!.nameString.capitalized) \nDate : \(income.incomeDateText)", preferredStyle: .actionSheet)
                    let dismissAction = UIAlertAction(title: "Cancel", style: .cancel)
                    let deleteAction = UIAlertAction(title: "Delete", style: .destructive) { (_) in
                        IncomeController.shared.deleteIncome(income)
                        self.categoriesSections[indexPath.section].remove(at: indexPath.row)
                        tableView.deleteRows(at: [indexPath], with: .fade)
                        tableView.reloadData()
                        guard let startDate = self.startDateIncomeStatement,
                              let endDate = self.endDateIncomeStatement else {return}
                        self.categoriesSections = self.fetchIncomesBySpecificTime(start: startDate, end: endDate)
                    }
                    alertController.addAction(dismissAction)
                    alertController.addAction(deleteAction)
                    present(alertController, animated: true)
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if isSearching {
            return "🔍 SEARCHING INCOMES \t\t\t" + AmountFormatter.currencyInString(num: totalIncomeSearching)
        } else {
                if categoriesSections[section].count == 0 {
                    return ""
                } else {
                    let title = configurateSectionTitle(categoriesSections: categoriesSections, section: section)
                    return title
                }
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
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        if segue.identifier ==  "toIncomeDetailVCFromSearching" {
//            guard let indexPath = tableView.indexPathForSelectedRow,
//                  let destinationVC = segue.destination as? IncomeDetailTableViewController else {return}
//            print("Row #: \(indexPath) \(#function)")
//            if isSearching {
//                guard let income = resultsIncomeFromSearching[indexPath.row] as? Income else {return}
//                destinationVC.income = income
//            }
//        }
//
//
//        if segue.identifier ==  "toIncomeDetailVCFromMonth" {
//            guard let indexPath = tableView.indexPathForSelectedRow,
//                  let destinationVC = segue.destination as? IncomeDetailTableViewController else {return}
//            let income = categoriesSections[indexPath.section][indexPath.row]
//            destinationVC.income = income
//        }
    }
}

// MARK: - UISearchBarDelegate
extension IncomeStatementDetailsTableViewController: UISearchBarDelegate {
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if !searchText.isEmpty {
            fetchAllIncomes()
            for incomes in IncomeCategoryController.shared.incomeCategoriesSections {
            resultsIncomeFromSearching = incomes.filter{$0.matches(searchTerm: searchText, name: $0.incomeNameString, category: $0.incomeCategory?.name ?? "", date: $0.incomeDateText, amount: $0.incomeAmountString, note: $0.incomeNoteString)}
            }
            guard let results = resultsIncomeFromSearching as? [Income] else {return}
            if !results.isEmpty {
                TotalController.shared.calculateTotalIncomeFrom(searchArrayResults:  results)
                totalIncomeSearching = TotalController.shared.totalIncomeSearchResults
                self.tableView.reloadData()
            } else {
                totalIncomeSearching = 0.0
                self.tableView.reloadData()
            }
            self.tableView.reloadData()
        } else if searchText == "" {
            resultsIncomeFromSearching = []
            totalIncomeSearching = 0.0
            self.tableView.reloadData()
        }
    }
    
    func searchBar(_ searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
        switch incomeSearchBar.selectedScopeButtonIndex {
        case 0:
            categoriesSectionsByDay = fetchIncomesBySpecificTime(start: daily, end: Date())
            print("\n===================ERROR! categoriesSectionsByDay :: \(categoriesSectionsByDay.count) IN\(#function) ======================\n")
            tableView.reloadData()
        case 1:
            categoriesSectionsByWeek = fetchIncomesBySpecificTime(start: Date().startOfWeek, end: Date().endOfWeek)
            tableView.reloadData()
        case 2:
            categoriesSectionsByMonth = fetchIncomesBySpecificTime(start: Date().startDateOfMonth, end: Date().endDateOfMonth)
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





