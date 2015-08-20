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
import Mixpanel

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
            Mixpanel.sharedInstanceWithToken(token)
            // if this is a Facebook login, fetch the username from Facebook
            FBSDKGraphRequest(graphPath: "me", parameters: ["fields":"id,name,email,friends,picture"]).startWithCompletionHandler {
                (connection: FBSDKGraphRequestConnection!, result: AnyObject?, error: NSError?) -> Void in
                if let error = error {
                    // Facebook Error? -> hand error to callback
                    ErrorHandling.defaultErrorHandler(error)
                    self.callback(nil, error)
                }
                
                let fbID = result?["id"] as? String
                let graphUrl = "/" + fbID!
                
                if let fbUsername = result?["name"] as? String {
                    // assign Facebook parameters to user - name, id, friendlist (more to come)
                    
                    let data = JSON(result!)
                    
                    user["fbID"]    = fbID
                    user["picture"] = "http://graph.facebook.com/" + fbID! + "/picture?width=300&height=300"
                    user.email      = data["email"].stringValue
                    user.username   = fbUsername // stored using swift native syntax
                    
                    // store User
                    user.saveInBackgroundWithBlock({ (success: Bool, error: NSError?) -> Void in
                        if (success) {
                            // updated user could be stored -> call success
                            self.callback(user, error)
                            
                            let mixpanel = Mixpanel.sharedInstance()
                            mixpanel.track("signup", properties: ["Service":"Facebook"])
                            
                        } else {
                            // updating user failed -> hand error to callback
                            ErrorHandling.defaultErrorHandler(error!) // TODO : IDK why is this throwing an error for me about email already existing
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
    
    static func updateFacebookData() // FIXME: implement check for profile picture change, email and everything else...
    {
        let fbID     = PFUser.currentUser()?.objectForKey("fbID") as! String
        let graphUrl = "/" + fbID
        
        FBSDKGraphRequest(graphPath: graphUrl, parameters: ["fields":"id,name,email,friends,picture"], HTTPMethod: "GET").startWithCompletionHandler { (connection: FBSDKGraphRequestConnection!, result: AnyObject?, error: NSError?) -> Void in
            if error == nil {
                
                let data    = JSON(result!)
                let friends = data["friends"]["data"]
                
                var toSave: [PFObject] = [PFObject]()
                
                for (key: String, subJson: JSON) in friends { // loop through the json based on keys to get friend ids and names
                    
                    // compare the ids to fb ids in the User class in parse
                    var id = subJson["id"].stringValue
                    
                    var user = PFUser.currentUser()
                    var userRelation = user?.relationForKey("friends")
                    var friendsQuery = userRelation?.query()
                    
                    friendsQuery?.whereKey("fbID", equalTo: id) // find out if there's already a friend with the id or if we have to store him
                    
                    friendsQuery?.countObjectsInBackgroundWithBlock({ (count, error) -> Void in
                        if (count == 0) // no friend with this id
                        {
                            var userQuery = PFQuery(className: "_User")
                            userQuery.whereKey("fbID", equalTo: id) // find the user to store
                            
                            userQuery.getFirstObjectInBackgroundWithBlock({ (object, error) -> Void in
                                if let friend = object
                                {
                                    // store the friend as relation to current user
                                    userRelation?.addObject(friend) //not sure wheter I can use this inside asynch method (does it still exist?)
                                    
                                    toSave.append(user!) //add the user with a new friend relation to the toSave array that will be used in the saveAll function
                                    
                                    PFObject.saveAllInBackground( toSave, block: { (success, error) -> Void in
                                        
                                        if (success == true) { println("saved - \(toSave)") } /* \(toSave) */
                                        else { println("\(toSave) - no new ones?") }
                                    })
                                }
                            })
                            
                            // all of this under asumption that if it shows a new ID it must mean that there is actually a user with that fb ID, otherwise facebook wouldn't give us the ID at all
                        }
                    })
                }
                
                println(toSave)
                
            } else {
                Mixpanel.sharedInstanceWithToken(token)

                let mixpanel = Mixpanel.sharedInstance()
                mixpanel.track("error", properties:["category":"fb users save"])

                ErrorHandling.defaultErrorHandler(error!)
                println("Error Getting Friends \(error)");
            }
        }
    }
    
    
}

extension ParseLoginHelper : PFSignUpViewControllerDelegate {
    
    func signUpViewController(signUpController: PFSignUpViewController, didSignUpUser user: PFUser) {
        self.callback(user, nil)
    }
}