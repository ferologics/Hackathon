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

class Hackathon : PFObject, PFSubclassing {
    
    @NSManaged var id:            String?
    @NSManaged var name:          String?
    @NSManaged var descript:      String?
    @NSManaged var start:         NSDate?
    @NSManaged var end:           NSDate?
    @NSManaged var capacity:      String?
    @NSManaged var currency:      String?
    @NSManaged var logo:          String?
    @NSManaged var status:        String?
    @NSManaged var url:           String?
    @NSManaged var ticketClasses: PFObject?// TODO add new properties for the location, city and such
    
    // TODO clean this code
    
    // static func initHackathonsFromQuery(#query: PFQuery) -> [Hackathon] {
        
    //     var hackathons:[Hackathon]?
        
    //     return []
    // }
    
    @NSManaged var user: PFUser?
               var hackathon: PFObject?
    
    override init () {
        super.init()
        
    }
}

extension Hackathon {
    
    static func parseClassName() -> String {
        return "Hackathon"
    }
    
    override class func initialize() {
        
        var onceToken : dispatch_once_t = 0;
        dispatch_once(&onceToken) {
            // inform Parse about this subclass
            self.registerSubclass()
            //            Hackathon.cellCache = NSCacheSwift<String, UIImage>()
        }
    }
}
