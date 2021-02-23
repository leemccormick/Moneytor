//
//  TotalBalanceViewController.swift
//  Moneytor
//
//  Created by Lee McCormick on 2/22/21.
//

import UIKit

class TotalBalanceViewController: UIViewController {

    // MARK: - Outlets
    @IBOutlet weak var pieChartView: UIView!
    @IBOutlet weak var totalBalanceLabel: UILabel!
    @IBOutlet weak var totalIncomeButton: UIButton!
    @IBOutlet weak var totalExpenseButton: UIButton!
    @IBOutlet weak var activityView: UIView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    
    // MARK: - Properties
    
    
    
    // MARK: - Life Cycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    // MARK: - Actions
    @IBAction func totalIncomeButtonTapped(_ sender: Any) {
    }
    
    
    @IBAction func totalExpenseButtonTapped(_ sender: Any) {
    }
    


}
