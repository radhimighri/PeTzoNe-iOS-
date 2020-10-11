//
//  SignInViewController.swift
//  PeTzoNe
//
//  Created by Radhi Mighri on 10/08/2020.
//  Copyright © 2020 Radhi Mighri. All rights reserved.
//

import UIKit
import ProgressHUD

class SignInViewController: UIViewController {
    
    @IBOutlet weak var titleTextLabel: UILabel!
    @IBOutlet weak var emailContainerView: UIView!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordContainerView: UIView!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var signInButton: UIButton!
    @IBOutlet weak var signUpButton: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    func setupUI(){
        
        setupTitleLabel()
        setupEmailTextField()
        setupPasswordTextField()
        setupSignInButton()
        setupSignUpButton()
    }
    
    @IBAction func dismissAction(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
    
    
    @IBAction func signInButtonDidTapped(_ sender: UIButton) {
        self.view.endEditing(true)
        self.validateFieldsSignIn()
        self.signIn(onSuccess: {
            Api.User.isOnline(bool: true)
            // switch view
            //        (UIApplication.shared.delegate as! AppDelegate).configureInitialViewController()
            //            (UIScene. as! SceneDelegate).configureInitialViewController()
            let scene = UIApplication.shared.connectedScenes.first
            if let sd : SceneDelegate = (scene?.delegate as? SceneDelegate) {
                sd.configureInitialViewController()
            }
        }) { (errorMessage) in
            ProgressHUD.showError(errorMessage)
        }
    }
    
}
