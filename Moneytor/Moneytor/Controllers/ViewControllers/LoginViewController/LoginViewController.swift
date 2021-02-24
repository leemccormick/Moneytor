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
    
    // MARK: - Life Cycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        let tap = UITapGestureRecognizer(target: self.view, action: #selector(UIView.endEditing))
        view.addGestureRecognizer(tap)
        fetchUser()
        setupViwes()
        startTimerForEachLogo()
    }
    
    // MARK: - Actions
    @IBAction func loginButtonTapped(_ sender: Any) {
        isNewUser = false
        // for animation
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
              let confirmPassword = confirmPasswordTextFiled.text, !confirmPassword.isEmpty else {return}
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
        // Make it the container to circle by this 2 lines of code.
//        photoContainerView.layer.cornerRadius = photoContainerView.frame.height / 2
//        photoContainerView.clipsToBounds = true
//        self.view.backgroundColor = UIColor.spaceGrey
        loginButton.setTitleColor(.mtTextLightBrown, for: .normal)
      signUpButton.setTitleColor(.mtTextDarkBrown, for: .normal)
        signUpButton.titleLabel?.font = UIFont(name: FontNames.textMoneytorMoneyFont, size: 35)
        loginButton.titleLabel?.font = UIFont(name: FontNames.textMoneytorMoneyFont, size: 35)
        signMeUpButton.setTitleColor(.mtWhiteText, for: .normal)
               // signMeUpButton.addCornerRadius() //from extension UIView
                signMeUpButton.titleLabel?.font = UIFont(name: FontNames.textTitleBoldMoneytor, size: 20)
       signMeUpButton.rotate()
        signMeUpStackView.addCornerRadius()
        signMeUpStackView.layer.borderWidth = 2.5
        signMeUpStackView.layer.borderColor = UIColor.mtLightYellow.cgColor
        //signUpButton.rotate()
     
        
      
        
//        UIView.animate(withDuration: 1, delay: 5, options: .curveEaseInOut) {
//            self.firstLogoImage.animationDuration = 2
//            self.secondLogoImage.isHidden = true
//            //self.secondLogoImage.isHidden = true
//        }
//
//        UIView.animate(withDuration: 1, delay: 5, options: .curveEaseInOut) {
//            self.firstLogoImage.isHidden = true
//            self.secondLogoImage.isHidden = false
//            self.thirdLogoImage.isHidden = true
//        }
//
//        UIView.animate(withDuration: 1, delay: 5, options: .curveEaseInOut) {
//            self.firstLogoImage.isHidden = true
//            self.secondLogoImage.isHidden = true
//            self.thirdLogoImage.isHidden = false
//        }
//
        
        

    }
    
    
    func startTimerForEachLogo() {
        var countdownTimerForLetter: Timer!
          countdownTimerForLetter = Timer(timeInterval: 2, repeats: true, block: { (timer) in
             // timer.invalidate()
//              //show the first
            print("Show")
          
            
            self.hideThirdLogo()
            
            self.hideSecondLogo()
            self.hideFirstLogo()
    DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                         
                     }
          DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                         
                     }
          DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                       
                     }
//            self.hideFirstLogo()
//            self.hideSecondLogo()
           // self.hideThirdLogo()
            // show the second
            // show the thired
          })
          RunLoop.current.add(countdownTimerForLetter, forMode: .common)
      }
//
    func hideFirstLogo() {
        firstLogoImage.isHidden = false
        secondLogoImage.isHidden = true
        thirdLogoImage.isHidden = true
    }
//
    func hideSecondLogo() {
        firstLogoImage.isHidden = false
        secondLogoImage.isHidden = false
        thirdLogoImage.isHidden = true
    }
//
//
    func hideThirdLogo() {
        firstLogoImage.isHidden = false
        secondLogoImage.isHidden = false
        thirdLogoImage.isHidden = false
    }
//
    func presentMoneytorVC() {
        DispatchQueue.main.async {
            // GO TO CityDataViewController By CODING STORYBOARD.ID
            let storyboard = UIStoryboard(name: "Main", bundle: nil) // HAVE TO MATCH The NAME of Storyboard, this case Main.storyboard. Mostly! Strict with main.
            let moneytorVC = storyboard.instantiateViewController(identifier: "MoneytorStoryboardID") //HAVE TO match the Storyboard ID in storyboard
            // The style of presenting
            moneytorVC.modalPresentationStyle = .formSheet //You can choose the style of presenting
            
            // Now Presenting the next VC
            self.present(moneytorVC, animated: true, completion: nil)
        }
    }
    
   
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    //toTabBarMoneytorController
    }
    
  
}
