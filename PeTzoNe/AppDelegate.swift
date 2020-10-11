//
//  AppDelegate.swift
//  PeTzoNe
//
//  Created by Radhi Mighri on 10/08/2020.
//  Copyright © 2020 Radhi Mighri. All rights reserved.
//

import UIKit
import FirebaseCore
import FirebaseAuth
import FBSDKCoreKit
import GoogleSignIn



@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, GIDSignInDelegate {
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        
    }
    
    
    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

        //fb sign in
        ApplicationDelegate.shared.application(application, didFinishLaunchingWithOptions: launchOptions)
        //google sign in
//        GIDSignIn.sharedInstance().clientID = FirebaseApp.app()?.options.clientID
        GIDSignIn.sharedInstance().clientID = "798875553537-gi8402u2lu68ku8lu7r70u7nfg9pnd3b.apps.googleusercontent.com"
        

        GIDSignIn.sharedInstance()?.delegate = self

        return true
    }
    
      
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        var handled = false
        
        if url.absoluteString.contains("fb") {
            handled = ApplicationDelegate.shared.application(app, open: url, options: options)
        }
            else {
//                handled = GIDSignIn.sharedInstance()!.handle(url, sourceApplication: options[UIApplication.OpenURLOptionsKey.sourceApplication] as? String, annotation: [:])
           handled =  GIDSignIn.sharedInstance().handle(url)

            }
            return handled
        }
    

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
     
    }


}

