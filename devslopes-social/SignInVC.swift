//
//  ViewController.swift
//  devslopes-social
//
//  Created by Kaushal Dhruw on 01/08/17.
//  Copyright © 2017 drulabs Inc. All rights reserved.
//

import UIKit
import FBSDKCoreKit
import FBSDKLoginKit
import Firebase
import SwiftKeychainWrapper

class SignInVC: UIViewController {
    
    @IBOutlet weak var emailAddress: FancyField!
    @IBOutlet weak var password: FancyField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if let _ = KeychainWrapper.standard.string(forKey: KEY_UID) {
            performSegue(withIdentifier: "goToFeed", sender: nil)
        }
    }
    
    @IBAction func facebookButtonTapped(_ sender: Any) {
        
        let facebookLogin = FBSDKLoginManager()
        
        facebookLogin.logIn(withReadPermissions: ["email"], from: self) { (result, error) in
            if error != nil {
                print("Dhruw: unable to authentication with facebook")
            } else if result?.isCancelled == true {
                print("Dhruw: user cancelled facebook authentication")
            } else {
                print("Dhruw: successfully authentication with facebook")
                let credential = FacebookAuthProvider.credential(withAccessToken: FBSDKAccessToken.current().tokenString)
                self.firebaseAuth(credential)
            }
        }
        
    }
    
    func firebaseAuth(_ crendential: AuthCredential){
        Auth.auth().signIn(with: crendential) { (user, error) in
            if error != nil {
                print("Dhruw: Unable to authenticate with facebook - \(String(describing: error))")
            } else {
                print("Dhruw: successfully authenticated with firebase")
                if let user = user {
                    self.completeSignIn(id: user.uid)
                }
            }
        }
    }
    
    @IBAction func signInTapped(_ sender: Any) {
        
        if let email = emailAddress.text, let pwd = password.text {
            Auth.auth().signIn(withEmail: email, password: pwd) { (user, error) in
                if error == nil {
                    print("Dhruw: email authenticated with firebase")
                    if let user = user {
                        self.completeSignIn(id: user.uid)
                    }
                } else {
                    Auth.auth().createUser(withEmail: email, password: pwd) { (user, error) in
                        if error != nil {
                            print("Dhruw: unable to authenticate with firebase using email")
                        } else {
                            print("Dhruw: successfully created and authenticated with firebase using email")
                            if let user = user {
                                self.completeSignIn(id: user.uid)
                            }
                        }
                    }
                }
            }
        }
    }
    
    func completeSignIn(id: String) {
        let keychainResult = KeychainWrapper.standard.set(id, forKey: KEY_UID)
        print("Dhruw: Keychain result save status: \(keychainResult)")
        performSegue(withIdentifier: "goToFeed", sender: nil)
    }
}

