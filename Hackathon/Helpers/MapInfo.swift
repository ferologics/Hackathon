//
//  mapInfo.swift
//  Hackathon
//
//  Created by master on 8/7/15.
//  Copyright (c) 2015 ferologics. All rights reserved.
//

import Foundation
import MapKit
import AddressBook

class MapInfo: NSObject, MKAnnotation
{
    let title: String
    let locationName: String
    var address_2: String?
    let coordinate: CLLocationCoordinate2D
    
    init(title: String, locationName: String, address_2:String?, coordinate: PFGeoPoint)// locationName: String, address_2: String?, coordinate: PFGeoPoint)
    {
        self.title = title
        self.locationName = locationName
        self.coordinate = CLLocationCoordinate2D(latitude: coordinate.latitude, longitude: coordinate.longitude)
        self.address_2 = address_2! ?? ""
        
        super.init()
    }
    
    func mapItem() -> MKMapItem {
        let addressDictionary = [String(kABPersonAddressStreetKey): subtitle]
        let placemark = MKPlacemark(coordinate: coordinate, addressDictionary: addressDictionary)
        
        let mapItem = MKMapItem(placemark: placemark)
        mapItem.name = title
        
        return mapItem
    }
    
    var subtitle: String {
        return locationName
    }
}