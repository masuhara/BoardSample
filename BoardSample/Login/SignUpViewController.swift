//
//  SignUpViewController.swift
//  BoardSample
//
//  Created by Masuhara on 2019/07/18.
//  Copyright © 2019 Ylab Inc. All rights reserved.
//

import UIKit
import MBProgressHUD

class SignUpViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet var userNameTextField: UITextField!
    @IBOutlet var mailAddressTextField: UITextField!
    @IBOutlet var passwordTextField: UITextField!

    override func viewDidLoad() {
        super.viewDidLoad()

        userNameTextField.delegate = self
        mailAddressTextField.delegate = self
        passwordTextField.delegate = self
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func validatePassword(password: String?) -> Bool {
        if let password = password {
            if password.count > 8 {
                return true
            } else {
                return false
            }
        } else {
            return false
        }
    }
    
    @IBAction func signUp() {
        guard let userName = userNameTextField.text else { return }
        guard let mailAddress = mailAddressTextField.text else { return }
        guard let password = passwordTextField.text else { return }
        
        let isValidPassword = validatePassword(password: password)
        if isValidPassword == false {
            print("パスワードが短すぎます")
            return
        }
        
        let hud = MBProgressHUD.showAdded(to: self.view, animated: true)
        User.signUp(userName: userName, mailAddress: mailAddress, password: password) { (error) in
            hud.hide(animated: true)
            
            if let error = error {
                print(error.localizedDescription)
            } else {
                let alert = UIAlertController(title: "登録完了", message: "ログイン画面に戻ります。登録したメールアドレスとパスワードでログインしてください。", preferredStyle: .alert)
                let okAction = UIAlertAction(title: "OK", style: .default, handler: { (action) in
                    alert.dismiss(animated: true, completion: nil)
                    self.navigationController?.popViewController(animated: true)
                })
                alert.addAction(okAction)
                self.present(alert, animated: true, completion: nil)
            }
        }
    }
}
