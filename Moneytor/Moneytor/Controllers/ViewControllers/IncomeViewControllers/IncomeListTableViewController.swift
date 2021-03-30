//
//  IncomeListTableViewController.swift
//  Moneytor
//
//  Created by Lee McCormick on 2/22/21.
//

import UIKit
import Vision
import VisionKit

class IncomeListTableViewController: UITableViewController {
    
    // MARK: - Outlets
    @IBOutlet weak var incomeSearchBar: MoneytorSearchBar!
    @IBOutlet weak var activityView: UIView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    // MARK: - Properties
    let daily = IncomeCategoryController.shared.daily
    let weekly = IncomeCategoryController.shared.weekly
    let monthly = IncomeCategoryController.shared.monthly
    var isSearching: Bool = false
    var resultsIncomeFromSearching: [SearchableRecordDelegate] = []
    var categoriesSectionsByDay: [[Income]] = []
    var categoriesSectionsByWeek: [[Income]] = []
    var categoriesSectionsByMonth: [[Income]] = []
    var totalIncomeSearching: Double = 0.0 {
        didSet{
            updateFooter(total: totalIncomeSearching)
        }
    }
    let textRecognizationQueue = DispatchQueue.init(label: "TextRecognizationQueue", qos: .userInitiated, attributes: [], autoreleaseFrequency: .workItem, target: nil)
    var requests = [VNRequest]()
    
