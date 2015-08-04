//
//  ParseLoginHelper.swift
//  Makestagram
//
//  Created by Benjamin Encz on 4/15/15.
//  Copyright (c) 2015 Make School. All rights reserved.
//

import Foundation
import FBSDKCoreKit
import Parse
import ParseUI
import SwiftyJSON

typealias ParseLoginHelperCallback = (PFUser?, NSError?) -> Void

/**
This class implements the 'PFLogInViewControllerDelegate' protocol. After a successfull login
it will call the callback function and provide a 'PFUser' object.
*/
class ParseLoginHelper : NSObject, NSObjectProtocol {
    static let errorDomain                          = "com.makeschool.parseloginhelpererrordomain"
    static let usernameNotFoundErrorCode            = 1
    static let usernameNotFoundLocalizedDescription = "Could not retrieve Facebook username"
    
    let callback: ParseLoginHelperCallback
    
    init(callback: ParseLoginHelperCallback) {
        self.callback = callback
    }
}

extension ParseLoginHelper : PFLogInViewControllerDelegate {
    
    
    func logInViewController(logInController: PFLogInViewController, didLogInUser user: PFUser) {
        // Determine if this is a Facebook login
        let isFacebookLogin = FBSDKAccessToken.currentAccessToken() != nil
        
        if !isFacebookLogin {
            // Plain parse login, we can return user immediately
            self.callback(user, nil)
        } else {
            // if this is a Facebook login, fetch the username from Facebook
            FBSDKGraphRequest(graphPath: "me", parameters: nil).startWithCompletionHandler {
                (connection: FBSDKGraphRequestConnection!, result: AnyObject?, error: NSError?) -> Void in
                if let error = error {
                    // Facebook Error? -> hand error to callback
                    ErrorHandling.defaultErrorHandler(error)
                    self.callback(nil, error)
                }
                
                println(result)
                
                let fbID = result?["id"] as? String
                let graphUrl = "/" + fbID!
                
                FBSDKGraphRequest(graphPath: graphUrl, parameters: ["fields":"id,name,email,friends,picture"], HTTPMethod: "GET").startWithCompletionHandler { (connection: FBSDKGraphRequestConnection!, result: AnyObject?, error: NSError?) -> Void in
                    if error == nil {
                        
                    } else {
                        ErrorHandling.defaultErrorHandler(error!)
                    }
                }
                
                if let fbUsername = result?["name"] as? String {
                    // assign Facebook parameters to user - name, id, friendlist
                    
                    let data = JSON(result!)
                    
                    user["fbID"]    = fbID
                    user["picture"] = data["picture"]["data"]["url"].stringValue ?? "https://myspace.com/common/images/user.png" // stored using swifyJSON
                    user.email      = data["email"].stringValue
                    user.username   = fbUsername// stored using swift native syntax
                    
                    // store PFUser
                    user.saveInBackgroundWithBlock({ (success: Bool, error: NSError?) -> Void in
                        if (success) {
                            // updated username could be stored -> call success
                            self.callback(user, error)
                        } else {
                            // updating username failed -> hand error to callback
                            ErrorHandling.defaultErrorHandler(error!)
                            self.callback(nil, error)
                        }
                    })
                } else {
                    // cannot retrieve username? -> create error and hand it to callback
                    let userInfo        = [NSLocalizedDescriptionKey : ParseLoginHelper.usernameNotFoundLocalizedDescription]
                    let noUsernameError = NSError(
                        domain:   ParseLoginHelper.errorDomain,
                        code:     ParseLoginHelper.usernameNotFoundErrorCode,
                        userInfo: userInfo
                    )
                    ErrorHandling.defaultErrorHandler(error!)
                    self.callback(nil, error)
                }
            }
        }
    }
}

extension ParseLoginHelper : PFSignUpViewControllerDelegate {
    
    func signUpViewController(signUpController: PFSignUpViewController, didSignUpUser user: PFUser) {
        self.callback(user, nil)
    }
}