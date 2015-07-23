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

class Hackathon: PFObject, PFSubclassing {

    enum SearchType{
        case currentLocation
        case name
        case cityName
        case capacity
        case date
        case friends
        case price
    }
    

    @NSManaged var user: PFUser?
//    var photoUploadTask: UIBackgroundTaskIdentifier?
               var hackathon: PFObject?

//    static var cellCache: NSCacheSwift<String, UIImage>!
    
    static func parseClassName() -> String {
        return "Hackathon"
    }
    
    override init () {
        super.init()
    }
    
    override class func initialize() {
        
        var onceToken : dispatch_once_t = 0;
        dispatch_once(&onceToken) {
            // inform Parse about this subclass
            self.registerSubclass()
            
//            Hackathon.cellCache = NSCacheSwift<String, UIImage>()
        }
    }
    
    func fetchHackathons() {
        
        
        
    }
    
    func fetchByName( name: String) {
//        var query = PFQuery(className: "Hackathon")
//        query.whereKey(<#key: String#>, containedIn: <#[AnyObject]#>)
//        query.findObjectsInBackgroundWithBlock(<#block: PFArrayResultBlock?##([AnyObject]?, NSError?) -> Void#>)
    }
    
    func fetchByCapacity() {
        
    }
    
    func fetchByDate() {
        
    }
    
    func fetchByDistance() {
        
    }

    func fetchByFriends() {
        
    }
    
    func fetchByPrice() {
        
    }
}
