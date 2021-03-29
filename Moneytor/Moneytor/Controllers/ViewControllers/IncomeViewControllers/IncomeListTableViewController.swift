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
    var sectionsIncomeDict = [Dictionary<String, Double>.Element]()
    var categoriesSections: [[Income]] =  IncomeCategoryController.shared.generateSectionsCategoiesByTimePeriod(start: Date().startOfWeek, end: Date().endOfWeek)
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
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        incomeSearchBar.selectedScopeButtonIndex = 1
        fetchIncomesBySpecificTime(start: Date().startOfWeek, end: Date().endOfWeek)
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
    
    func fetchIncomesBySpecificTime(start: Date, end: Date) {
        categoriesSections = IncomeCategoryController.shared.generateSectionsCategoiesByTimePeriod(start: start, end: end)
        TotalController.shared.calculateTotalIncomesBySpecificTime(startedTime: start, endedTime: end)
        updateFooter(total: TotalController.shared.totalIncomeBySpecificTime)
        sectionsIncomeDict = IncomeCategoryController.shared.generateCategoryDictionaryByIncomesAndReturnDict(sections: categoriesSections)
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
            cell.textLabel?.numberOfLines = 0
            cell.textLabel?.text = "\(income.incomeCategory?.emoji ?? "💵") \(income.incomeNameString.capitalized) \n\(income.incomeDateText)"
            cell.detailTextLabel?.text = income.incomeAmountString
        } else {
            if !categoriesSections[indexPath.section].isEmpty {
                
                let income = categoriesSections[indexPath.section][indexPath.row]
                cell.textLabel?.numberOfLines = 0
                cell.textLabel?.text = "\(income.incomeCategory?.emoji ?? "💵") \(income.incomeNameString.capitalized) \n\(income.incomeDateText)"
                cell.detailTextLabel?.text = income.incomeAmountString
            }
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            
            if isSearching {
                guard let income = self.resultsIncomeFromSearching[indexPath.row] as? Income else {return}
                let alertController = UIAlertController(title: "Are you sure to delete this Income?", message: "Name : \(income.incomeNameString) \nAmount : \(income.incomeAmountString) \nCategory : \(income.incomeCategory!.nameString.capitalized) \nDate : \(income.incomeDateText)", preferredStyle: .actionSheet)
                let dismissAction = UIAlertAction(title: "Cancel", style: .cancel)
                let deleteAction = UIAlertAction(title: "Delete", style: .destructive) { (_) in
                    IncomeController.shared.deleteIncome(income)
                    self.fetchAllIncomes()
                }
                alertController.addAction(dismissAction)
                alertController.addAction(deleteAction)
                present(alertController, animated: true)
                
            } else {
                let income = self.categoriesSections[indexPath.section][indexPath.row]
                let alertController = UIAlertController(title: "Are you sure to delete this Income?", message: "Name : \(income.incomeNameString) \nAmount : \(income.incomeAmountString) \nCategory : \(income.incomeCategory!.nameString.capitalized) \nDate : \(income.incomeDateText)", preferredStyle: .actionSheet)
                let dismissAction = UIAlertAction(title: "Cancel", style: .cancel)
                let deleteAction = UIAlertAction(title: "Delete", style: .destructive) { (_) in
                    IncomeController.shared.deleteIncome(income)
                    
                    if self.incomeSearchBar.selectedScopeButtonIndex == 0 {
                        self.fetchIncomesBySpecificTime(start: self.daily, end: Date())
                    } else if self.incomeSearchBar.selectedScopeButtonIndex == 2 {
                        self.fetchIncomesBySpecificTime(start: Date().startDateOfMonth, end: Date().endDateOfMonth)
                    } else  {
                        self.fetchIncomesBySpecificTime(start: Date().startOfWeek, end: Date().endOfWeek)
                    }
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
            return "🔍 SEARCHING INCOMES \t\t\t" + AmountFormatter.currencyInString(num: totalIncomeSearching)
        } else {
            if tableView.numberOfRows(inSection: section) == 0 {
                return nil
            } else {
                
                if self.incomeSearchBar.selectedScopeButtonIndex == 0 {
                    self.fetchIncomesBySpecificTime(start: self.daily, end: Date())
                    var total = 0.0
                    var name = ""
                    var totalIncomeInEachSections: [Double] = []
                    var sectionNames: [String] = []
                    for section in categoriesSections {
                        total = 0.0
                        for income in section {
                            total += income.amount as! Double
                            name = income.incomeCategory?.nameString ?? ""
                        }
                        totalIncomeInEachSections.append(total)
                        sectionNames.append(name)
                    }
                    
                    let categoryName = sectionNames[section]
                    let categoryTotal = totalIncomeInEachSections[section]
                    let categoryTotalString = AmountFormatter.currencyInString(num: categoryTotal)
                    return "\(categoryName.uppercased()) \(categoryTotalString)"
                } else if self.incomeSearchBar.selectedScopeButtonIndex == 2 {
                    self.fetchIncomesBySpecificTime(start: Date().startDateOfMonth, end: Date().endDateOfMonth)
                    var total = 0.0
                    var name = ""
                    var totalIncomeInEachSections: [Double] = []
                    var sectionNames: [String] = []
                    for section in categoriesSections {
                        total = 0.0
                        for income in section {
                            total += income.amount as! Double
                            name = income.incomeCategory?.nameString ?? ""
                        }
                        totalIncomeInEachSections.append(total)
                        sectionNames.append(name)
                    }
                    
                    let categoryName = sectionNames[section]
                    let categoryTotal = totalIncomeInEachSections[section]
                    let categoryTotalString = AmountFormatter.currencyInString(num: categoryTotal)
                    return "\(categoryName.uppercased()) \(categoryTotalString)"
                } else {
                    self.fetchIncomesBySpecificTime(start: Date().startOfWeek, end: Date().endOfWeek)
                    var total = 0.0
                    var name = ""
                    var totalIncomeInEachSections: [Double] = []
                    var sectionNames: [String] = []
                    for section in categoriesSections {
                        total = 0.0
                        for income in section {
                            total += income.amount as! Double
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
                let income = self.categoriesSections[indexPath.section][indexPath.row]
                destinationVC.income = income
                
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
        if selectedScope == 0 {
            categoriesSections = IncomeCategoryController.shared.generateSectionsCategoiesByTimePeriod(start: self.daily, end: Date())
            self.fetchIncomesBySpecificTime(start: self.daily, end: Date())
        } else if selectedScope == 2 {
            categoriesSections = IncomeCategoryController.shared.generateSectionsCategoiesByTimePeriod(start: Date().startDateOfMonth, end: Date().endDateOfMonth)
            self.fetchIncomesBySpecificTime(start: Date().startDateOfMonth, end: Date().endDateOfMonth)
        } else {
            categoriesSections =  IncomeCategoryController.shared.generateSectionsCategoiesByTimePeriod(start: Date().startOfWeek, end: Date().endOfWeek)
            self.fetchIncomesBySpecificTime(start: Date().startOfWeek, end: Date().endOfWeek)
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
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let incomeDetailVC = storyboard.instantiateViewController(identifier: "incomeStoryBoardId")
        incomeDetailVC.modalPresentationStyle = .pageSheet
        self.present(incomeDetailVC, animated: true, completion: nil)
        
        
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
}


/* NOTE NEED Help
 
 - Keyboard need to be hide after done searching on searchbar
 
 
 
 //______________________________________________________________________________________
 */
