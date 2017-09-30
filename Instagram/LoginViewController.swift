//
//  LoginViewController.swift
//  Instagram
//
//  Created by 杉山尋美 on 2017/09/21.
//  Copyright © 2017年 hiromi.sugiyama. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import SVProgressHUD


class LoginViewController: UIViewController {

  @IBOutlet weak var mailAddressTextField: UITextField!
  
  @IBOutlet weak var passwordTextField: UITextField!
  
  @IBOutlet weak var displayNameTextField: UITextField!
  
  // ログインボタンをタップ
  @IBAction func handleLoginButton(_ sender: Any) {
  
    if let address = mailAddressTextField.text, let password = passwordTextField.text {
      
      // アドレスとパスワード名のいずれかでも入力されていない時は何もしない
      if address.characters.isEmpty || password.characters.isEmpty {
        return
      }

      // HUDで処理中を表示
      SVProgressHUD.show()

      Auth.auth().signIn(withEmail: address, password: password) { user, error in
        if let error = error {
          print("DEBUG_PRINT: " + error.localizedDescription)
          SVProgressHUD.showError(withStatus: "サインインに失敗しました。")
          return
        } else {
          print("DEBUG_PRINT: ログインに成功しました。")
          
          // HUDを消す
          SVProgressHUD.dismiss()
          
          // 画面を閉じてViewControllerに戻る
          self.dismiss(animated: true, completion: nil)
        }
      }

    }
  
  }
  
  // アカウント作成ボタンをタップ
  @IBAction func handleCreateAcountButton(_ sender: Any) {
    
    if let address = mailAddressTextField.text, let password = passwordTextField.text, let displayName = displayNameTextField.text {
      
      // アドレスとパスワードと表示名のいずれかでも入力されていない時は何もしない
      if address.characters.isEmpty || password.characters.isEmpty || displayName.characters.isEmpty {
        print("DEBUG_PRINT: 何かが空文字です。")
        return
      }
 
      // HUDで処理中を表示
      SVProgressHUD.show()

      
      // アドレスとパスワードでユーザー作成。ユーザー作成に成功すると、自動的にログインする
      Auth.auth().createUser(withEmail: address, password: password) { user, error in
        if let error = error {
          // エラーがあったら原因をprintして、returnすることで以降の処理を実行せずに処理を終了する
          print("DEBUG_PRINT: " + error.localizedDescription)
          SVProgressHUD.showError(withStatus: "ユーザー作成に失敗しました。")
          return
        }
        print("DEBUG_PRINT: ユーザー作成に成功しました。")
        
        // 表示名を設定する
        let user = Auth.auth().currentUser
        if let user = user {
          let changeRequest = user.createProfileChangeRequest()
          changeRequest.displayName = displayName
          changeRequest.commitChanges { error in
            if let error = error {
              SVProgressHUD.showError(withStatus: "ユーザー作成時にエラーが発生しました。")
              print("DEBUG_PRINT: " + error.localizedDescription)
            }
            print("DEBUG_PRINT: [displayName = \(String(describing: user.displayName))]の設定に成功しました。")
            
            // HUDを消す
            SVProgressHUD.dismiss()
            
            // 画面を閉じてViewControllerに戻る
            self.dismiss(animated: true, completion: nil)
          }
        } else {
          print("DEBUG_PRINT: displayNameの設定に失敗しました。")
        }
      }
    }
  }

  
  override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
