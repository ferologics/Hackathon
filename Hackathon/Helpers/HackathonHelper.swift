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

enum Category
{
    case Global
    case CurrentLocation
    case Friends
}

class SearchCriteria
{
    var searchString:  String? = nil
    var searchDistance: Double = 50.0
    var category: Category = .CurrentLocation
}

class HackathonHelper
{

    static func queryForTable(searchCriteria: SearchCriteria, onComplete: (PFQuery) -> Void)
    {
        var query:PFQuery?
        
        if ( searchCriteria.category == .Friends )
        {
            var user = PFUser.currentUser()
            query = PFQuery(className: "Watchlist") // if in Friends category -> set query source to "Watchlist" class
            // get user ids for all friends
            var relation = user?.relationForKey("tracking")
            var relationQuery = relation?.query() // can also be further refined
            relationQuery?.whereKeyExists("objectId")
            
            //query for friends
            query?.whereKey("toUser", matchesQuery: relationQuery!)
            
            if (searchCriteria.searchString?.isEmpty == false) // if searchstring exists create subquery
            {
                if let q = query { // there should always be a category before this happens so this is probably not needed
                    
                    var searchQuery = PFQuery()
                    searchQuery.whereKey("name", matchesQuery: q) // create subquery
                    searchQuery.whereKey("name", matchesRegex: searchCriteria.searchString!, modifiers: "i") // make it match lowercase
                    onComplete(searchQuery)
                }
            }
            else { onComplete(query!) }
        }
        else
        {
            query = PFQuery(className: "Hackathon") // if in Current location or Global category -> set query source to "Hackathon" class
            if ( searchCriteria.category == .CurrentLocation )
            {
                saveAndReturnCurrentLocation({ (point) -> Void in
                    
                    //set the current location query
                    query!.whereKey("geoPoint", nearGeoPoint: point, withinKilometers: searchCriteria.searchDistance)
                    
                    if (searchCriteria.searchString?.isEmpty == false) // if searchstring exists create subquery
                    {
                        if let q = query { // there should always be a category before this happens so this is probably not needed
                            
                            var searchQuery = PFQuery(className: "Hackathon")
                            searchQuery.whereKey("name", matchesQuery: q) // create subquery
                            searchQuery.whereKey("name", matchesRegex: searchCriteria.searchString!, modifiers: "i") // make it match lowercase
                            onComplete(searchQuery)
                        }
                    }
                    else { onComplete(query!) }
                })
            }
            else
            { onComplete(query!) }
        }
    }
    
// MARK: -
// MARK: supporting functions
    
    static func getDistanceFromUser(geopoint: PFGeoPoint, complete: (String) -> Void ) {
        var distance:String?
        HackathonHelper.saveAndReturnCurrentLocation { (point) -> Void in
            
            distance = (round((point.distanceInKilometersTo(geopoint))*1000)/1000).description // round to 3 digits
            complete(distance!)
        }
    }
    
    static func utcToString(date: NSDate) -> String {
        var dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "d MMM' 'H:mm" // format date
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
            else {
                println(error)
            }// TODO setup error handler
        }
    }
    
    static func setHackathonCellLogoAsynch(hackathon: Hackathon, onComplete: (UIImage) -> Void)
    {
        
        if let url = NSURL(string: hackathon.logo!) // set hackathon logo
        {
            getDataFromUrl(url) { data in
                dispatch_async(dispatch_get_main_queue()) {
                    onComplete(UIImage(data: data!)!)
                }
            }
        }
    }
    
    static func getDataFromUrl(urL:NSURL, completion: ((data: NSData?) -> Void)) {
        NSURLSession.sharedSession().dataTaskWithURL(urL) { (data, response, error) in
            completion(data: data) // return callback data
            }.resume()
    }
    
}












