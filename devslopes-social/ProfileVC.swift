//
//  ProfileVC.swift
//  devslopes-social
//
//  Created by Kaushal Dhruw on 06/08/17.
//  Copyright © 2017 drulabs Inc. All rights reserved.
//

import UIKit
import Firebase
import SwiftKeychainWrapper

class ProfileVC: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var imagePicker: FancyCircleView!
    @IBOutlet weak var displayName: FancyField!
    
    var imgPickerController: UIImagePickerController!
    
    var imagePicked = false
    
    var profileId: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imgPickerController = UIImagePickerController()
        imgPickerController.allowsEditing = true
        imgPickerController.delegate = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if let _ = KeychainWrapper.standard.string(forKey: KEY_UID) {
            performSegue(withIdentifier: "goToFeeds", sender: nil)
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let selectedImage = info[UIImagePickerControllerEditedImage] as? UIImage {
            imagePicker.image = selectedImage
            imagePicked = true
        } else {
            print("Dhruw: invalid profile image selected")
        }
        imgPickerController.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func saveTapped(_ sender: Any) {
        
        guard let profileImage = imagePicker.image, imagePicked else {
            print("Dhruw: Profile image not selected")
            return
        }
        
        guard let userDisplayName = displayName.text else {
            print("Dhruw: Display name cannot be empty")
            return
        }
        
        if let profileImageData = UIImageJPEGRepresentation(profileImage, 0.2) {
            
            let profileImgUid = NSUUID().uuidString
            let profileImgMeta = StorageMetadata()
            profileImgMeta.contentType = "image/jpeg"
            
            dismissKeyboard()
            
            DataService.ds.REF_POST_PICS.child(profileImgUid).putData(profileImageData, metadata: profileImgMeta) { (metadata, error) in
                
                if error != nil {
                    print("Dhruw: unable to upload profile image")
                } else {
                    print("Dhruw: successfully uploaded profile image")
                    
                    if let profileImgURL = metadata?.downloadURL()?.absoluteString {
                        self.saveProfileInfo(userDisplayName, profileImgURL)
                    }
                }
            }
        }
    }
    
    func saveProfileInfo(_ userDisplayName: String, _ profileImgURL: String) {
        let currentUserRef = DataService.ds.REF_USERS.child(profileId)
        currentUserRef.child("display_name").setValue(userDisplayName)
        currentUserRef.child("image_url").setValue(profileImgURL)
        
        let keychainResult = KeychainWrapper.standard.set(profileId, forKey: KEY_UID)
        print("Dhruw: Keychain result save status: \(keychainResult)")
        performSegue(withIdentifier: "goToFeeds", sender: nil)
    }
    
    func dismissKeyboard() {
        view.endEditing(true)
    }
    
    @IBAction func imagePickerTapped(_ sender: Any) {
        present(imgPickerController, animated: true, completion: nil)
    }
}
