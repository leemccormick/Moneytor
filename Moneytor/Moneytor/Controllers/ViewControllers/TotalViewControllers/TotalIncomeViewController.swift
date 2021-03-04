//
//  TotalIncomeViewController.swift
//  Moneytor
//
//  Created by Lee McCormick on 3/3/21.
//

import UIKit

class TotalIncomeViewController: UIViewController {
    
    // MARK: - Outlets
    @IBOutlet weak var incomeTableView: UITableView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    // MARK: - Properties
    var incomeCategoryDict: [Dictionary<String, Double>.Element] = IncomeCategoryController.shared.incomeCategoriesTotalDict
    var totalIncomeString = TotalController.shared.totalIncomeString
    var incomeCategoriesEmoji = IncomeCategoryController.shared.incomeCategoriesEmoji
    
    // MARK: - Life Cycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        incomeTableView.delegate = self
        incomeTableView.dataSource = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        IncomeCategoryController.shared.generateSectionsAndSumEachIncomeCategory()
        incomeCategoryDict = IncomeCategoryController.shared.incomeCategoriesTotalDict
        incomeCategoriesEmoji = IncomeCategoryController.shared.incomeCategoriesEmoji
        print(incomeCategoriesEmoji)
       // incomeTableView.selectRowAtIndexPath(2, animated: true, scrollPosition: .Middle)
        
//        incomeTableView.selectionFollowsFocus
//        incomeTableView.selectRow(at: <#T##IndexPath?#>, animated: <#T##Bool#>, scrollPosition: <#T##UITableView.ScrollPosition#>)
    }
}


// MARK: - UITableViewDelegate, UITableViewDataSource
extension TotalIncomeViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return incomeCategoryDict.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "incomeCategoryCell", for: indexPath)
        
        cell.textLabel?.text = "\(incomeCategoriesEmoji[indexPath.row]) \(incomeCategoryDict[indexPath.row].key.capitalized)"
        cell.detailTextLabel?.text = AmountFormatter.currencyInString(num: incomeCategoryDict[indexPath.row].value)
        return cell
    }
    
    func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        return "TOTAL INCOMES : \(totalIncomeString)"
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return CGFloat(40.0)
    }
    
    func tableView(_ tableView: UITableView, willDisplayFooterView view: UIView, forSection section: Int) {
        view.tintColor = UIColor.mtLightYellow
        let footer = view as! UITableViewHeaderFooterView
        footer.textLabel?.textColor = UIColor.mtTextDarkBrown
        footer.textLabel?.font = UIFont(name: FontNames.textMoneytorGoodLetter, size: 25)
        footer.textLabel?.textAlignment = .center
    }
    
}
