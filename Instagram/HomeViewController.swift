//
//  HomeViewController.swift
//  Instagram
//
//  Created by 杉山尋美 on 2017/09/21.
//  Copyright © 2017年 hiromi.sugiyama. All rights reserved.
//


import UIKit
import Firebase
import FirebaseAuth
import FirebaseDatabase

class HomeViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
  @IBOutlet weak var tableView: UITableView!
  
  // セルを取得してデータを設定する

  var postArray: [PostData] = []
//  var comment: String = ""
  
  // DatabaseのobserveEventの登録状態を表す
  var observing = false
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    tableView.delegate = self
    tableView.dataSource = self
    
    // テーブルセルのタップを無効にする
    // tableView.allowsSelection = false
    
    // 背景をタップしたらdismissKeyboardメソッドを呼ぶように設定する
    let tapGesture: UITapGestureRecognizer = UITapGestureRecognizer(target:self, action:#selector(dismissKeyboard))
    self.view.addGestureRecognizer(tapGesture)

    let nib = UINib(nibName: "PostTableViewCell", bundle: nil)
    tableView.register(nib, forCellReuseIdentifier: "Cell")
    tableView.rowHeight = UITableViewAutomaticDimension
    
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    print("DEBUG_PRINT: viewWillAppear")
    
    if Auth.auth().currentUser != nil {
      if self.observing == false {
        // 要素が追加されたらpostArrayに追加してTableViewを再表示する
        let postsRef = Database.database().reference().child(Const.PostPath)
        
        postsRef.observe(.childAdded, with: { snapshot in
          print("DEBUG_PRINT: .childAddedイベントが発生しました。")
          
          // PostDataクラスを生成して受け取ったデータを設定する
          if let uid = Auth.auth().currentUser?.uid {
            let postData = PostData(snapshot: snapshot, myId: uid)
            self.postArray.insert(postData, at: 0)
            
            // TableViewを再表示する
            self.tableView.reloadData()
          }
        })
        
        // 要素が変更されたら該当のデータをpostArrayから一度削除した後に新しいデータを追加してTableViewを再表示する
        postsRef.observe(.childChanged, with: { snapshot in
          print("DEBUG_PRINT: .childChangedイベントが発生しました。")
          
          if let uid = Auth.auth().currentUser?.uid {
            // PostDataクラスを生成して受け取ったデータを設定する
            let postData = PostData(snapshot: snapshot, myId: uid)
            
            // 保持している配列からidが同じものを探す
            var index: Int = 0
            for post in self.postArray {
              if post.id == postData.id {
                index = self.postArray.index(of: post)!
                break
              }
            }
            
            // 差し替えるため一度削除する
            self.postArray.remove(at: index)
            
            // 削除したところに更新済みのでデータを追加する
            self.postArray.insert(postData, at: index)
            
            // TableViewの現在表示されているセルを更新する
            self.tableView.reloadData()
          }
        })
        
        // DatabaseのobserveEventが上記コードにより登録されたため
        // trueとする
        observing = true
      }
    } else {
      if observing == true {
        // ログアウトを検出したら、一旦テーブルをクリアしてオブザーバーを削除する。
        // テーブルをクリアする
        postArray = []
        tableView.reloadData()
        // オブザーバーを削除する
        Database.database().reference().removeAllObservers()
        
        // DatabaseのobserveEventが上記コードにより解除されたため
        // falseとする
        observing = false
      }
    }
    
  }
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return postArray.count
  }
  
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    // セルを取得してデータを設定する
    let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath as IndexPath) as! PostTableViewCell
    cell.setPostData(postData: postArray[indexPath.row])

    // セル内の２つのボタンのアクションをソースコードで設定する
    cell.likeButton.addTarget(self, action:#selector(handleButton(sender:event:)), for:  UIControlEvents.touchUpInside)
    cell.commentButton.addTarget(self, action:#selector(commentButton(sender:event:)), for:  UIControlEvents.touchUpInside)
    return cell
  }
  
  func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
    // Auto Layoutを使ってセルの高さを動的に変更する
    return UITableViewAutomaticDimension
  }
  
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    // セルをタップされたら何もせずに選択状態を解除する
    tableView.deselectRow(at: indexPath as IndexPath, animated: true)
  }

  // セル内のコメントボタンがタップされた時に呼ばれるメソッド
  func commentButton(sender: UIButton, event:UIEvent) {
    print("DEBUG_PRINT: コメントボタンがタップされました。")
 
    // コメント記入者の表示名を取得
    let name = Auth.auth().currentUser?.displayName

    // タップされたセルのインデックスを求める
    let touch = event.allTouches?.first
    let point = touch!.location(in: self.tableView)
    let indexPath = tableView.indexPathForRow(at: point)
    
    // 配列からタップされたインデックスのデータを取り出す
    var commentStr: String
    let postData = postArray[indexPath!.row]

    // インデックスからセルを求め、そのセル上の commentTextView に書き込まれたコメントを取得する
    let cell = tableView.cellForRow(at: indexPath!) as! PostTableViewCell
    let comment = cell.commentTextView.text
    
    // Firebaseに保存するデータの準備
    if postData.comments != nil {
      commentStr = postData.comments! + "\n" + name! + " : " + comment!
    } else {
      commentStr = "\n" + name! + " : " + comment!
    }
    postData.comments = commentStr

    // 増えたcommentをFirebaseに保存する
    let postRef = Database.database().reference().child(Const.PostPath).child(postData.id!)
    let comments = ["comments": postData.comments ?? ""]
    postRef.updateChildValues(comments)

  }
  

  // セル内のいいねボタンがタップされた時に呼ばれるメソッド
  func handleButton(sender: UIButton, event:UIEvent) {
    print("DEBUG_PRINT: likeボタンがタップされました。")
    
    // タップされたセルのインデックスを求める
    let touch = event.allTouches?.first
    let point = touch!.location(in: self.tableView)
    let indexPath = tableView.indexPathForRow(at: point)
    
    // 配列からタップされたインデックスのデータを取り出す
    let postData = postArray[indexPath!.row]
    
    // Firebaseに保存するデータの準備
    if let uid = Auth.auth().currentUser?.uid {
      if postData.isLiked {
        // すでにいいねをしていた場合はいいねを解除するためIDを取り除く
        var index = -1
        for likeId in postData.likes {
          if likeId == uid {
            // 削除するためにインデックスを保持しておく
            index = postData.likes.index(of: likeId)!
            break
          }
        }
        postData.likes.remove(at: index)
      } else {
        postData.likes.append(uid)
      }
      
      // 増えたlikesをFirebaseに保存する
      let postRef = Database.database().reference().child(Const.PostPath).child(postData.id!)
      let likes = ["likes": postData.likes]
      postRef.updateChildValues(likes)
      
    }
  }

  func dismissKeyboard(){
    // キーボードを閉じる
    view.endEditing(true)
  }

}

