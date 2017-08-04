//
//  FeedVC.swift
//  devslopes-social
//
//  Created by Kaushal Dhruw on 02/08/17.
//  Copyright © 2017 drulabs Inc. All rights reserved.
//

import UIKit
import Firebase
import SwiftKeychainWrapper

class FeedVC: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    func signOutTapped(_ sender: Any) {
        try! Auth.auth().signOut()
        let keychainResult = KeychainWrapper.standard.removeObject(forKey: KEY_UID)
        print("Dhruw: Signed out from firebase. Keychain result: \(keychainResult)")
        performSegue(withIdentifier: "goToSignIn", sender: nil)
        
    }
}
