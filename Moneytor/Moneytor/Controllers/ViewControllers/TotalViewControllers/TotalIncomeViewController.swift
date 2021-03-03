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
    
    // MARK: - Life Cycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        incomeTableView.delegate = self
        incomeTableView.dataSource = self
    }
}

// MARK: - UITableViewDelegate, UITableViewDataSource
extension TotalIncomeViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "incomeCategoryCell", for: indexPath)
        return cell
    }
}
