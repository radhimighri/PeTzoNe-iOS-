//
//  SignUpViewController.swift
//  PeTzoNe
//
//  Created by Radhi Mighri on 10/08/2020.
//  Copyright © 2020 Radhi Mighri. All rights reserved.
//

import UIKit
import ProgressHUD
import CoreLocation
import GeoFire


class SignUpViewController: UIViewController {
    
    @IBOutlet weak var titleTextLabel: UILabel!
    @IBOutlet weak var avatar: UIImageView!
    @IBOutlet weak var fullnameContainerView: UIView!
    @IBOutlet weak var fullnameTextField: UITextField!
    @IBOutlet weak var emailContainerView: UIView!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordContainerView: UIView!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var signUpButton: UIButton!
    @IBOutlet weak var signInButton: UIButton!
    
    var image: UIImage? = nil
    let manager = CLLocationManager()
    var userLat = ""
    var userLong = ""
    var geoFire: GeoFire!
    var geoFireRef: DatabaseReference!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureLocationManager()
        setupUI()
        
    }
    

    func setupUI(){
        
        setupTitleLabel()
        setupAvatar()
        setupFullNameTextField()
        setupEmailTextField()
        setupPasswordTextField()
        setupSignUpButton()
        setupSignInButton()
    }
    
    
    @IBAction func dismissAction(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
    
    @IBAction func signUpButtonDidTapped(_ sender: Any) {
        
        self.view.endEditing(true)
        self.validateFields()
        if let userLat = UserDefaults.standard.value(forKey: "current_location_latitude") as? String, let userLong = UserDefaults.standard.value(forKey: "current_location_longitude") as? String {
            self.userLat = userLat
            self.userLong = userLong
        }
        self.signUp(onSuccess: {
            if !self.userLat.isEmpty && !self.userLong.isEmpty {
                           let location: CLLocation = CLLocation(latitude: CLLocationDegrees(Double(self.userLat)!), longitude: CLLocationDegrees(Double(self.userLong)!))
                           self.geoFireRef = Ref().databaseGeo
                           self.geoFire = GeoFire(firebaseRef: self.geoFireRef)
                           self.geoFire.setLocation(location, forKey: Api.User.currentUserId)
                           // send location to Firebase
                       }

            Api.User.isOnline(bool: true)
            // switch view
            //        (UIApplication.shared.delegate as! AppDelegate).configureInitialViewController()
            //            (UIApplication.shared.delegate as! SceneDelegate).configureInitialViewController()
            let scene = UIApplication.shared.connectedScenes.first
            if let sd : SceneDelegate = (scene?.delegate as? SceneDelegate) {
                sd.configureInitialViewController()
            }
            
        }) { (errorMessage) in
            ProgressHUD.showError(errorMessage)
        }
        
    }
    
    
}


