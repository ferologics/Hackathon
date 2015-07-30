//
//  SearchTableViewController.swift
//  Hackathon
//
//  Created by master on 7/23/15.
//  Copyright (c) 2015 ferologics. All rights reserved.
//

import UIKit

public var currentLocation:PFGeoPoint?
public var distanceDesired:Double?

struct Constants { // TODO start using this instead of the strings.
    static let ClassHackathon = "Hackathon"
    static let ClassWatchList = "Watchlist"
}

enum State
{
    case Ascending
    case Descending
    case Off
}

struct Sort
{
    var state: State = .Off
    var isPrimary: Bool?
}

enum Category
{
    case Global
    case CurrentLocation
//    case City
    case Friends
}

class SearchCriteria
{
    var searchString:  String?
    var cityString:    String?
    var searchDistance: Double = 50.0
    var category: Category = .CurrentLocation
    var sorted:        Bool?
    var primarySort:   Sort?
    var secondarySort: Sort?
//    var tertiarySort:  Sort?
}

class HackathonHelper
{

    static func queryForTable(searchCriteria: SearchCriteria) -> PFQuery // TODO fix sorting
    {
        var query:PFQuery?
        
        if ( searchCriteria.category == .Friends )
        {
            query = PFQuery(className: "Watchlist")
        }
        else
        {
            query = PFQuery(className: "Hackathon")
            if ( searchCriteria.category == .CurrentLocation )
            {
                saveAndReturnCurrentLocation({ (point) -> Void in
                    query!.whereKey("geoPoint", nearGeoPoint: point, withinKilometers: searchCriteria.searchDistance)
                }) // get current location and wait for the callback
            }
        }

        if let string = searchCriteria.searchString
        {
            if let q = query {
                
                var searchQuery = PFQuery()
                searchQuery.whereKey("name", matchesKey: "name", inQuery: q)
                searchQuery.whereKeyExists(string)
            }
        }
        
        if searchCriteria.primarySort != nil // Date sort
        {
            
            if searchCriteria.primarySort!.state == .Ascending
            {
                if (searchCriteria.primarySort?.isPrimary == true) { query!.orderByAscending("start") }
                else { query!.addAscendingOrder("start") }
            }
            if searchCriteria.primarySort!.state == .Descending
            {
                if (searchCriteria.primarySort?.isPrimary == true) { query!.orderByDescending("start") }
                else { query!.addDescendingOrder("start") }
            }
        }
        
        if searchCriteria.secondarySort != nil // Capacity sort
        {
            if searchCriteria.secondarySort!.state == .Ascending
            {
                if (searchCriteria.secondarySort?.isPrimary == true) { query!.orderByAscending("capacity") }
                else { query!.addAscendingOrder("capacity") }
            }
            if searchCriteria.secondarySort!.state == .Descending
            {
                if (searchCriteria.secondarySort?.isPrimary == true) { query!.orderByDescending("capacity") }
                else { query!.addDescendingOrder("capacity") }
            }
        }
        
        return query!
    }
    
// MARK: -
// MARK: supporting functions
    
    static func utcToString(date: NSDate) -> String {
        var dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSz" // format date
                                 //"yyyy-MM-dd'T'HH:mm:ss'Z'" maybe?
        var dateString = dateFormatter.stringFromDate(date)
        
        return dateString
    }
    
    static func saveAndReturnCurrentLocation(onCompletion: (point: PFGeoPoint) -> Void)
    {
        PFGeoPoint.geoPointForCurrentLocationInBackground
        {
            (geoPoint: PFGeoPoint?, error: NSError?) -> Void in
            if error == nil
            {
                let point = geoPoint!
                // do something with the new geoPoint
                PFUser.currentUser()!.setValue(geoPoint, forKey: "location")
                PFUser.currentUser()!.saveInBackground()
                
                onCompletion(point: point) // callback
            }
            else { println(error) }// TODO setup error handler
        }
    }
}












