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

class SignInVC: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
            }
        }
    }

}

