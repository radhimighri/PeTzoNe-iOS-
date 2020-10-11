//
//  UserApi.swift
//  PeTzoNe
//
//  Created by Radhi Mighri on 11/08/2020.
//  Copyright © 2020 Radhi Mighri. All rights reserved.
//

import Foundation
import FirebaseAuth
import FirebaseDatabase
import FirebaseStorage
import ProgressHUD
import GoogleSignIn

class UserApi {
    
    var currentUserId: String {
        return Auth.auth().currentUser != nil ? Auth.auth().currentUser!.uid : ""
    }
    
    func signIn(email: String, password: String, onSuccess: @escaping() -> Void, onError: @escaping(_ errorMessage: String) -> Void) {
        Auth.auth().signIn(withEmail: email, password: password) { (authData, error) in
            if error != nil {
                onError(error!.localizedDescription)
                return
            }
            print(authData?.user.uid)
            onSuccess()
        }
    }
    
    
    func signUp(withUsername username: String, email: String, password: String, image: UIImage?, onSuccess: @escaping() -> Void, onError: @escaping(_ errorMessage: String) -> Void) {
        
        Auth.auth().createUser(withEmail: email, password: password) { (AuthDataResult, error) in
            if error != nil {
                ProgressHUD.showError(error!.localizedDescription)
                return
            }
            if let authData = AuthDataResult {
                //                print(authData.user.email)
                //put the created profile in a dictionary
                let dict: Dictionary<String, Any> = [
                    UID: authData.user.uid,
                    EMAIL: authData.user.email,
                    USERNAME: username,
                    PROFILE_IMAGE_URL: "",
                    STATUS: "Welcome to PeTzoNe"
                ]
                
                
                guard let imageSelected = image else {
                    //print("Avatar is nil")
                    ProgressHUD.showError(ERROR_EMPTY_PHOTO)
                    return
                }
                guard let imageData = imageSelected.jpegData(compressionQuality: 0.4) else {
                    return
                }
                
                let storageProfile = Ref().storageSpecificProfile(uid: authData.user.uid)
                
                let metadata = StorageMetadata()
                metadata.contentType = "image/jpg"
                
                
                StorageService.savePhoto(username: username, uid: authData.user.uid, imageData: imageData, metadata: metadata, storageProfileRef: storageProfile, dict: dict, onSuccess: {
                    onSuccess()
                }) { (errorMessage) in
                    onError(errorMessage)
                }
                
            }
        }
    }
    
    
    
    func saveUserProfile(dict: Dictionary<String, Any>, onSuccess: @escaping() -> Void, onError: @escaping(_ errorMessage: String) -> Void) {
        Ref().databaseSpecificUser(uid: Api.User.currentUserId).updateChildValues(dict) { (error, databaseRef) in
            if error != nil {
                onError(error!.localizedDescription)
                return
            }
            onSuccess()
        }
    }
    
    
    
    func resetPassword(email: String, onSuccess: @escaping() -> Void, onError: @escaping(_ errorMessage: String) -> Void) {
        Auth.auth().sendPasswordReset(withEmail: email) { (error) in
            if error == nil {
                onSuccess()
            } else {
                onError(error!.localizedDescription)
            }
        }
    }
    
    func logOut() {
        do {
            Api.User.isOnline(bool: false)
            
            
            if let providerData = Auth.auth().currentUser?.providerData {
                           let userInfo = providerData[0]
                           
                           switch userInfo.providerID {
                           case "google.com":
                               GIDSignIn.sharedInstance()?.signOut()
                           default:
                               break
                           }
                       }

            
            
            try Auth.auth().signOut()
        }catch {
            ProgressHUD.showError(error.localizedDescription)
            return
        }
        //        (UIApplication.shared.delegate as! AppDelegate).configureInitialViewController()
        //        (UIApplication.shared.delegate as! SceneDelegate).configureInitialViewController()
        let scene = UIApplication.shared.connectedScenes.first
        if let sd : SceneDelegate = (scene?.delegate as? SceneDelegate) {
            sd.configureInitialViewController()
        }
        
        
    }
    
//    func observeUsers(onSuccess: @escaping(User) -> Void) {
    func observeUsers(onSuccess: @escaping(UserCompletion)) {

        //        print(Ref().dataBaseRoot.ref.description())
        //        print(Ref().databaseUsers.ref.description())
        
        Ref().databaseUsers.observe(.childAdded) { (snapshot) in
            if let dict = snapshot.value as? Dictionary<String, Any> {
                if let user = User.transformUser(dict: dict) {
                    onSuccess(user)
                }
            }
        }
    }
    
    //Load user's profile once and then does not trigger again
    func getUserInforSingleEvent(uid: String, onSuccess: @escaping(UserCompletion)) {
        let ref = Ref().databaseSpecificUser(uid: uid)
        ref.observe(.value) { (snapshot) in
            if let dict = snapshot.value as? Dictionary<String, Any> {
                if let user = User.transformUser(dict: dict) {
                    onSuccess(user)
                }
            }
        }
    }
    
    func getUserInfor(uid: String, onSuccess: @escaping(UserCompletion)) {
        let ref = Ref().databaseSpecificUser(uid: uid)
        ref.observeSingleEvent(of: .value) { (snapshot) in
            if let dict = snapshot.value as? Dictionary<String, Any> {
                if let user = User.transformUser(dict: dict) {
                    onSuccess(user)
                }
            }
        }
    }
    
    
    func isOnline(bool: Bool) {
        if !Api.User.currentUserId.isEmpty {
            let ref = Ref().dataBaseIsOnline(uid: Api.User.currentUserId)
            let dict: Dictionary<String, Any> = [
                "online": bool as Any,
                "latest": Date().timeIntervalSince1970 as Any
            ]
            ref.updateChildValues(dict)
        }
    }
    
    func typing(from: String, to: String) {
        let ref = Ref().dataBaseIsOnline(uid: from)
        let dict: Dictionary<String, Any> = [
            "typing": to
        ]
        ref.updateChildValues(dict)
    }
    
    func observeNewMatch(onSuccess: @escaping(UserCompletion)) {    Ref().dataBaseRoot.child("newMatch").child(Api.User.currentUserId).observeSingleEvent(of: .value) { (snapshot) in
            guard let dict = snapshot.value as? [String: Bool] else { return }
            dict.forEach({ (key, value) in
                self.getUserInforSingleEvent(uid: key, onSuccess: { (user) in
                    onSuccess(user)
                })
            })
        }
    }
    
    
}

typealias UserCompletion = (User) -> Void
