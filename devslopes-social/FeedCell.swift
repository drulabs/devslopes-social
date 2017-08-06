//
//  FeedCell.swift
//  devslopes-social
//
//  Created by Kaushal Dhruw on 04/08/17.
//  Copyright © 2017 drulabs Inc. All rights reserved.
//

import UIKit
import Firebase
import SwiftKeychainWrapper

class FeedCell: UITableViewCell {
    
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var usernameLbl: UILabel!
    @IBOutlet weak var feedImage: UIImageView!
    @IBOutlet weak var caption: UITextView!
    @IBOutlet weak var likesLbl: UILabel!
    @IBOutlet weak var likeImage: UIImageView!
    @IBOutlet weak var deleteBtn: UIButton!
    
    
    var post: Post!
    
    var likesRef: DatabaseReference!
    var uploaderRef: DatabaseReference!
    
    let currentUserProfileId = KeychainWrapper.standard.string(forKey: KEY_UID)
    
    override func awakeFromNib() {
        super.awakeFromNib()
        let tap = UITapGestureRecognizer(target: self, action: #selector(likeTapped))
        tap.numberOfTapsRequired = 1
        likeImage.addGestureRecognizer(tap)
        likeImage.isUserInteractionEnabled = true
    }
    
    func configureCell(post: Post, img: UIImage? = nil) {
        self.post = post
        self.caption.text = post.caption
        self.likesLbl.text = "\(post.likes)"
        
        likesRef = DataService.ds.REF_CURRENT_USER.child("likes").child(self.post.postKey)
        uploaderRef = DataService.ds.REF_USERS.child(self.post.uploadedByUser)
        
        if let img = img {
            self.feedImage.image = img
        } else {
            let ref = Storage.storage().reference(forURL: post.imageUrl)
            ref.getData(maxSize: 2 * 1024 * 1024, completion: { (data, error) in
                
                if error != nil {
                    print("Dhruw: Unable to download image from firebase: \(String(describing: error))")
                } else {
                    print("Dhruw: Image downloaded from firebase")
                    
                    if let imageData = data {
                        if let image = UIImage(data: imageData) {
                            self.feedImage.image = image
//                            FeedVC.imageCache.setObject(image, forKey: self.post.imageUrl as NSString)
                        }
                    }
                }
            })
        }
        
        if post.uploadedByUser == currentUserProfileId {
            deleteBtn.isHidden = false
        } else {
            deleteBtn.isHidden = true
        }
        
        likesRef.observeSingleEvent(of: .value, with: { (snapshot) in
            if let _ = snapshot.value as? NSNull {
                self.likeImage.image = UIImage(named: "empty-heart")
            } else {
                self.likeImage.image = UIImage(named: "filled-heart")
            }
        })
        
        uploaderRef.observeSingleEvent(of: .value, with: {(snapshot) in
            if let uploaderImg = snapshot.childSnapshot(forPath: "image_url").value as? String {
                let storageRef = Storage.storage().reference(forURL: uploaderImg)
                storageRef.getData(maxSize: 10 * 1024 * 1024, completion: {(data, error) in
                    
                    if error != nil {
                        print("Dhruw: Unable to download profile image from firebase: \(String(describing: error))")
                    } else {
                        print("Dhruw: Profile image downloaded from firebase")
                        
                        if let profileImgData = data {
                            if let actualImg = UIImage(data: profileImgData) {
                                self.profileImage.image = actualImg
                            }
                        }
                    }
                })
            }
            
            if let uploaderName = snapshot.childSnapshot(forPath: "display_name").value as? String {
                self.usernameLbl.text = uploaderName
            }
        })
    }
    
    func likeTapped(sender: UITapGestureRecognizer) {
        likesRef.observeSingleEvent(of: .value, with: { (snapshot) in
            if let _ = snapshot.value as? NSNull {
                self.likeImage.image = UIImage(named: "filled-heart")
                self.post.adjustLikes(addLike: true)
                self.likesRef.setValue(true)
            } else {
                self.likeImage.image = UIImage(named: "empty-heart")
                self.post.adjustLikes(addLike: false)
                self.likesRef.removeValue()
            }
        })
    }
    
    @IBAction func deleteTapped(_ sender: Any) {
        if !deleteBtn.isHidden {
            DataService.ds.REF_POSTS.child(post.postKey).removeValue()
//            DataService.ds.REF_CURRENT_USER.child("likes").child(post.postKey).removeValue()
        } else {
            print("Dhruw: You can't delete others posts")
        }
    }
}
