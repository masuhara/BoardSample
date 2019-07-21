//
//  Post.swift
//  BoardSample
//
//  Created by Masuhara on 2019/07/14.
//  Copyright © 2019 Ylab Inc. All rights reserved.
//

import UIKit
import NCMB

class Post {
    var objectId: String!
    var tagId: String!
    var text: String?
    var createDate: Date?
    var user: User?
    
    static func loadData(skip: Int32 = 0, completion: @escaping([Post]?, Error?) -> ()) {
        let query = NCMBQuery(className: "Post")
        query?.order(byDescending: "createDate")
        query?.limit = 50
        query?.skip = skip
        query?.includeKey("user")
        query?.findObjectsInBackground({ (result, error) in
            if let error = error {
                completion(nil, error)
            } else {
                if let postObjects = result as? [NCMBObject] {
                    var posts = [Post]()
                    for postObject in postObjects {
                        let post = Post()
                        post.objectId = postObject.objectId
                        post.text = postObject.object(forKey: "text") as? String
                        post.createDate = postObject.createDate
                        let userObject = postObject.object(forKey: "user") as? NCMBUser
                        let user = User()
                        user.objectId = userObject?.objectId
                        user.name = userObject?.object(forKey: "userId") as? String
                        user.imageURL =  userObject?.object(forKey: "imageURL") as? String
                        post.user = user
                        posts.append(post)
                    }
                    completion(posts, nil)
                } else {
                    completion(nil, nil)
                }
            }
        })
    }
    
    static func saveData(text: String, image: UIImage? = nil, completion: @escaping(Error?) -> ()) {
        
        let object = NCMBObject(className: "Post")
        
        if let currentUser = NCMBUser.current() {
            object?.setObject(currentUser, forKey: "user")
        } else {
            SegueManager.show(display: .login)
            return
        }
        
        object?.setObject(text, forKey: "text")
        
        if let image = image {
            Post.saveImage(image: image) { (path, error) in
                if let error = error {
                    completion(error)
                } else {
                    if let path = path {
                        object?.setObject("imageURL", forKey: path)
                        object?.saveInBackground({ (error) in
                            completion(error)
                        })
                    } else {
                        object?.saveInBackground({ (error) in
                            completion(error)
                        })
                    }
                }
            }
        }
        
        object?.saveInBackground({ (error) in
            completion(error)
        })
    }
    
    static func saveImage(image: UIImage, completion: @escaping(String?, Error?) -> ()) {
        guard let imageData = image.pngData() else {
            completion(nil, nil)
            return
        }
        
        let file = NCMBFile.file(with: imageData) as! NCMBFile
        file.saveInBackground({ (error) in
            if let error = error {
                completion(nil, error)
            } else {
                let path = "https://mbaas.api.nifcloud.com/2013-09-01/applications/xkwUXCbJWsbGex25/publicFiles/" + file.name
                completion(path, nil)
            }
        }) { (progress) in
            print(progress)
        }
    }
}
