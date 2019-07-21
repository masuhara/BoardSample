//
//  User.swift
//  BoardSample
//
//  Created by Masuhara on 2019/07/14.
//  Copyright © 2019 Ylab Inc. All rights reserved.
//

import UIKit
import NCMB

class User {
    var objectId: String!
    var name: String?
    var imageURL: String?
    
    static func currentUser() -> User? {
        guard let currentUserObject = NCMBUser.current() else {
            SegueManager.show(display: .login)
            return nil
        }
        let user = User()
        user.objectId = currentUserObject.objectId
        user.name = currentUserObject.userName
        user.imageURL = currentUserObject.object(forKey: "imageURL") as? String
        return user
    }
    
    static func login(email: String, password: String, completion: @escaping(Error?) -> ()) {
        NCMBUser.logInWithMailAddress(inBackground: email, password: password) { (user, error) in
            completion(error)
        }
    }
    
    static func signUp(userName: String, mailAddress: String, password: String, completion: @escaping(Error?) -> ()) {
        let user = NCMBUser()
        user.userName = userName
        user.mailAddress = mailAddress
        user.password = password
        user.signUpInBackground { (error) in
            if let error = error  {
                completion(error)
            } else {
                user.acl.isPublicReadAccess()
                user.acl.isWriteAccess(forUserId: user.objectId)
                user.saveInBackground({ (error) in
                    completion(error)
                })
            }
        }
    }
    
    static func loadUserInfo(objectId: String, completion: @escaping(User?, Error?) -> ()) {
        let query = NCMBUser.query()
        query?.getObjectInBackground(withId: objectId, block: { (object, error) in
            if let userObject = object as? NCMBUser {
                let user = User()
                user.objectId = userObject.objectId
                user.name = userObject.object(forKey: "userName") as? String
                user.imageURL = userObject.object(forKey: "imageURL") as? String
                completion(user, error)
            } else {
                completion(nil, error)
            }
        })
    }
}
