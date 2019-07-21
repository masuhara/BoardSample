//
//  TagViewController.swift
//  BoardSample
//
//  Created by Masuhara on 2019/07/14.
//  Copyright © 2019 Ylab Inc. All rights reserved.
//

import UIKit
import KafkaRefresh
import MBProgressHUD
import DZNEmptyDataSet

class TagViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate, DZNEmptyDataSetSource, DZNEmptyDataSetDelegate {
    
    @IBOutlet var tagTableView: UITableView!
    @IBOutlet var addTagButton: UIButton!
    
    var tags = [Tag]()

    override func viewDidLoad() {
        super.viewDidLoad()
        // ボタンの角を丸に
        addTagButton.layer.cornerRadius = 8.0
        addTagButton.layer.masksToBounds = true
        
        // ボーダー色
        addTagButton.layer.borderWidth = 1.0
        addTagButton.layer.borderColor = UIColor.red.cgColor
        
        // tagTableViewの設定
        tagTableView.dataSource = self
        tagTableView.delegate = self
        tagTableView.tableFooterView = UIView()
        
        // データがないときの表示
        tagTableView.emptyDataSetSource = self
        tagTableView.emptyDataSetDelegate = self
        
        // 引っ張って更新(上)
        tagTableView.bindHeadRefreshHandler({
            self.loadTags()
        }, themeColor: UIColor.lightGray, refreshStyle: .native)
        
        // 引っ張って更新(下)
        tagTableView.bindFootRefreshHandler({
            self.loadTags(isAdditional: true)
        }, themeColor: UIColor.lightGray, refreshStyle: .native)
        
        // カスタムセルの登録
        let nib = UINib(nibName: "TagTableViewCell", bundle: Bundle.main)
        tagTableView.register(nib, forCellReuseIdentifier: "TagTableViewCell")
        
        loadTags()
    }
    
    // 何個セルがあるか
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tags.count
    }
    
    // セルの内容
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TagTableViewCell") as! TagTableViewCell
        cell.tagLabel.text = tags[indexPath.row].text
        return cell
    }
    
    // データが空のときの表示設定
    func title(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString! {
        return NSAttributedString(string: "まだ投稿がありません")
    }
    
    func emptyDataSetShouldAllowScroll(_ scrollView: UIScrollView!) -> Bool {
        return true
    }

    @IBAction func plus() {
        let alert = UIAlertController(title: "タグ入力", message: "タグを入力してください", preferredStyle: .alert)
        alert.addTextField { (textField) in
            textField.delegate = self
            textField.placeholder = "ここにタグを入力"
        }
        let plusAction = UIAlertAction(title: "OK", style: .default) { (action) in
            alert.dismiss(animated: true, completion: nil)
            
            let textField = alert.textFields![0]
            
            if let text = textField.text {
                self.saveTag(text: text)
            } else {
                print("入力されていません")
            }
        }
        
        let cancelAction = UIAlertAction(title: "キャンセル", style: .cancel) { (action) in
            alert.dismiss(animated: true, completion: nil)
        }
        
        alert.addAction(plusAction)
        alert.addAction(cancelAction)
        self.present(alert, animated: true, completion: nil)
    }
    
    func saveTag(text: String) {
        let hud = MBProgressHUD.showAdded(to: self.view, animated: true)
        
        Tag.saveData(tag: text) { (error) in
            DispatchQueue.main.async {
                hud.hide(animated: true)
            }
            
            if let error = error {
                print(error.localizedDescription)
            } else {
                self.loadTags()
            }
        }
    }
    
    func loadTags(isAdditional: Bool = false) {
        var skip: Int32 = 0
        if isAdditional == true {
            skip = Int32(tags.count)
        }
        
        Tag.loadData(skip: skip) { (tags, error) in
            DispatchQueue.main.async {
                self.tagTableView.headRefreshControl.endRefreshing()
                self.tagTableView.footRefreshControl.endRefreshing()
            }
            
            if let error = error {
                print(error.localizedDescription)
            } else {
                if let tags = tags {
                    if isAdditional == true {
                        self.tags = self.tags + tags
                    } else {
                        self.tags = tags
                    }
                    self.tagTableView.reloadData()
                }
            }
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        self.performSegue(withIdentifier: "toBoard", sender: nil)
    }
}
