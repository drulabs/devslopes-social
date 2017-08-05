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

class FeedVC: UIViewController, UITableViewDelegate, UITableViewDataSource, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var imageAdd: FancyCircleView!
    @IBOutlet weak var captionField: FancyField!
    
    var posts = [Post]()
    var imagePicker: UIImagePickerController!
    
    var imageSelected = false
    
    // Image cache
    static var imageCache: NSCache<NSString, UIImage> = NSCache()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        tableView.delegate = self
        tableView.dataSource = self
        
        imagePicker = UIImagePickerController()
        imagePicker.allowsEditing = true
        imagePicker.delegate = self
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(SignInVC.dismissKeyboard))
        view.addGestureRecognizer(tap)
        
        DataService.ds.REF_POSTS.observe(.value, with: { (snapshot) in
            if let snapshots = snapshot.children.allObjects as? [DataSnapshot] {
                
                self.posts = [] // clear the old array
                
                for post in snapshots {
                    if let postDict = post.value as? Dictionary<String, Any> {
                        let key = post.key
                        let singlePost = Post(postKey: key, postData: postDict)
                        self.posts.append(singlePost)
                    }
                }
                self.tableView.reloadData()
            }
        })
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return posts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let post = posts[indexPath.row]
        if let feedCell = tableView.dequeueReusableCell(withIdentifier: "feedCell") as? FeedCell {
            
            if let image = FeedVC.imageCache.object(forKey: post.imageUrl as NSString) {
                feedCell.configureCell(post: post, img: image)
            } else {
                feedCell.configureCell(post: post)
            }
            return feedCell
        } else {
            return FeedCell()
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        if let selectedImage = info[UIImagePickerControllerEditedImage] as? UIImage {
            imageAdd.image = selectedImage
            imageSelected = true
        } else {
            print("Dhruw: invalid image selected")
        }
        imagePicker.dismiss(animated: true, completion: nil)
    }
    
    func postToFirebase(imageUrl: String) {
        let post: Dictionary<String, Any> = [
            "caption": captionField.text ?? "No caption provided",
            "image_url": imageUrl,
            "likes": 0
        ]
        
        let firebasePost = DataService.ds.REF_POSTS.childByAutoId()
        firebasePost.setValue(post)
        
        // clear the post params
        self.imageSelected = false
        self.captionField.text = ""
        self.imageAdd.image = UIImage(named: "add-image")
        
        self.tableView.reloadData()
    }
    
    func dismissKeyboard() {
        view.endEditing(true)
    }

    
    @IBAction func postButtonTapped(_ sender: Any) {
        
        guard let caption = captionField.text, caption != "" else {
            print("Dhruw: Caption can't be empty")
            return
        }
        
        guard let image = imageAdd.image, imageSelected else {
            print("Dhruw: An image must be selected")
            return
        }
        
        if let imageData = UIImageJPEGRepresentation(image, 0.2) {
            
            let imageUid = NSUUID().uuidString
            let imgMetadata = StorageMetadata()
            imgMetadata.contentType = "image/jpeg"
            
            dismissKeyboard()
            
            DataService.ds.REF_POST_PICS.child(imageUid).putData(imageData, metadata: imgMetadata) { (metadata, error) in
                
                if error != nil {
                    print("Dhruw: unable to upload image to  firebase storage image")
                } else {
                    print("Dhruw: successfully uploaded image to firebase")
                    
                    if let downloadURL = metadata?.downloadURL()?.absoluteString {
                        self.postToFirebase(imageUrl: downloadURL)
                    }
                }
                
            }
        }
        
    }
    
    @IBAction func addImageTapped(_ sender: Any) {
        present(imagePicker, animated: true, completion: nil)
    }
    
    @IBAction func signOutTapped(_ sender: Any) {
        try! Auth.auth().signOut()
        let keychainResult = KeychainWrapper.standard.removeObject(forKey: KEY_UID)
        print("Dhruw: Signed out from firebase. Keychain result: \(keychainResult)")
        performSegue(withIdentifier: "goToSignIn", sender: nil)
        
    }
}