    // MARK: - Life Cycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        incomeSearchBar.delegate = self
        categoriesSectionsByDay =  IncomeCategoryController.shared.generateSectionsCategoiesByTimePeriod(start: daily, end: Date())
        categoriesSectionsByWeek =  IncomeCategoryController.shared.generateSectionsCategoiesByTimePeriod(start: Date().startOfWeek, end: Date().endOfWeek)
        categoriesSectionsByMonth  =  IncomeCategoryController.shared.generateSectionsCategoiesByTimePeriod(start: Date().startDateOfMonth, end: Date().endDateOfMonth)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        incomeSearchBar.selectedScopeButtonIndex = 1
        categoriesSectionsByWeek = fetchIncomesBySpecificTime(start: Date().startOfWeek, end: Date().endOfWeek)
        tableView.reloadData()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        ScannerController.shared.deleteNameAmountAndNote()
        self.requests = ScannerController.shared.setupVisionForIncomeScanner()
    }
    
    // MARK: - Actions
    @IBAction func incomeAddButtonTapped(_ sender: Any) {
        isSearching = false
    }
    
    @IBAction func incomeDocumentScannerButtonTapped(_ sender: Any) {
        //  IncomeDetailTableViewController.scanReceiptForIncomeResult(IncomeDetailTableViewController)
        ScannerController.shared.deleteNameAmountAndNote()
        let documentCameraController = VNDocumentCameraViewController()
        documentCameraController.delegate = self
        self.present(documentCameraController, animated: true, completion: nil)
    }
    
    // MARK: - Helper Fuctions
    func fetchAllIncomes() {
        IncomeController.shared.fetchAllIncomes()
        resultsIncomeFromSearching = IncomeController.shared.incomes
        updateFooter(total: TotalController.shared.totalIncomeSearchResults)
        tableView.reloadData()
    }
    
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
                    
                    total += expense.incomeAmountInDouble
                    name = expense.incomeCategory?.nameString ?? ""
                    
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
            switch incomeSearchBar.selectedScopeButtonIndex {
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
            return resultsIncomeFromSearching.count
        } else {
            switch incomeSearchBar.selectedScopeButtonIndex {
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
            let searchcCell = tableView.dequeueReusableCell(withIdentifier: "incomeCell", for: indexPath)
            guard let income = resultsIncomeFromSearching[indexPath.row] as? Income else {return UITableViewCell()}
            searchcCell.textLabel?.numberOfLines = 0
            searchcCell.textLabel?.text = "\(income.incomeCategory?.emoji ?? "💵") \(income.incomeNameString.capitalized) \n\(income.incomeDateText)"
            searchcCell.detailTextLabel?.text = income.incomeAmountString
            returnCell = searchcCell
        } else {
            let scopeCell = tableView.dequeueReusableCell(withIdentifier: "  incomeNotSearchingCell", for: indexPath)
            switch incomeSearchBar.selectedScopeButtonIndex {
            case 0:
                let income = categoriesSectionsByDay[indexPath.section][indexPath.row]
                scopeCell.textLabel?.numberOfLines = 0
                scopeCell.textLabel?.text = "\(income.incomeCategory?.emoji ?? "💵") \(income.incomeNameString.capitalized) \n\(income.incomeDateText)"
                scopeCell.detailTextLabel?.text = income.incomeAmountString
                returnCell = scopeCell
            case 1:
                let income = categoriesSectionsByWeek[indexPath.section][indexPath.row]
                scopeCell.textLabel?.numberOfLines = 0
                scopeCell.textLabel?.text = "\(income.incomeCategory?.emoji ?? "💵") \(income.incomeNameString.capitalized) \n\(income.incomeDateText)"
                scopeCell.detailTextLabel?.text = income.incomeAmountString
                returnCell = scopeCell
            case 2:
                let income = categoriesSectionsByMonth[indexPath.section][indexPath.row]
                scopeCell.textLabel?.numberOfLines = 0
                scopeCell.textLabel?.text = "\(income.incomeCategory?.emoji ?? "💵") \(income.incomeNameString.capitalized) \n\(income.incomeDateText)"
                scopeCell.detailTextLabel?.text = income.incomeAmountString
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
                    guard let income = self.resultsIncomeFromSearching[indexPath.row] as? Income else {return}
                    let alertController = UIAlertController(title: "Are you sure to delete this Expense?", message: "Name : \(income.incomeNameString) \nAmount : \(income.incomeAmountString) \nCategory : \(income.incomeCategory!.nameString.capitalized) \nDate : \(income.incomeDateText)", preferredStyle: .actionSheet)
                    let dismissAction = UIAlertAction(title: "Cancel", style: .cancel)
                    let deleteAction = UIAlertAction(title: "Delete", style: .destructive) { (_) in
                        IncomeController.shared.deleteIncome(income)
                        self.fetchAllIncomes()
                    }
                    alertController.addAction(dismissAction)
                    alertController.addAction(deleteAction)
                    present(alertController, animated: true)
                    
                } else {
                    switch incomeSearchBar.selectedScopeButtonIndex {
                    case 0:
                        let income = self.categoriesSectionsByDay[indexPath.section][indexPath.row]
                        let alertController = UIAlertController(title: "Are you sure to delete this Expense?", message: "Name : \(income.incomeNameString) \nAmount : \(income.incomeAmountString) \nCategory : \(income.incomeCategory!.nameString.capitalized) \nDate : \(income.incomeDateText)", preferredStyle: .actionSheet)
                        let dismissAction = UIAlertAction(title: "Cancel", style: .cancel)
                        let deleteAction = UIAlertAction(title: "Delete", style: .destructive) { (_) in
                            IncomeController.shared.deleteIncome(income)
                            self.categoriesSectionsByDay[indexPath.section].remove(at: indexPath.row)
                            tableView.deleteRows(at: [indexPath], with: .fade)
                            tableView.reloadData()
                            self.categoriesSectionsByDay = self.fetchIncomesBySpecificTime(start: self.daily, end: Date())
                        }
                        alertController.addAction(dismissAction)
                        alertController.addAction(deleteAction)
                        present(alertController, animated: true)
                        
                    case 1:
                        let income = self.categoriesSectionsByWeek[indexPath.section][indexPath.row]
                        let alertController = UIAlertController(title: "Are you sure to delete this Expense?", message: "Name : \(income.incomeNameString) \nAmount : \(income.incomeAmountString) \nCategory : \(income.incomeCategory!.nameString.capitalized) \nDate : \(income.incomeDateText)", preferredStyle: .actionSheet)
                        let dismissAction = UIAlertAction(title: "Cancel", style: .cancel)
                        let deleteAction = UIAlertAction(title: "Delete", style: .destructive) { (_) in
                            IncomeController.shared.deleteIncome(income)
                            self.categoriesSectionsByWeek[indexPath.section].remove(at: indexPath.row)
                            tableView.deleteRows(at: [indexPath], with: .fade)
                            tableView.reloadData()
                            self.categoriesSectionsByWeek = self.fetchIncomesBySpecificTime(start: Date().startOfWeek, end: Date().endOfWeek)
                        }
                        alertController.addAction(dismissAction)
                        alertController.addAction(deleteAction)
                        present(alertController, animated: true)
                    case 2:
                        let income = self.categoriesSectionsByMonth[indexPath.section][indexPath.row]
                        let alertController = UIAlertController(title: "Are you sure to delete this Expense?", message: "Name : \(income.incomeNameString) \nAmount : \(income.incomeAmountString) \nCategory : \(income.incomeCategory!.nameString.capitalized) \nDate : \(income.incomeDateText)", preferredStyle: .actionSheet)
                        let dismissAction = UIAlertAction(title: "Cancel", style: .cancel)
                        let deleteAction = UIAlertAction(title: "Delete", style: .destructive) { (_) in
                            IncomeController.shared.deleteIncome(income)
                            self.categoriesSectionsByMonth[indexPath.section].remove(at: indexPath.row)
                            tableView.deleteRows(at: [indexPath], with: .fade)
                            tableView.reloadData()
                            self.categoriesSectionsByMonth = self.fetchIncomesBySpecificTime(start: Date().startDateOfMonth, end: Date().endDateOfMonth)
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
                switch incomeSearchBar.selectedScopeButtonIndex {
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
                return "🔍 SEARCHING INCOMES \t\t\t" + AmountFormatter.currencyInString(num: totalIncomeSearching)
            } else {
                switch incomeSearchBar.selectedScopeButtonIndex {
                case 0:
                    let title = configurateSectionTitle(categoriesSections: categoriesSectionsByDay, section: section)
                    tableView.reloadData()
                    return title
                case 1:
                    let title = configurateSectionTitle(categoriesSections: categoriesSectionsByWeek, section: section)
                    tableView.reloadData()
                    return title
                case 2:
                    let title = configurateSectionTitle(categoriesSections: categoriesSectionsByMonth, section: section)
                    tableView.reloadData()
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
            
            if segue.identifier == "toIncomeDetailVC" {
                guard let indexPath = tableView.indexPathForSelectedRow,
                      let destinationVC = segue.destination as? IncomeDetailTableViewController else {return}
                if isSearching {
                    guard let income = resultsIncomeFromSearching[indexPath.row] as? Income else {return}
                    destinationVC.income = income
                }
                    
                }
            
            
            if segue.identifier ==  "toIncomeDetailVCByScopeBar" {
                guard let indexPath = tableView.indexPathForSelectedRow,
                      let destinationVC = segue.destination as? IncomeDetailTableViewController else {return}
                print("Row #: \(indexPath) \(#function)")
                switch incomeSearchBar.selectedScopeButtonIndex {
                case 0:
                    let income = categoriesSectionsByDay[indexPath.section][indexPath.row]
                    destinationVC.income = income
                case 1:
                    let income = categoriesSectionsByWeek[indexPath.section][indexPath.row]
                    destinationVC.income = income
                case 2:
                    let income = categoriesSectionsByMonth[indexPath.section][indexPath.row]
                    destinationVC.income = income
                default:
                    print("\n===================ERROR! IN \(#function) ======================\n")
                }
            }
            
        }
        
    }
    
    // MARK: - UISearchBarDelegate
    extension IncomeListTableViewController: UISearchBarDelegate {
        
        func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
            if !searchText.isEmpty {
                fetchAllIncomes()
                resultsIncomeFromSearching = IncomeController.shared.incomes.filter {$0.matches(searchTerm: searchText, name: $0.incomeNameString, category: $0.incomeCategory?.nameString ?? "", date: $0.incomeDateText)}
                
                guard let results = resultsIncomeFromSearching
                        as? [Income] else {return}
                
                if !results.isEmpty {
                    TotalController.shared.calculateTotalIncomeFrom(searchArrayResults: results)
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
    
    
    // MARK: - VNDocumentCameraViewControllerDelegate
    extension IncomeListTableViewController: VNDocumentCameraViewControllerDelegate {
        func documentCameraViewController(_ controller: VNDocumentCameraViewController, didFinishWith scan: VNDocumentCameraScan) {
            controller.dismiss(animated: true, completion: nil)
            for i in 0..<scan.pageCount {
                let scannedImage = scan.imageOfPage(at: i)
                if let cgImage = scannedImage.cgImage {
                    let requestHandler = VNImageRequestHandler.init(cgImage: cgImage, options: [:])
                    do {
                        try requestHandler.perform(self.requests)
                    } catch {
                        print(error.localizedDescription)
                    }
                    
                }
            }
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let incomeDetailVC = storyboard.instantiateViewController(identifier: "incomeStoryBoardId")
            //incomeDetailVC.modalPresentationStyle = .pageSheet
            
            
            
            
            
            let nav = UINavigationController(rootViewController: incomeDetailVC)
            
            
            let image = UIImage(systemName: "chevron.backward")
            nav.navigationItem.leftBarButtonItem = UIBarButtonItem(image: image, style: .plain, target: self, action: "backClicked")
            
            nav.navigationItem.backBarButtonItem?.isEnabled = true
            nav.modalPresentationStyle = .fullScreen
            self.present(nav, animated: true, completion: nil)
            
            
            
        }
        
        func documentCameraViewControllerDidCancel(_ controller: VNDocumentCameraViewController) {
            controller.dismiss(animated: true, completion: nil)
            presentAlertToUser(titleAlert: "CANCELED!", messageAlert: "Income document scanner have been cancled!")
        }
        
        func documentCameraViewController(_ controller: VNDocumentCameraViewController, didFailWithError error: Error) {
            
            controller.dismiss(animated: true, completion: nil)
            print("\n==== ERROR SCANNING RECEIPE IN \(#function) : \(error.localizedDescription) : \(error) ====\n")
            presentAlertToUser(titleAlert: "ERROR! SCANNING INCOME!", messageAlert: "Please, make sure if you are using camera propertly to scan income!")
        }
        func backClicked(sender: UIBarButtonItem!) {
            dismiss(animated: true, completion: nil);
        }
    }


/* NOTE NEED Help
 
 - Keyboard need to be hide after done searching on searchbar
 
 
 
 //______________________________________________________________________________________
 */
