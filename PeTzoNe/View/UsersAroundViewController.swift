//
//  UsersAroundViewController.swift
//  PeTzoNe
//
//  Created by Radhi Mighri on 17/08/2020.
//  Copyright © 2020 Radhi Mighri. All rights reserved.
//

import UIKit
import CoreLocation
import GeoFire
import FirebaseDatabase
import ProgressHUD


class UsersAroundViewController: UIViewController {
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var segmentControl: UISegmentedControl!
    @IBOutlet weak var mapViewButton: UIButton!
    
    
    let mySlider = UISlider()
    let distanceLabel = UILabel()
    let manager = CLLocationManager()
    var userLat = ""
    var userLong = ""
    var geoFire: GeoFire!
    var geoFireRef: DatabaseReference!
    var myQuery: GFQuery!
    var queryHandle: DatabaseHandle?
    var distance: Double = 500
    var users: [User] = []
    var currentLocation: CLLocation?

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        collectionView.delegate = self
        collectionView.dataSource = self
        setupNavigationBar()
        configureLocationManager()
        
    }
    
    func configureLocationManager() {
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.distanceFilter = kCLDistanceFilterNone
        manager.pausesLocationUpdatesAutomatically = true
        manager.delegate = self
        manager.requestWhenInUseAuthorization()
        if CLLocationManager.locationServicesEnabled() {
            manager.startUpdatingLocation()
        }
        
        self.geoFireRef = Ref().databaseGeo
        self.geoFire = GeoFire(firebaseRef: self.geoFireRef)

    }
    
    
   func setupNavigationBar() {
        title = "Find Users"
        let refresh = UIBarButtonItem(image: UIImage(named: "icon-refresh"), style: UIBarButtonItem.Style.plain, target: self, action: #selector(refreshTapped))
        distanceLabel.frame = CGRect(x: 0, y: 0, width: 50, height: 20)
        distanceLabel.font = UIFont.systemFont(ofSize: 13)
        distanceLabel.text = "\(Int(distance)) km"
        distanceLabel.textColor = UIColor(red: 93/255, green: 79/255, blue: 141/255, alpha: 1)
        let distanceItem = UIBarButtonItem(customView: distanceLabel)
        
        mySlider.frame = CGRect(x: 0, y: 0, width: 200, height: 20)
        mySlider.minimumValue = 1
        mySlider.maximumValue = 999
        mySlider.isContinuous = true
        mySlider.value = Float(distance)
        mySlider.tintColor = UIColor(red: 93/255, green: 79/255, blue: 141/255, alpha: 1)
        mySlider.addTarget(self, action: #selector(sliderValueChanged(slider:event:)), for: UIControl.Event.valueChanged)
        
        let sliderItem = UIBarButtonItem(customView: mySlider)
        navigationItem.rightBarButtonItems = [refresh, distanceItem, sliderItem]
    }

    
    func findUsers() {
           
           if queryHandle != nil, myQuery != nil {
               myQuery.removeObserver(withFirebaseHandle: queryHandle!)
               myQuery = nil
               queryHandle = nil
           }
           
           guard let userLat = UserDefaults.standard.value(forKey: "current_location_latitude") as? String, let userLong = UserDefaults.standard.value(forKey: "current_location_longitude") as? String else {
               return
           }
           
           let location: CLLocation = CLLocation(latitude: CLLocationDegrees(Double(userLat)!), longitude: CLLocationDegrees(Double(userLong)!))
           self.users.removeAll()
           
           myQuery = geoFire.query(at: location, withRadius: distance)
           
        queryHandle = myQuery.observe(.keyEntered, with: { (key, location) in
              //print(key)

            if key != Api.User.currentUserId {
                Api.User.getUserInforSingleEvent(uid: key, onSuccess: { (user) in
                    if self.users.contains(user) {
                        return
                    }
                    if user.isMale == nil {
                        return
                    }
                    switch self.segmentControl.selectedSegmentIndex {
                    case 0:
                    if user.isMale! {
                        self.users.append(user)
                    }
                    case 1:
                    if !user.isMale! {
                        self.users.append(user)
                    }
                    case 2:
                        self.users.append(user)
                    default:
                        break
                    }
                    self.collectionView.reloadData()
                })
            }
          })
        
        
       }

    
    @objc func refreshTapped() {
                 findUsers()
    }
    
    @IBAction func segmentChanged(_ sender: UISegmentedControl) {
        findUsers()

    }
    
    
    @IBAction func mapButtonTapped(_ sender: UIButton) {
             let storyboard = UIStoryboard(name: "Main", bundle: nil)
             let mapVC = storyboard.instantiateViewController(withIdentifier: IDENTIFIER_MAP) as! MapViewController
             mapVC.users = self.users
             self.navigationController?.pushViewController(mapVC, animated: true)
    }
    

    @objc func sliderValueChanged(slider: UISlider, event: UIEvent) {
        //           print(Double(slider.value))
        if let touchEvent = event.allTouches?.first {
                           distance = Double(slider.value)
            distanceLabel.text = "\( Int(slider.value)) Km"
            
                           switch touchEvent.phase {
                           case .began:
                               print("began")
                           case .moved:
                               print("moved")
                           case .ended:
                               findUsers()
            
                           default:
                               break
            
                           }
        }
    }
    

    
    

}

extension UsersAroundViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.users.count
        
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "UserAroundCollectionViewCell", for: indexPath) as! UserAroundCollectionViewCell
                let user = users[indexPath.item]
                cell.controller = self
                cell.loadData(user, currentLocation: self.currentLocation)
        
        
        return cell
    }

        func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
            if let cell = collectionView.cellForItem(at: indexPath) as? UserAroundCollectionViewCell {
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let detailVC = storyboard.instantiateViewController(withIdentifier: IDENTIFIER_DETAIL) as! DetailViewController
                detailVC.user = cell.user

                self.navigationController?.pushViewController(detailVC, animated: true)
            }
        }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: view.frame.size.width/3 - 2, height: view.frame.size.width/3)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 1
    }
    
}

extension UsersAroundViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if (status == .authorizedAlways) || (status == .authorizedWhenInUse) {
            manager.startUpdatingLocation()
        }
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        ProgressHUD.showError("\(error.localizedDescription)")
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        manager.stopUpdatingLocation()
        manager.delegate = nil
        let updatedLocation: CLLocation = locations.first!
        let newCoordinate: CLLocationCoordinate2D = updatedLocation.coordinate
        self.currentLocation = updatedLocation
//         update location
        let userDefaults: UserDefaults = UserDefaults.standard
        userDefaults.set("\(newCoordinate.latitude)", forKey: "current_location_latitude")
        userDefaults.set("\(newCoordinate.longitude)", forKey: "current_location_longitude")
        userDefaults.synchronize()

        if let userLat = UserDefaults.standard.value(forKey: "current_location_latitude") as? String, let userLong = UserDefaults.standard.value(forKey: "current_location_longitude") as? String {
            let location: CLLocation = CLLocation(latitude: CLLocationDegrees(Double(userLat)!), longitude: CLLocationDegrees(Double(userLong)!))
            
            Ref().databaseSpecificUser(uid: Api.User.currentUserId).updateChildValues([LAT: userLat, LONG: userLong])

            self.geoFire.setLocation(location, forKey: Api.User.currentUserId) { (error) in
                if error == nil {
                    // Find Users
                    self.findUsers()
                }
            }
        }

    }
}



