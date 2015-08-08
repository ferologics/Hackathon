//
//  mapInfo.swift
//  Hackathon
//
//  Created by master on 8/7/15.
//  Copyright (c) 2015 ferologics. All rights reserved.
//

import Foundation
import MapKit

class MapInfo: NSObject, MKAnnotation
{
    let title: String
    let locationName: String
    let address_2: String
    let coordinate: CLLocationCoordinate2D
    
    init(title: String, locationName: String, address_2: String?, coordinate: CLLocationCoordinate2D)
    {
        self.title = title
        self.locationName = locationName
        self.coordinate = coordinate
        self.address_2 = address_2!
        
        super.init()
    }
    
    var subtitle: String {
        return locationName
    }
}