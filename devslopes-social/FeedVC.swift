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

class FeedVC: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        tableView.delegate = self
        tableView.dataSource = self
        
        DataService.ds.REF_POSTS.observe(.value, with: { (snapshot) in
            print(snapshot.value ?? "none")
        })
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return tableView.dequeueReusableCell(withIdentifier: "feedCell") as! FeedCell
    }
    
    @IBAction func signOutTapped(_ sender: Any) {
        try! Auth.auth().signOut()
        let keychainResult = KeychainWrapper.standard.removeObject(forKey: KEY_UID)
        print("Dhruw: Signed out from firebase. Keychain result: \(keychainResult)")
        performSegue(withIdentifier: "goToSignIn", sender: nil)
        
    }
}
