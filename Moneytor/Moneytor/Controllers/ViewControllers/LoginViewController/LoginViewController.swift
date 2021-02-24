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
    @IBOutlet weak var fullNameTextField:  MoneytorTextField!
    @IBOutlet weak var emailTextField:  MoneytorTextField!
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
    @IBOutlet weak var signMeUpStackView: UIStackView!
    
    // MARK: - Properties
    var isNewUser = true
    var countingTimeForAnimationLogo: Timer!
    
    // MARK: - Life Cycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        let tap = UITapGestureRecognizer(target: self.view, action: #selector(UIView.endEditing))
        view.addGestureRecognizer(tap)
        fetchUser()
        setupViwes()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        startAnimationLogo()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        print("\n\n\nviewDidDisappear")
        stopAnimationLogo()
    }
    
    // MARK: - Actions
    @IBAction func loginButtonTapped(_ sender: Any) {
        isNewUser = false
        UIView.animate(withDuration: 0.5) {
            self.loginButton.setTitleColor(.mtTextDarkBrown, for: .normal)
            self.signUpButton.setTitleColor(.mtTextLightBrown, for: .normal)
            self.fullNameTextField.isHidden = true
            self.emailTextField.isHidden = true
            self.confirmPasswordTextFiled.isHidden = true
            self.signMeUpButton.setTitle("Login!", for: .normal)
        }
    }
    
    @IBAction func signUpButtonTapped(_ sender: Any) {
        isNewUser = true
        UIView.animate(withDuration: 0.5) {
            self.loginButton.setTitleColor(.mtTextLightBrown, for: .normal)
            self.signUpButton.setTitleColor(.mtTextDarkBrown, for: .normal)
            self.confirmPasswordTextFiled.isHidden = false
            self.fullNameTextField.isHidden = false
            self.emailTextField.isHidden = false
            self.signMeUpButton.setTitle("Sign Up!", for: .normal)
        }
    }
    
    @IBAction func signMeUpButtonTapped(_ sender: Any) {
        guard let fullName = fullNameTextField.text, !fullName.isEmpty,
              let email = emailTextField.text, !email.isEmpty,
              let username = usernameTextField.text, !username.isEmpty,
              let password = passwordTextFileld.text, !password.isEmpty,
              let confirmPassword = confirmPasswordTextFiled.text, !confirmPassword.isEmpty else {return
            presentErrorToUser(titleAlert: "Sing Up Or Login!", messageAlert: "Please! Add your info in all fields!!!")
        }
        
        if password == confirmPassword {
        
        UserController.shared.createUserWith(fullName, username: username, email: email, password: password) { (result) in
            switch result {
            case .success(let user):
                guard let user = user else {return}
                UserController.shared.currentUser = user
                //Present Tabar
                self.presentMoneytorVC()
                
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
        } else {
            presentErrorToUser(titleAlert: "Password Not Match!", messageAlert: "Please! Make sure your password and confirm password are matched.")
        }
    }
    
    // MARK: - Helper Fuctions
    func fetchUser() {
        UserController.shared.fetchUser(completion:  {(result) in
            switch result {
            case .success(let user):
                UserController.shared.currentUser = user
                self.presentMoneytorVC()
            case .failure(let error):
                print(error.localizedDescription)
            }
        })
    }
    
    func setupViwes() {
        loginButton.setTitleColor(.mtTextLightBrown, for: .normal)
        signUpButton.setTitleColor(.mtTextDarkBrown, for: .normal)
        signUpButton.titleLabel?.font = UIFont(name: FontNames.textMoneytorMoneyFont, size: 35)
        loginButton.titleLabel?.font = UIFont(name: FontNames.textMoneytorMoneyFont, size: 35)
        signMeUpButton.setTitleColor(.mtWhiteText, for: .normal)
        signMeUpButton.titleLabel?.font = UIFont(name: FontNames.textTitleBoldMoneytor, size: 18)
        signMeUpButton.rotate()
        signMeUpStackView.addCornerRadius()
        signMeUpStackView.layer.borderWidth = 2.5
        signMeUpStackView.layer.borderColor = UIColor.mtLightYellow.cgColor
    }
    
    func presentMoneytorVC() {
        DispatchQueue.main.async {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let moneytorVC = storyboard.instantiateViewController(identifier: "MoneytorStoryboardID")
            moneytorVC.modalPresentationStyle = .formSheet //You can choose the style of presenting
            self.present(moneytorVC, animated: true, completion: nil)
        }
    }
    
    // MARK: - Navigation
//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        //toTabBarMoneytorController
//    }
    
    
}

// MARK: - Logo Animation
  
extension LoginViewController {
    
    func startAnimationLogo() {
        countingTimeForAnimationLogo = Timer(timeInterval: 2, repeats: true, block: { (timer) in
            print("Show startTim")
            self.hideFirstLogo()
            DispatchQueue.main.asyncAfter(deadline: .now() + 4) {
                print("Second 5 second")
                self.hideSecondLogo()
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 6) {
                print("third3 second")
                self.hideThirdLogo()
            }
        })
        RunLoop.current.add(countingTimeForAnimationLogo, forMode: .common)
    }
    
    func stopAnimationLogo(){
        countingTimeForAnimationLogo = Timer(timeInterval: 2, repeats: true, block: { (timer) in
            print("Stopping plzzz")
            timer.invalidate()
        })
        print("Stopping plzzz  countingTimeForAnimationLogo.invalidate() ")
        countingTimeForAnimationLogo.invalidate()
    }

    func hideFirstLogo() {
        firstLogoImage.isHidden = false
        secondLogoImage.isHidden = true
        thirdLogoImage.isHidden = true
    }

    func hideSecondLogo() {
        firstLogoImage.isHidden = false
        secondLogoImage.isHidden = false
        thirdLogoImage.isHidden = true
    }
 
    func hideThirdLogo() {
        firstLogoImage.isHidden = false
        secondLogoImage.isHidden = false
        thirdLogoImage.isHidden = false
    }
}
