//
//  SearchTableViewController.swift
//  Hackathon
//
//  Created by master on 7/23/15.
//  Copyright (c) 2015 ferologics. All rights reserved.
//

import UIKit
import Mixpanel

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

    let mixpanel = Mixpanel.sharedInstance()
    
    static func queryForTable(searchCriteria: SearchCriteria, onComplete: (PFQuery) -> Void)
    {
        var query: PFQuery?
        
        // MARK: friends
        if ( searchCriteria.category == .Friends )
        {
            // using parse cloud function ATM
            query = PFQuery(className: "Hackathon")
            
            if (searchCriteria.searchString != nil) // if searchstring exists create subquery
            {
                if let q = query { // there should always be a category before this happens so this is probably not needed
                    
                    var searchQuery = PFQuery(className: "Hackathon")
                    searchQuery.whereKey("name", matchesQuery: q) // create subquery
                    searchQuery.whereKey("name", matchesRegex: searchCriteria.searchString!, modifiers: "i") // make it match lowercase
                    onComplete(searchQuery)
                }
            }
            else { println("whoa") }
        }
        
        // MARK: curr loc or any other
        else
        {
            query = PFQuery(className: "Hackathon") // if in Current location or Global category -> set query source to "Hackathon" class
            if ( searchCriteria.category == .CurrentLocation )
            {
                saveAndReturnCurrentLocation({ (point) -> Void in
                    
                    //set the curr ent location query
                    query!.whereKey("geoPoint", nearGeoPoint: point, withinKilometers: searchCriteria.searchDistance)
                    
                    if (searchCriteria.searchString != nil) // if searchstring exists create subquery
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
                
            else // any other than current location
            {
                if (searchCriteria.searchString != nil) // if searchstring exists create subquery
                {
                    if let q = query { // there should always be a category before this happens so this is probably not needed
                        
                        var searchQuery = PFQuery(className: "Hackathon")
                        searchQuery.whereKey("name", matchesQuery: q) // create subquery
                        searchQuery.whereKey("name", matchesRegex: searchCriteria.searchString!, modifiers: "i") // make it match lowercase
                        onComplete(searchQuery)
                    }
                }
                    
                else { onComplete(query!) }
            }
        }
    }
    
// MARK: -
// MARK: supporting functions
    
    static func getHackathonsFromParse( searchCriteria: SearchCriteria, onComplete: ([Hackathon] -> Void) )
    {
        PFCloud.callFunctionInBackground("getFriendHackathons", withParameters: nil) { (hackathons, error) -> Void in
            if let hacks = hackathons as? [Hackathon] { onComplete(hacks) }
            else { println(error) }
        }
        
        if ( searchCriteria.searchString != nil ) // if searchstring exists create subquery
        {
            let query = PFQuery(className: "Watchlist") // only search within watchlist
            query.whereKey("name", matchesRegex: searchCriteria.searchString!, modifiers: "i") // make it match lowercase
            
            query.findObjectsInBackgroundWithBlock({ (objects, error) -> Void in
                if let hackathons = objects as? [Hackathon]
                {
                    onComplete(hackathons)
                }
            })
            
        }
    }
    
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
                
                Mixpanel.sharedInstanceWithToken(token)
                let mixpanel = Mixpanel.sharedInstance()
                mixpanel.track("error", properties:["category":"location"])
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












