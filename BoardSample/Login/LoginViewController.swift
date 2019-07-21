//
//  LoginViewController.swift
//  BoardSample
//
//  Created by Masuhara on 2019/07/18.
//  Copyright © 2019 Ylab Inc. All rights reserved.
//

import UIKit
import MBProgressHUD

class LoginViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet var mailAddressTextField: UITextField!
    @IBOutlet var passwordTextField: UITextField!

    override func viewDidLoad() {
        super.viewDidLoad()
        mailAddressTextField.delegate = self
        passwordTextField.delegate = self
    }

    @IBAction func login() {
        guard let mailAddress = mailAddressTextField.text else { return }
        guard let password = passwordTextField.text else { return }
        
        let hud = MBProgressHUD.showAdded(to: self.view, animated: true)
        User.login(email: mailAddress, password: password) { (error) in
            hud.hide(animated: true)
            if let error = error {
                print(error.localizedDescription)
            } else {
                SegueManager.show(display: .main)
            }
        }
    }

}
