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
    
    @NSManaged var id: String?
    @NSManaged var name: String?
    @NSManaged var descript: String?
    @NSManaged var start: NSDate?
    @NSManaged var end: NSDate?
    @NSManaged var capacity: String?
    @NSManaged var currency: String?
    @NSManaged var logo: String?
    @NSManaged var status: String?
    @NSManaged var url: String?
    @NSManaged var ticketClasses: PFObject?
    
//    static var query: PFQuery? {
//        didSet {
//            // whenever we assign a new query, cancel any previous requests
//            oldValue?.cancel()
//        }
//    }
    
    // MARK: instances
    // MARK: -
    
//    static func getHackathons(#className   :String,
//                               withCategory:Constants.Category,
//                               withFilters :[Filter.Filter]) -> [Hackathon]
//    {
//        return (self.initHackathonsFromQuery(
//                                query: self.getQuery(
//                                                    className    : className,
//                                                    withCategory : withCategory,
//                                                    withFilters  : withFilters
//                                                    )
//                                            )
//                )
//    }
//    
//    static func getQuery(#className   :String,
//                          withCategory:Constants.Category,
//                          withFilters :[Filter.Filter]) -> PFQuery
//    {
//        
//        let filterCount = withFilters.count
//        
//        if ( filterCount == 1 ) {
//            // perform query
//            //            query = PFQuery(className:className)
//            //            query.
//            
////            query = PFQuery.
//            
//        } else if ( filterCount == 2 ) {
//            
//            
//            
//            
//        } else if ( filterCount == 3 ) {
//            
//            
//            
//            
//        } else if ( filterCount == 4 ) {
//            
//            
//            
//            
//        }
//        
//        
//    }
    
    static func initHackathonsFromQuery(#query: PFQuery) -> [Hackathon] {
        
        var hackathons:[Hackathon]?
        
        return []
    }
    
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
