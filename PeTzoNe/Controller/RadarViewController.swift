//
//  RadarViewController.swift
//  PeTzoNe
//
//  Created by Radhi Mighri on 18/08/2020.
//  Copyright © 2020 Radhi Mighri. All rights reserved.
//

import UIKit
import CoreLocation
import GeoFire
import FirebaseDatabase
import ProgressHUD

class RadarViewController: UIViewController {
    
    @IBOutlet weak var cardStack: UIView!
    @IBOutlet weak var refreshImg: UIImageView!
    @IBOutlet weak var nopeImg: UIImageView!
    @IBOutlet weak var likeImg: UIImageView!
    @IBOutlet weak var superLikeImg: UIImageView!
    @IBOutlet weak var boostImg: UIImageView!
    
    let manager = CLLocationManager()
    var userLat = ""
    var userLong = ""
    var geoFire: GeoFire!
    var geoFireRef: DatabaseReference!
    var myQuery: GFQuery!
    var queryHandle: DatabaseHandle?
    var distance: Double = 500
    var users: [User] = []
    var cards: [Card] = []
    var cardInitialLocationCenter: CGPoint!
    var panInitialLocation: CGPoint!
    
    
    override func viewDidLoad() {
        title = "PeTzoNe"
        
        super.viewDidLoad()
        
        configureLocationManager()
        nopeImg.isUserInteractionEnabled = true
               let tapNopeImg = UITapGestureRecognizer(target: self, action: #selector(nopeImgDidTap))
               nopeImg.addGestureRecognizer(tapNopeImg)
               
               likeImg.isUserInteractionEnabled = true
               let tapLikeImg = UITapGestureRecognizer(target: self, action: #selector(likeImgDidTap))
               likeImg.addGestureRecognizer(tapLikeImg)
               
               let newMatchItem = UIBarButtonItem(image: UIImage(named: "icon-chat"), style: UIBarButtonItem.Style.plain, target: self, action: #selector(newMatchItemDidTap))
               self.navigationItem.rightBarButtonItem = newMatchItem

    }
    
    @objc func nopeImgDidTap() {
        guard let firstCard = cards.first else {
            return
        }
        saveToFirebase(like: false, card: firstCard)
        swipeAnimation(translation: -750, angle: -15)
        self.setupTransforms()
    }
    
    @objc func likeImgDidTap() {
        guard let firstCard = cards.first else {
            return
        }
        saveToFirebase(like: true, card: firstCard)
        swipeAnimation(translation: 750, angle: 15)
        self.setupTransforms()
    }
    
    @objc func newMatchItemDidTap() {
          let storyboard = UIStoryboard(name: "Main", bundle: nil)
          let newMatchVC = storyboard.instantiateViewController(withIdentifier: IDENTIFIER_NEW_MATCH) as! NewMatchTableViewController
          self.navigationController?.pushViewController(newMatchVC, animated: true)
      }
    
        func checkIfMatchFor(card: Card) {
            Ref().databaseActionForUser(uid: card.user.uid).observeSingleEvent(of: .value) { (snapshot) in
                guard let dict = snapshot.value as? [String: Bool] else { return }
                if dict.keys.contains(Api.User.currentUserId), dict[Api.User.currentUserId] == true {
                    // send push notification
                    print("Has Matched !")
                Ref().dataBaseRoot.child("newMatch").child(Api.User.currentUserId).updateChildValues([card.user.uid: true])
                Ref().dataBaseRoot.child("newMatch").child(card.user.uid).updateChildValues([Api.User.currentUserId: true])

                    Api.User.getUserInforSingleEvent(uid: Api.User.currentUserId, onSuccess: { (user) in
//                        sendRequestNotification(isMatch: true, fromUser: user, toUser: card.user, message: "Tap to chat with \(user.username)", badge: 1)
//                          sendRequestNotification(isMatch: true, fromUser: card.user, toUser: user, message: "Tap to chat with \(card.user.username)", badge: 1)
                    })
                }
            }
        }
    
    
    func saveToFirebase(like: Bool, card: Card) {
           Ref().databaseActionForUser(uid: Api.User.currentUserId)
               .updateChildValues([card.user.uid: like]) { (error, ref) in
                   if error == nil, like == true {
                       // check if match { send push notificaiton }
//                       self.checkIfMatchFor(card: card)
                   }
           }
       }


    func swipeAnimation(translation: CGFloat, angle: CGFloat) {
        let duration = 0.5
        let translationAnimation = CABasicAnimation(keyPath: "position.x")
        translationAnimation.toValue = translation
        translationAnimation.duration = duration
        translationAnimation.fillMode = .forwards
        translationAnimation.timingFunction = CAMediaTimingFunction(name: .easeOut)
        translationAnimation.isRemovedOnCompletion = false

        let rotationAnimation = CABasicAnimation(keyPath: "transform.rotation.z")
        rotationAnimation.toValue = angle * CGFloat.pi / 180
        rotationAnimation.duration = duration
        guard let firstCard = cards.first else {
            return
        }
        for (index, c) in self.cards.enumerated() {
            if c.user.uid == firstCard.user.uid {
                self.cards.remove(at: index)
                self.users.remove(at: index)
            }
        }

        self.setupGestures()

        CATransaction.setCompletionBlock {

            firstCard.removeFromSuperview()
        }
        firstCard.layer.add(translationAnimation, forKey: "translation")
        firstCard.layer.add(rotationAnimation, forKey: "rotation")

        CATransaction.commit()
    }
    
    @objc func pan(gesture: UIPanGestureRecognizer) {
        let card = gesture.view! as! Card
        let translation = gesture.translation(in: cardStack)

        switch gesture.state {
        case .began:
            panInitialLocation = gesture.location(in: cardStack)
            print("began")
            print("panInitialLocation")
            print(panInitialLocation)

        case .changed:
            print("changed")
            print("x: \(translation.x)")
            print("y: \(translation.y)")

            card.center.x = cardInitialLocationCenter.x + translation.x
            card.center.y = cardInitialLocationCenter.y + translation.y

            if translation.x > 0 {
                // show like icon
                // 0<= alpha <=1
                card.likeView.alpha = abs(translation.x * 2) / cardStack.bounds.midX
                card.nopeView.alpha = 0
            } else {
                // show unlike icon
                card.nopeView.alpha = abs(translation.x * 2) / cardStack.bounds.midX
                card.likeView.alpha = 0
            }

            card.transform = self.transform(view: card, for: translation)

        case .ended:

            if translation.x > 75 {
                UIView.animate(withDuration: 0.3, animations: {
                    card.center = CGPoint(x: self.cardInitialLocationCenter.x + 1000, y: self.cardInitialLocationCenter.y + 1000)
                }) { (bool) in
                    // remove card
                    card.removeFromSuperview()
                }
                // save after like a card
                saveToFirebase(like: true, card: card)
                self.updateCards(card: card)

                return
            } else if translation.x < -75 {
                UIView.animate(withDuration: 0.3, animations: {
                    card.center = CGPoint(x: self.cardInitialLocationCenter.x - 1000, y: self.cardInitialLocationCenter.y + 1000)
                }) { (bool) in
                    // remove card
                    card.removeFromSuperview()
                }
                // save after dislike a card
                saveToFirebase(like: false, card: card)
                self.updateCards(card: card)

                return
            }


            UIView.animate(withDuration: 0.3) {
                card.center = self.cardInitialLocationCenter
                card.likeView.alpha = 0
                card.nopeView.alpha = 0
                card.transform = CGAffineTransform.identity
            }
        default:
            break
        }
    }
    func transform(view: UIView, for translation: CGPoint) -> CGAffineTransform {
        let moveBy = CGAffineTransform(translationX: translation.x, y: translation.y)
        let rotation = -translation.x / (view.frame.width / 2)
        return moveBy.rotated(by: rotation)
    }

    func updateCards(card: Card) {
        for (index, c) in self.cards.enumerated() {
            if c.user.uid == card.user.uid {
                self.cards.remove(at: index)
                self.users.remove(at: index)
            }
        }

        setupGestures()
        setupTransforms()
    }

    func setupGestures() {
        for card in cards {
            let gestures = card.gestureRecognizers ?? []
            for g in gestures {
                card.removeGestureRecognizer(g)
            }
        }

        if let firstCard = cards.first {
            firstCard.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(pan(gesture:))))
        }
    }
//
    func configureLocationManager() {
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.distanceFilter = kCLDistanceFilterNone
        manager.pausesLocationUpdatesAutomatically = true
        manager.delegate = self
        manager.requestWhenInUseAuthorization()
        if CLLocationManager.locationServicesEnabled() {
            manager.startUpdatingLocation()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.prefersLargeTitles = false
        tabBarController?.tabBar.isHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.navigationBar.prefersLargeTitles = true
        tabBarController?.tabBar.isHidden = false
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
                    self.users.append(user)
                    self.setupCard(user: user)
                    print(user.username)
                })
            }
        })
        
        
    }
    
    func setupCard(user: User) {
        let card: Card = UIView.fromNib()
        card.frame = CGRect(x: 0, y: 0, width: cardStack.bounds.width, height: cardStack.bounds.height)
        card.user = user
                 card.controller = self
        cards.append(card)
        cardStack.addSubview(card)
        cardStack.sendSubviewToBack(card)
        
        setupTransforms()
        
        if cards.count == 1 {
            cardInitialLocationCenter = card.center
            card.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(pan(gesture:))))
        }
        
        if cards.count == 1 {
                   card.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(pan(gesture:))))
               }
        
    }
    
    func setupTransforms() {
        for (i, card) in cards.enumerated() {
            if i == 0 { continue; }
            
            if i > 3 { return }
            
            var transform = CGAffineTransform.identity
            if i % 2 == 0 {
                transform = transform.translatedBy(x: CGFloat(i)*4, y: 0)
                transform = transform.rotated(by: CGFloat(Double.pi)/150*CGFloat(i))
            } else {
                transform = transform.translatedBy(x: -CGFloat(i)*4, y: 0)
                transform = transform.rotated(by: -CGFloat(Double.pi)/150*CGFloat(i))
            }
            
            card.transform = transform
        }
    }
    
}


extension RadarViewController: CLLocationManagerDelegate {
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
