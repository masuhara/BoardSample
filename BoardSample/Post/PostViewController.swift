//
//  PostViewController.swift
//  BoardSample
//
//  Created by Masuhara on 2019/07/14.
//  Copyright © 2019 Ylab Inc. All rights reserved.
//

import UIKit
import KafkaRefresh

class PostViewController: UIViewController, UITableViewDataSource {
    
    @IBOutlet var postTableView: UITableView!
    @IBOutlet var postButton: UIButton! {
        didSet {
            postButton.layer.cornerRadius = postButton.bounds.width / 2.0
            postButton.layer.masksToBounds = true
        }
    }
    
    var posts = [Post]()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // TableViewの設定
        postTableView.dataSource = self
        postTableView.tableFooterView = UIView()
        postTableView.rowHeight = UITableView.automaticDimension
        postTableView.estimatedRowHeight = 44.0
        
        // 引っ張って更新(上)
        postTableView.bindHeadRefreshHandler({
            self.loadPosts()
        }, themeColor: UIColor.lightGray, refreshStyle: .native)
        
        // 引っ張って更新(下)
        postTableView.bindFootRefreshHandler({
            self.loadPosts(isAdditional: true)
        }, themeColor: UIColor.lightGray, refreshStyle: .native)
        
        let nib = UINib(nibName: "PostTableViewCell", bundle: Bundle.main)
        postTableView.register(nib, forCellReuseIdentifier: "PostTableViewCell")
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return posts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PostTableViewCell") as! PostTableViewCell
        let post = posts[indexPath.row]
        cell.textView.text = post.text
        cell.userNameLabel.text = post.user?.name
        return cell
    }

    func loadPosts(isAdditional: Bool = false) {
        var skip: Int32 = 0
        if isAdditional == true {
            skip = Int32(posts.count)
        }
        
        Post.loadData(skip: skip) { (posts, error) in
            DispatchQueue.main.async {
                self.postTableView.headRefreshControl.endRefreshing()
                self.postTableView.footRefreshControl.endRefreshing()
            }
            
            if let error = error {
                print(error.localizedDescription)
            } else {
                if let posts = posts {
                    if isAdditional == true {
                        self.posts = self.posts + posts
                    } else {
                        self.posts = posts
                    }
                }
            }
        }
    }
    
    @IBAction func savePost() {
        
    }

}
