//
//  SearchTableViewController.swift
//  Hackathon
//
//  Created by master on 7/23/15.
//  Copyright (c) 2015 ferologics. All rights reserved.
//

import UIKit

struct Constants {
    static let ClassHackathon = "Hackathon"
    static let ClassWatchList = "Watchlist"
    
}

struct Sort {
    var column: String?
    var ascending = false
    
    init(column: String, ascending: Bool) {
        self.column    = column
        self.ascending = ascending
    }
}

enum Category {
    case Global
    case CurrentLocation
    case City
    case Friends
}

class SearchCriteria {
    var searchString:  String?
    var cityString:    String?
    var category:      Category?
    var primarySort:   Sort?
    var secondarySort: Sort?
    var tertiarySort:  Sort?
}

class HackathonHelper {
    
    var hackathons = [Hackathon]()
/*

if in Category --->

friends -> searchCriteria.category = .Friends
        -> let query = PFQuery(className: "Watchlist")
        -> filter query for hackathons involving just your friends
        -> present in table view cell

currentLocation -> searchCriteria.category = .CurrentLocation
                -> let query = PFQuery(className: "Hackathon")
                -> get the city from users current location and compare with the events city
                -> query.whereKey("city", containsString: USERS_CURRENT_CITY)
                -> 

city -> searchCriteria.category = .City
     -> let query = PFQuery(className: "Hackathon")
     -> prompt user with another tableviewcell with search and constrain them to use only cities inside the Parse database
     -> set searchCriteria.cityString to current sity


*/

    static func queryForTable(searchCriteria: SearchCriteria) -> PFQuery
    {
        var query:PFQuery?
        
        if searchCriteria.category == .Friends
        {
            query = PFQuery(className: "Watchlist")
        }
        else
        {
            query = PFQuery(className: "Hackathon")
            println("been here")
            if ( ( searchCriteria.category == .CurrentLocation ) || ( searchCriteria.category == .City ) )
            {
                // TODO pass in the users current city before
                query!.whereKey("city", containsString: searchCriteria.cityString)
                            println("been here232")
            }
        }

        if searchCriteria.searchString != nil
        {
            query!.whereKey("name", containsString: searchCriteria.searchString)
        }
        
        if searchCriteria.primarySort != nil
        {
            if searchCriteria.primarySort!.ascending
            {
                query!.orderByAscending(searchCriteria.primarySort!.column!)
            }
            else
            {
                query!.orderByDescending(searchCriteria.primarySort!.column!) // TODO setup BUTTONS so that the 1st touch sets this to true -> orderByAscending first, then orderByDescending
            }
        }
        
        if searchCriteria.secondarySort != nil
        {
            if searchCriteria.secondarySort!.ascending
            {
                query!.addAscendingOrder(searchCriteria.secondarySort!.column!)
            }
            else
            {
                query!.addDescendingOrder(searchCriteria.secondarySort!.column!)
            }
        }

        if searchCriteria.tertiarySort != nil
        {
            if searchCriteria.tertiarySort!.ascending
            {
                query!.addAscendingOrder(searchCriteria.tertiarySort!.column!)
            }
            else
            {
                query!.addDescendingOrder(searchCriteria.tertiarySort!.column!)
            }
        }
        return query!
    }
    
    

}
