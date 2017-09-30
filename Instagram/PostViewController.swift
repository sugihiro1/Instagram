//
//  PostViewController.swift
//  Instagram
//
//  Created by 杉山尋美 on 2017/09/21.
//  Copyright © 2017年 hiromi.sugiyama. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase
import SVProgressHUD


class PostViewController: UIViewController {

  var image: UIImage!
  
  @IBOutlet weak var textField: UITextField!
  
  @IBOutlet weak var imageView: UIImageView!
  
  // 投稿ボタンをタップしたときに呼ばれるメソッド
  @IBAction func handlePostButton(_ sender: Any) {

    // ImageViewから画像を取得する
    let imageData = UIImageJPEGRepresentation(imageView.image!, 0.5)
    let imageString = imageData!.base64EncodedString(options: .lineLength64Characters)
    
    // postDataに必要な情報を取得しておく
    let time = NSDate.timeIntervalSinceReferenceDate
    let name = Auth.auth().currentUser?.displayName
    
    // 辞書を作成してFirebaseに保存する
    let postRef = Database.database().reference().child(Const.PostPath)
    let postData = ["caption": textField.text!, "image": imageString, "time": String(time), "name": name!]
    postRef.childByAutoId().setValue(postData)
    
    // HUDで投稿完了を表示する
    SVProgressHUD.showSuccess(withStatus: "投稿しました")
    
    // 全てのモーダルを閉じる
    UIApplication.shared.keyWindow?.rootViewController?.dismiss(animated: true, completion: nil)
  
  }
  
  // キャンセルボタンをタップ
  @IBAction func handleCnacelButton(_ sender: Any) {
    // 画面を閉じる
    dismiss(animated: true, completion: nil)

  }
  
  override func viewDidLoad() {
        super.viewDidLoad()
    
    // 受け取った画像をImageViewに設定する
    imageView.image = image

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

  
}
