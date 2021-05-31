//
//  IncomeListTableViewController.swift
//  Moneytor
//
//  Created by Lee on 4/2/21.
//

import UIKit
import Vision
import VisionKit

class IncomeListTableViewController: UITableViewController {
    
    // MARK: - Outlets
    @IBOutlet weak var incomeSearchBar: UISearchBar!
    
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
        didSet {
            updateFooter(total: totalIncomeSearching)
        }
    }
    let textRecognizationQueue = DispatchQueue.init(label: "TextRecognizationQueue", qos: .userInitiated, attributes: [], autoreleaseFrequency: .workItem, target: nil)
    var requests = [VNRequest]()
    
    
    // MARK: - Life Cycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        incomeSearchBar.delegate = self
        categoriesSectionsByDay = IncomeCategoryController.shared.generateSectionsCategoiesByTimePeriod(start: daily, end: Date())
        categoriesSectionsByWeek = IncomeCategoryController.shared.generateSectionsCategoiesByTimePeriod(start: Date().startOfWeek, end: Date().endOfWeek)
        categoriesSectionsByMonth = IncomeCategoryController.shared.generateSectionsCategoiesByTimePeriod(start: Date().startOfWeek, end: Date().endOfWeek)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        isSearching = false
        incomeSearchBar.setShowsCancelButton(true, animated: true)
        incomeSearchBar.selectedScopeButtonIndex = 1
        categoriesSectionsByWeek = fetchIncomesBySpecificTime(start: Date().startOfWeek, end: Date().endOfWeek)
        tableView.reloadData()
    }
    
    // MARK: - Actions
    @IBAction func incomeScannerButtonTapped(_ sender: Any) {
        scanReceiptForIncomeResult()
        ScannerController.shared.deleteNameAmountAndNote()
        self.requests = ScannerController.shared.setupVisionForIncomeScanner()
    }
    
    // MARK: - Helper Fuctions
    func scanReceiptForIncomeResult() {
        ScannerController.shared.deleteNameAmountAndNote()
        let documentCameraController = VNDocumentCameraViewController()
        documentCameraController.delegate = self
        self.present(documentCameraController, animated: true, completion: nil)
    }
    
    func fetchAllIncomes(){
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
extension IncomeListTableViewController {
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
            let searchCell = tableView.dequeueReusableCell(withIdentifier: "incomeSearchCell", for: indexPath)
            guard let income = resultsIncomeFromSearching[indexPath.row] as? Income else {return UITableViewCell()}
            searchCell.textLabel?.numberOfLines = 0
            searchCell.textLabel?.text = "\(income.incomeCategory?.emoji ?? "💵") \(income.incomeNameString.capitalized) \n\(income.incomeDateText)"
            searchCell.detailTextLabel?.text = income.incomeAmountString
            searchCell.selectionStyle = .none
            returnCell = searchCell
        } else {
            switch incomeSearchBar.selectedScopeButtonIndex {
            case 0:
                let dayCell = tableView.dequeueReusableCell(withIdentifier: "incomeDayCell", for: indexPath)
                let income = categoriesSectionsByDay[indexPath.section][indexPath.row]
                dayCell.textLabel?.numberOfLines = 0
                dayCell.textLabel?.text = "\(income.incomeCategory?.emoji ?? "💵") \(income.incomeNameString.capitalized) \n\(income.incomeDateText)"
                dayCell.detailTextLabel?.text = income.incomeAmountString
                dayCell.selectionStyle = .none
                returnCell = dayCell
            case 1:
                let weekCell = tableView.dequeueReusableCell(withIdentifier: "incomeWeekCell", for: indexPath)
                let income = categoriesSectionsByWeek[indexPath.section][indexPath.row]
                weekCell.textLabel?.numberOfLines = 0
                weekCell.textLabel?.text = "\(income.incomeCategory?.emoji ?? "💵") \(income.incomeNameString.capitalized) \n\(income.incomeDateText)"
                weekCell.detailTextLabel?.text = income.incomeAmountString
                weekCell.selectionStyle = .none
                returnCell = weekCell
            case 2:
                let monthCell = tableView.dequeueReusableCell(withIdentifier: "incomeMonthCell", for: indexPath)
                let income = categoriesSectionsByMonth[indexPath.section][indexPath.row]
                monthCell.textLabel?.numberOfLines = 0
                monthCell.textLabel?.text = "\(income.incomeCategory?.emoji ?? "💵") \(income.incomeNameString.capitalized) \n\(income.incomeDateText)"
                monthCell.detailTextLabel?.text = income.incomeAmountString
                monthCell.selectionStyle = .none
                returnCell = monthCell
            default:
                return returnCell
            }
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
                    self.fetchAllIncomes()
                }
                alertController.addAction(dismissAction)
                alertController.addAction(deleteAction)
                present(alertController, animated: true)
                
            } else {
                switch incomeSearchBar.selectedScopeButtonIndex {
                case 0:
                    let income = self.categoriesSectionsByDay[indexPath.section][indexPath.row]
                    let alertController = UIAlertController(title: "Are you sure to delete this income?", message: "Name : \(income.incomeNameString) \nAmount : \(income.incomeAmountString) \nCategory : \(income.incomeCategory!.nameString.capitalized) \nDate : \(income.incomeDateText)", preferredStyle: .actionSheet)
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
                    let alertController = UIAlertController(title: "Are you sure to delete this income?", message: "Name : \(income.incomeNameString) \nAmount : \(income.incomeAmountString) \nCategory : \(income.incomeCategory!.nameString.capitalized) \nDate : \(income.incomeDateText)", preferredStyle: .actionSheet)
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
                    let alertController = UIAlertController(title: "Are you sure to delete this income?", message: "Name : \(income.incomeNameString) \nAmount : \(income.incomeAmountString) \nCategory : \(income.incomeCategory!.nameString.capitalized) \nDate : \(income.incomeDateText)", preferredStyle: .actionSheet)
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
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if isSearching {
            return "🔍 SEARCHING INCOMES \t\t\t" + AmountFormatter.currencyInString(num: totalIncomeSearching)
        } else {
            switch incomeSearchBar.selectedScopeButtonIndex {
            case 0:
                if categoriesSectionsByDay[section].count == 0 {
                    return ""
                } else {
                    let title = configurateSectionTitle(categoriesSections: categoriesSectionsByDay, section: section)
                    return title
                }
            case 1:
                if categoriesSectionsByWeek[section].count == 0 {
                    return ""
                } else {
                    let title = configurateSectionTitle(categoriesSections: categoriesSectionsByWeek, section: section)
                    return title
                }
            case 2:
                if categoriesSectionsByMonth[section].count == 0 {
                    return ""
                } else {
                    let title = configurateSectionTitle(categoriesSections: categoriesSectionsByMonth, section: section)
                    return title
                }
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
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier ==  "toIncomeDetailVCFromSearching" {
            guard let indexPath = tableView.indexPathForSelectedRow,
                  let destinationVC = segue.destination as? IncomeDetailTableViewController else {return}
            print("Row #: \(indexPath) \(#function)")
            if isSearching {
                guard let income = resultsIncomeFromSearching[indexPath.row] as? Income else {return}
                destinationVC.income = income
            }
        }
        
        if segue.identifier ==  "toIncomeDetailVCFromDay" {
            guard let indexPath = tableView.indexPathForSelectedRow,
                  let destinationVC = segue.destination as? IncomeDetailTableViewController else {return}
            let income = categoriesSectionsByDay[indexPath.section][indexPath.row]
            destinationVC.income = income
        }
        
        if segue.identifier ==  "toIncomeDetailVCFromWeek" {
            guard let indexPath = tableView.indexPathForSelectedRow,
                  let destinationVC = segue.destination as? IncomeDetailTableViewController else {return}
            let income = categoriesSectionsByWeek[indexPath.section][indexPath.row]
            destinationVC.income = income
        }
        
        if segue.identifier ==  "toIncomeDetailVCFromMonth" {
            guard let indexPath = tableView.indexPathForSelectedRow,
                  let destinationVC = segue.destination as? IncomeDetailTableViewController else {return}
            let income = categoriesSectionsByMonth[indexPath.section][indexPath.row]
            destinationVC.income = income
        }
    }
}

// MARK: - UISearchBarDelegate
extension IncomeListTableViewController: UISearchBarDelegate {
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if !searchText.isEmpty {
            fetchAllIncomes()
            resultsIncomeFromSearching = IncomeController.shared.incomes.filter{$0.matches(searchTerm: searchText, name: $0.incomeNameString, category: $0.incomeCategory?.name ?? "", date: $0.incomeDateText, amount: $0.incomeAmountString, note: $0.incomeNoteString)}
            
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

// MARK: - VNDocumentCameraViewControllerDelegate
extension IncomeListTableViewController: VNDocumentCameraViewControllerDelegate {
    func documentCameraViewController(_ controller: VNDocumentCameraViewController, didFinishWith scan: VNDocumentCameraScan) {
        controller.dismiss(animated: true, completion: nil)
        for i in 0..<scan.pageCount {
            let scannedImage = scan.imageOfPage(at: i)
            ScannerController.shared.imageScanner = scannedImage
            if let cgImage = scannedImage.cgImage {
                let requestHandler = VNImageRequestHandler.init(cgImage: cgImage, options: [:])
                do {
                    try requestHandler.perform(self.requests)
                } catch {
                    print(error.localizedDescription)
                }
            }
        }
        gotoIncomeDetailVC()
    }
    
    func documentCameraViewControllerDidCancel(_ controller: VNDocumentCameraViewController) {
        controller.dismiss(animated: true, completion: nil)
        presentAlertToUser(titleAlert: "CANCELED!", messageAlert: "Expense receipt scanner have been cancled!")
    }
    
    func documentCameraViewController(_ controller: VNDocumentCameraViewController, didFailWithError error: Error) {
        controller.dismiss(animated: true, completion: nil)
        print("\n==== ERROR SCANNING RECEIPE IN \(#function) : \(error.localizedDescription) : \(error) ====\n")
        presentAlertToUser(titleAlert: "ERROR! SCANNING RECEIPT!", messageAlert: "Please, make sure if you are using camera propertly to scan receipt!")
    }
    
    func gotoIncomeDetailVC() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        guard let  destinationVc = storyboard.instantiateViewController(identifier: "incomeDetailStoryBoardId") as? IncomeDetailTableViewController else {
            print("Couldn't find the view controller")
            return}
        navigationController?.pushViewController(destinationVc, animated: true)
    }
}






