//
//  TotalExpenseListTableViewController.swift
//  Moneytor
//
//  Created by Lee McCormick on 2/22/21.
//

import UIKit

class TotalExpenseListTableViewController: UITableViewController {
    
    // MARK: - Outlets
    @IBOutlet weak var foodLabel: MoneytorGoodLetterLabel!
    @IBOutlet weak var utilityLabel: MoneytorGoodLetterLabel!
    @IBOutlet weak var healthLabel: MoneytorGoodLetterLabel!
    @IBOutlet weak var groceryLabel: MoneytorGoodLetterLabel!
    @IBOutlet weak var shoppingLabel: MoneytorGoodLetterLabel!
    @IBOutlet weak var entertainmentLabel: MoneytorGoodLetterLabel!
    @IBOutlet weak var transportationLabel: MoneytorGoodLetterLabel!
    @IBOutlet weak var otherLabel: MoneytorGoodLetterLabel!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    // MARK: - Properties
    
    
    
    
    // MARK: - Life Cycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        //toExpenseBarChartVC
    }
    
    
}
