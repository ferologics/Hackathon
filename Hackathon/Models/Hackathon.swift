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

class Hackathon : PFObject, PFSubclassing
{ // TODO change this to struct?
    
    @NSManaged var uniqueID:                    String?
    @NSManaged var name:                        String?
    @NSManaged var descript:                    String?
    @NSManaged var city:                        String?
    @NSManaged var adres_1:                     String?
    @NSManaged var adres_2:                     String?
    @NSManaged var latitude:                    NSNumber? // TODO convert these to int
    @NSManaged var longitude:                   NSNumber? // int
    @NSManaged var start:                       NSDate? // TODO create a UTC NSPredicate to NSDate or whatnot handler for start and end
    @NSManaged var end:                         NSDate?
    @NSManaged var capacity:                    NSNumber? // int
    @NSManaged var currency:                    String?
    @NSManaged var logo:                        String?
    @NSManaged var status:                      String?
    @NSManaged var online:                      NSNumber? // Bool
    @NSManaged var url:                         String?
    @NSManaged var ticketClassesNames:          [String]? // TODO fix this in cloudcode
    @NSManaged var ticketClassesCosts:          [Int]?
    @NSManaged var ticketClassesFees:           [Int]?
    @NSManaged var ticketClassesTaxes:          [Int]?
    @NSManaged var ticketClassesOnSaleStatuses: [String]?
    @NSManaged var ticketClassesDescriptions:   [String]?
    @NSManaged var ticketClassesDonations:      [Bool]?
    @NSManaged var ticketClassesFree:           [Bool]?
    
    @NSManaged var user: PFUser?
               var hackathon: PFObject?
    
    override init ()
    {
        super.init()
    }
}

extension Hackathon {
    
    static func parseClassName() -> String
    {
        return "Hackathon"
    }
    
    override class func initialize()
    {
        var onceToken : dispatch_once_t = 0;
        dispatch_once(&onceToken)
        {
            // inform Parse about this subclass
            self.registerSubclass()
            //            Hackathon.cellCache = NSCacheSwift<String, UIImage>()
        }
    }
}
