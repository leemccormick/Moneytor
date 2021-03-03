//
//  TotalExpenseViewController.swift
//  Moneytor
//
//  Created by Lee McCormick on 3/3/21.
//

import UIKit

class TotalExpenseViewController: UIViewController {
    
    // MARK: - Outlets
    @IBOutlet weak var expenseTableView: UITableView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    // MARK: - Life Cycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        expenseTableView.delegate = self
        expenseTableView.dataSource = self
    }
    
}

// MARK: - UITableViewDelegate, UITableViewDataSource
extension TotalExpenseViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "expenseCategoryCell", for: indexPath)
        
        return cell
    }
}
