//
//  Card.swift
//  PeTzoNe
//
//  Created by Radhi Mighri on 18/08/2020.
//  Copyright © 2020 Radhi Mighri. All rights reserved.
//

import UIKit
import CoreLocation

class Card: UIView {

    @IBOutlet weak var photo: UIImageView!
    @IBOutlet weak var locationLbl: UILabel!
    @IBOutlet weak var usernameLbl: UILabel!
    @IBOutlet weak var infoButton: UIButton!
    @IBOutlet weak var likeView: UIView!
    @IBOutlet weak var likeLbl: UILabel!
    @IBOutlet weak var nopeView: UIView!
    @IBOutlet weak var nopeLbl: UILabel!
    var controller: RadarViewController!

    var user: User! {
             didSet {
            photo.loadImage(user.profileImageUrl) { (image) in
                self.user.profileImage = image
            }
            
            let attributedUsernameText = NSMutableAttributedString(string: "\(user.username)  ", attributes: [NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize: 30),
                                                                                                              NSAttributedString.Key.foregroundColor : UIColor.white                                                                     ])
            var age = ""
            if let ageValue = user.age {
                age = String(ageValue)
            }
            let attributedAgeText = NSMutableAttributedString(string: age, attributes: [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 22),
                                                                                                   NSAttributedString.Key.foregroundColor : UIColor.white                                                                     ])
            attributedUsernameText.append(attributedAgeText)
            
            usernameLbl.attributedText = attributedUsernameText
            
            if let userLat = UserDefaults.standard.value(forKey: "current_location_latitude") as? String, let userLong = UserDefaults.standard.value(forKey: "current_location_longitude") as? String {
                let currentLocation:CLLocation = CLLocation(latitude: CLLocationDegrees(Double(userLat)!), longitude: CLLocationDegrees(Double(userLong)!))
                if !user.latitude.isEmpty && !user.longitude.isEmpty {
                    
                    let userLoc = CLLocation(latitude: Double(user.latitude)! , longitude: Double(user.longitude)!)
                    let distanceInKM: CLLocationDistance = userLoc.distance(from: currentLocation) / 1000
                    // let kmIntoMiles = distanceInKM * 0.6214
                    locationLbl.text = "\(Int(distanceInKM)) Km away"
                } else {
                    locationLbl.text = ""
                }
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
               backgroundColor = .clear
               let frameGradient = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: bounds.height)
               photo.addBlackGradientLayer(frame: frameGradient, colors: [.clear, .black])
               photo.layer.cornerRadius = 10
               photo.clipsToBounds = true
               
               likeView.alpha = 0
               nopeView.alpha = 0

               likeView.layer.borderWidth = 3
               likeView.layer.cornerRadius = 5
               likeView.clipsToBounds = true
               likeView.layer.borderColor = UIColor(red: 0.101, green: 0.737, blue: 0.611, alpha: 1).cgColor

               nopeView.layer.borderWidth = 3
               nopeView.layer.cornerRadius = 5
               nopeView.clipsToBounds = true
               nopeView.layer.borderColor = UIColor(red: 0.9, green: 0.29, blue: 0.23, alpha: 1).cgColor

        //rotate the nopeview and likeview to (pi/8) degrees clockwise
               likeView.transform = CGAffineTransform(rotationAngle: -.pi / 8)
               nopeView.transform = CGAffineTransform(rotationAngle: .pi / 8)

               nopeLbl.addCharacterSpacing()
               nopeLbl.attributedText = NSAttributedString(string: "NOPE",attributes:[NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize: 30)])

               nopeView.layer.borderColor = UIColor(red: 0.9, green: 0.29, blue: 0.23, alpha: 1).cgColor
               nopeLbl.textColor = UIColor(red: 0.9, green: 0.29, blue: 0.23, alpha: 1)

               likeLbl.addCharacterSpacing()
               likeLbl.attributedText = NSAttributedString(string: "LIKE",attributes:[NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize: 30)])
               likeView.layer.borderColor = UIColor(red: 0.101, green: 0.737, blue: 0.611, alpha: 1).cgColor
               likeLbl.textColor = UIColor(red: 0.101, green: 0.737, blue: 0.611, alpha: 1)


    }

    @IBAction func infoBtnDidTapped(_ sender: UIButton) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let detailVC = storyboard.instantiateViewController(withIdentifier: IDENTIFIER_DETAIL) as! DetailViewController
        detailVC.user = user
        
        self.controller.navigationController?.pushViewController(detailVC, animated: true)

    }
}
