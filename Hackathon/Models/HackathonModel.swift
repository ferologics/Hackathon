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

class HackathonModel: PFObject, PFSubclassing {
    
    var query: PFQuery? {
        didSet {
            // whenever we assign a new query, cancel any previous requests
            oldValue?.cancel()
        }
    }
    
    // MARK: instances
    // MARK: -
    
    static func getHackathons(#className: String, category: SearchTableViewController.Category, withFilters:[SearchTableViewController.Filter]) -> Hackathon
    {
        

        let filterCount = withFilters.count
        
        if ( filterCount == 1 ) {
            // perform query
//            query = PFQuery(className:className)
//            query.
    
        } else if ( filterCount == 2 ) {
            
            
            
            
        } else if ( filterCount == 3 ) {
            
            
            
            
        } else if ( filterCount == 4 ) {
            
            
            
            
        }
    }
    
    @NSManaged var user: PFUser?
               var hackathon: PFObject?
    
    override init () {
        super.init()
        
    }
}

extension HackathonModel {
    
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
