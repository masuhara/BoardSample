//
//  UserViewController.swift
//  BoardSample
//
//  Created by Masuhara on 2019/07/14.
//  Copyright © 2019 Ylab Inc. All rights reserved.
//

import UIKit
import Kingfisher
import KafkaRefresh

class UserViewController: UIViewController, UITableViewDataSource {
    
    var user: User!
    
    @IBOutlet var userTableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()
        user = User.currentUser()
        
        userTableView.rowHeight = UITableView.automaticDimension
        userTableView.estimatedRowHeight = 44.0
        
        userTableView.tableFooterView = UIView()
        userTableView.dataSource = self
        
        let nib = UINib(nibName: "UserTableViewCell", bundle: Bundle.main)
        userTableView.register(nib, forCellReuseIdentifier: "UserTableViewCell")
        
        userTableView.bindHeadRefreshHandler({
            self.loadUserInfo()
        }, themeColor: UIColor.lightGray, refreshStyle: .native)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "UserTableViewCell") as! UserTableViewCell
        if let imageURL = user.imageURL {
            cell.userImageView.kf.setImage(with: URL(string: imageURL))
        } else {
            cell.userImageView.image = nil
            cell.userImageView.backgroundColor = UIColor.lightGray
        }
        cell.userNameLabel.text = user.name
        return cell
    }
    
    func loadUserInfo() {
        User.loadUserInfo(objectId: user.objectId) { (user, error) in
            DispatchQueue.main.async {
                self.userTableView.headRefreshControl.endRefreshing()
            }
            if let error = error {
                print(error.localizedDescription)
            } else {
                if let user = user {
                    self.user = user
                    self.userTableView.reloadData()
                }
            }
        }
    }
}
