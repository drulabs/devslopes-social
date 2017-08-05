//
//  FeedCell.swift
//  devslopes-social
//
//  Created by Kaushal Dhruw on 04/08/17.
//  Copyright © 2017 drulabs Inc. All rights reserved.
//

import UIKit
import Firebase

class FeedCell: UITableViewCell {
    
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var usernameLbl: UILabel!
    @IBOutlet weak var feedImage: UIImageView!
    @IBOutlet weak var caption: UITextView!
    @IBOutlet weak var likesLbl: UILabel!
    
    var post: Post!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func configureCell(post: Post, img: UIImage? = nil) {
        self.post = post
        self.caption.text = post.caption
        self.likesLbl.text = "\(post.likes)"
        
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
                            FeedVC.imageCache.setObject(image, forKey: self.post.imageUrl as NSString)
                        }
                    }
                }
            })
        }
    }
    
}
