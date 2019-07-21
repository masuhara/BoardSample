//
//  Tag.swift
//  BoardSample
//
//  Created by Masuhara on 2019/07/14.
//  Copyright © 2019 Ylab Inc. All rights reserved.
//

import UIKit
import NCMB

class Tag {
    var objectId: String!
    var text: String?
    var createDate: Date?
    var updateDate: Date?
    var user: User?
    
    static func loadData(skip: Int32 = 0, completion: @escaping([Tag]?, Error?) -> ()) {
        let query = NCMBQuery(className: "Tag")
        query?.order(byDescending: "createDate")
        query?.limit = 50
        query?.skip = skip
        query?.includeKey("user")
        query?.findObjectsInBackground({ (result, error) in
            if let error = error {
                completion(nil, error)
            } else {
                if let tagObjects = result as? [NCMBObject] {
                    var tags = [Tag]()
                    for tagObject in tagObjects {
                        let tag = Tag()
                        tag.objectId = tagObject.objectId
                        tag.text = tagObject.object(forKey: "text") as? String
                        tag.createDate = tagObject.createDate
                        tag.updateDate = tagObject.updateDate
                        let userObject = tagObject.object(forKey: "user") as? NCMBUser
                        let user = User()
                        user.objectId = userObject?.objectId
                        user.name = userObject?.object(forKey: "userId") as? String
                        user.imageURL =  userObject?.object(forKey: "imageURL") as? String
                        tag.user = user
                        tags.append(tag)
                    }
                    completion(tags, nil)
                } else {
                    completion(nil, nil)
                }
            }
        })
    }

    static func saveData(tag: String, completion: @escaping(Error?) -> ()) {
        let object = NCMBObject(className: "Tag")
        object?.setObject(tag, forKey: "text")
        object?.saveInBackground({ (error) in
            completion(error)
        })
    }
}
