//
//  CurrencyMapViewController.swift
//  Moneytor
//
//  Created by Lee McCormick on 2/22/21.
//

import UIKit
import MapKit

class CurrencyMapViewController: UIViewController {

    // MARK: - Outlets
    
    @IBOutlet weak var currencyMapView: MKMapView!
    @IBOutlet weak var activityView: UIView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let tap = UITapGestureRecognizer(target: self.view, action: #selector(UIView.endEditing))
        view.addGestureRecognizer(tap)
    }
    
    // MARK: - Actions
    @IBAction func logoutButtonTapped(_ sender: Any) {
    }
    
    

}
