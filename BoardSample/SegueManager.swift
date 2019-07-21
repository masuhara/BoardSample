//
//  SegueManager.swift
//  BoardSample
//
//  Created by Masuhara on 2019/07/18.
//  Copyright © 2019 Ylab Inc. All rights reserved.
//

import UIKit

struct SegueManager {
    enum Display {
        case login
        case main
    }
    
    static func show(display: Display) {
        // アプリ全体のウィンドウを取得
        let appDelegate = UIApplication.shared.delegate
        guard let keyWindow = appDelegate?.window else { return }
        
        // 引数で選ばれた画面によって遷移
        switch display {
        case .login:
            // ログイン画面のStoryboardを取得してウィンドウを差し替え
            let storyboard = UIStoryboard(name: "Login", bundle: Bundle.main)
            let loginViewController = storyboard.instantiateInitialViewController() as! UINavigationController
            keyWindow?.rootViewController = loginViewController
        case .main:
            // MainのStoryboardを取得してウィンドウを差し替え
            let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
            let rootTabBarController = storyboard.instantiateInitialViewController() as! RootTabBarController
            keyWindow?.rootViewController = rootTabBarController
        }
    }
}
