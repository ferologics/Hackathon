
//
//  Watchlist.swift
//  Hackathon
//
//  Created by master on 8/5/15.
//  Copyright (c) 2015 ferologics. All rights reserved.
//

import Foundation

//
//  Hackathon.swift
//  Hackathon
//
//  Created by master on 7/21/15.
//  Copyright (c) 2015 ferologics. All rights reserved.
//

import UIKit
import Foundation
import ConvenienceKit
import Parse

class Watchlist : PFObject, PFSubclassing
{
    
    @NSManaged var toHackathon: PFObject?
    @NSManaged var toUser:      PFUser?
    
    override init ()
    {
        super.init()
    }
    
    func startTrackingHackathon(hackathon:Hackathon?, onComplete: (Bool)->Void )
    {
        
        if let hack = hackathon
        {
            // add relation of hackathon to user
            addRelationToUser(hack, onComplete: { (tracking) -> Void in
                onComplete(tracking)
            })
            
            // add pointers to hackathon and to user in Watchlist
            addToWatchlist(hack)
        }
    }
    
    func addRelationToUser(hack: Hackathon, onComplete: (Bool) -> Void )
    {
        let hackathonQuery = PFQuery(className: "Hackathon")
        hackathonQuery.whereKey("uniqueID", equalTo: hack.uniqueID!)
        hackathonQuery.getFirstObjectInBackgroundWithBlock({ (object, error) -> Void in
            
            if (error == nil) // tbt simon
            {
                let user             = PFUser.currentUser()
                let trackingRelation = user!.relationForKey("tracking")
                trackingRelation.addObject(object!)
                
                // save relation
                user?.saveInBackgroundWithBlock({ (success, error) -> Void in
                    onComplete(success) // return true
                })
            }
            else { println("already tracking biach") }
        })
    }
    
    func addToWatchlist(hack: Hackathon)
    {
        let user         = PFUser.currentUser()// declare curren user
        self.toHackathon = hack// get the hackathon
        self.toUser      = user// get the user
        
        // store it inside the watchlist
        self.saveInBackgroundWithBlock({ (success, error) -> Void in
            
            if (error == nil) { println("watchlist saved with user \(user?.description) and hackathon \(hack.name) ") }
            else { println("successfully saved")}
        })
    }
    
    func stopTrackingHackathon(hack: Hackathon, onComplete: (Bool) -> Void )
    {
        var user = PFUser.currentUser()

        // remove the relation
        let trackingRelation = user?.relationForKey("tracking")
        trackingRelation?.removeObject(hack)
        
        user?.saveInBackgroundWithBlock({ (success, error) -> Void in
            if (success == true)
            {
                let watchlistQuery = PFQuery(className: "Watchlist")
                watchlistQuery.whereKey("toHackathon", equalTo: hack)
                
                watchlistQuery.getFirstObjectInBackgroundWithBlock({ (object, error) -> Void in
                    
                    if let watchlistObject = object
                    {
                        watchlistObject.deleteInBackgroundWithBlock({ (success, error) -> Void in
                            if success { onComplete(success) }
                        })
                    }
                })
                
            }
            else { ErrorHandling.defaultErrorHandler(error!) }
        })
    }
    
    func isTrackingHackathon(hack: Hackathon, onComplete: (Bool) -> Void )
    {
        // query users relations for current hackathon id and determine wether he's tracking the event
        var user         = PFUser.currentUser()
        var userRelation = user?.relationForKey("tracking")
        var userQuery    = userRelation?.query()

        userQuery?.whereKey("objectId", containsString: hack.objectId)
        userQuery?.getFirstObjectInBackgroundWithBlock({ (object, error) -> Void in
            
            (object != nil) ? onComplete(true) : onComplete(false)
        })
    }
}
    
extension Watchlist
{
    
    static func parseClassName() -> String
    {
        return "Watchlist"
    }
    
    override class func initialize()
    {
        var onceToken : dispatch_once_t = 0
        dispatch_once(&onceToken)
            {
                self.registerSubclass()
        }
    }
}
