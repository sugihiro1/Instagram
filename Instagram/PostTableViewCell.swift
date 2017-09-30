//
//  PostTableViewCell.swift
//  Instagram
//
//  Created by 杉山尋美 on 2017/09/25.
//  Copyright © 2017年 hiromi.sugiyama. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase
import SVProgressHUD

var commentPosted: String = ""

class PostTableViewCell: UITableViewCell {
  
  @IBOutlet weak var postImageView: UIImageView!
  @IBOutlet weak var likeButton: UIButton!
  @IBOutlet weak var likeLabel: UILabel!
  @IBOutlet weak var dateLabel: UILabel!
  @IBOutlet weak var captionLabel: UILabel!

  @IBOutlet weak var commentTextView: UITextView!
  @IBOutlet weak var commentButton: UIButton!
  
  override func awakeFromNib() {
    super.awakeFromNib()
    // Initialization code
    
  }

  override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
  }
  
  func setPostData(postData: PostData) {
    self.postImageView.image = postData.image
    
    if postData.comments != nil {
      self.captionLabel.text = "\(postData.name!) : \(postData.caption!)" + "\(postData.comments!)"
    } else {
      self.captionLabel.text = "\(postData.name!) : \(postData.caption!)"
    }
    
    let likeNumber = postData.likes.count
    likeLabel.text = "\(likeNumber)"    
    
    let formatter = DateFormatter()
    formatter.locale = NSLocale(localeIdentifier: "ja_JP") as Locale!
    formatter.dateFormat = "yyyy-MM-dd HH:mm"
    
    let dateString:String = formatter.string(from: postData.date! as Date)
    self.dateLabel.text = dateString
    
    if postData.isLiked {
      let buttonImage = UIImage(named: "like_exist")
      self.likeButton.setImage(buttonImage, for: UIControlState.normal)
    } else {
      let buttonImage = UIImage(named: "like_none")
      self.likeButton.setImage(buttonImage, for: UIControlState.normal)
    }
  }
 

  
}
