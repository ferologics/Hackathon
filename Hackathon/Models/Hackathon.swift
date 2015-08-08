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
{
    
    @NSManaged var uniqueID:                    String?
    @NSManaged var name:                        String?
    @NSManaged var descript:                    String?
    @NSManaged var city:                        String?
    @NSManaged var adres_1:                     String?
    @NSManaged var adres_2:                     String?
    @NSManaged var geoPoint:                    PFGeoPoint?
    @NSManaged var start:                       NSDate?
    @NSManaged var end:                         NSDate?
    @NSManaged var capacity:                    NSNumber?
    @NSManaged var currency:                    String?
    @NSManaged var logo:                        String?
    @NSManaged var status:                      String?
    @NSManaged var online:                      NSNumber?
    @NSManaged var url:                         String?
    @NSManaged var ticketClassesNames:          [String]?
    @NSManaged var ticketClassesCosts:          [String]?
    @NSManaged var ticketClassesFees:           [String]?
    @NSManaged var ticketClassesTaxes:          [String]?
    @NSManaged var ticketClassesOnSaleStatuses: [String]?
    @NSManaged var ticketClassesDescriptions:   [String]?
    @NSManaged var ticketClassesDonations:      [Bool]?
    @NSManaged var ticketClassesFree:           [Bool]?
    
    @NSManaged var user: PFUser?
    
    override init ()
    {
        super.init()
    }
    
}

extension Hackathon
{
    
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
