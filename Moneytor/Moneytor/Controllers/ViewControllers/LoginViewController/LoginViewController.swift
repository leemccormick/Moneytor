//
//  LoginViewController.swift
//  Moneytor
//
//  Created by Lee McCormick on 2/22/21.
//

import UIKit

class LoginViewController: UIViewController {

    // MARK: - Outlets
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var signUpButton: UIButton!
    @IBOutlet weak var firstNameTextField:  MoneytorTextField!
    @IBOutlet weak var lastNameTextField:  MoneytorTextField!
    @IBOutlet weak var usernameTextField:  MoneytorTextField!
    @IBOutlet weak var passwordTextFileld: MoneytorTextField!
    @IBOutlet weak var confirmPasswordTextFiled: MoneytorTextField!
    @IBOutlet weak var logoStackView: UIStackView!
    @IBOutlet weak var firstLogoImage: UIImageView!
    @IBOutlet weak var secondLogoImage: UIImageView!
    @IBOutlet weak var thirdLogoImage: UIImageView!
    @IBOutlet weak var signMeUpButton: MoneytorButton!
    @IBOutlet weak var activityView: UIView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    
    // MARK: - Life Cycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        let tap = UITapGestureRecognizer(target: self.view, action: #selector(UIView.endEditing))
        view.addGestureRecognizer(tap)
    }
    
    // MARK: - Actions
    @IBAction func loginButtonTapped(_ sender: Any) {
        
    }
    
    @IBAction func signUpButtonTapped(_ sender: Any) {
        
    }
    
    @IBAction func signMeUpButtonTapped(_ sender: Any) {
        
    }

    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    //toTabBarMoneytorController
    }
}
