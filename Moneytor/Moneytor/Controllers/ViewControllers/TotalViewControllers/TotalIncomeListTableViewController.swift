//
//  TotalIncomeListTableViewController.swift
//  Moneytor
//
//  Created by Lee McCormick on 2/22/21.
//

import UIKit

class TotalIncomeListTableViewController: UITableViewController {
    
    // MARK: - Outlets
    @IBOutlet weak var salaryLabel: MoneytorGoodLetterLabel!
    @IBOutlet weak var savingLabel: MoneytorGoodLetterLabel!
    @IBOutlet weak var checkingLabel: MoneytorGoodLetterLabel!
    @IBOutlet weak var otherLabel: MoneytorGoodLetterLabel!
    @IBOutlet weak var totalIncomeLabel: MoneytorGoodLetterLabel!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    // MARK: - Properties
    
    

    // MARK: - Life Cycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()

    }

    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        //toIncomeLineChartVC
    }
 

}
