//
//  SearchTableViewController.swift
//  Hackathon
//
//  Created by master on 7/23/15.
//  Copyright (c) 2015 ferologics. All rights reserved.
//

import UIKit

struct Sort {
    var column: String?
    var ascending = false
    
    init(column: String, ascending: Bool) {
        self.column = column
        self.ascending = ascending
    }
}

struct SearchCriteria {
    var searchString: String?
    var primarySort: Sort?
    var secondarySort: Sort?
}

class SearchTableViewController: UITableViewController {
    
    var hackathons = [Hackathon]()
    
    enum ClassName {
        case Hackathon
        case WatchList
    }

    static func queryForTable(tableName: String, searchCriteria: SearchCriteria) -> PFQuery {
        
        let query = PFQuery(className: tableName)
        
        if searchCriteria.searchString != nil
        {
            query.whereKey("name", containsString: searchCriteria.searchString)
        }
        
        if searchCriteria.primarySort != nil
        {
            if searchCriteria.primarySort!.ascending
            {
                query.orderByAscending(searchCriteria.primarySort!.column!)
            }
            else
            {
                query.orderByDescending(searchCriteria.primarySort!.column!)
            }
        }
        
        if searchCriteria.secondarySort != nil
        {
            if searchCriteria.secondarySort!.ascending
            {
                query.addAscendingOrder(searchCriteria.secondarySort!.column!)
            }
            else
            {
                query.addDescendingOrder(searchCriteria.secondarySort!.column!)
            }
        }

        return query
    }

//    var filter = Filter.filters
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // TODO if previous search available, load that
//        filter?.append(.None)
//        HackathonModel.getHackathons(className: Constants.ClassHackathon, withCategory: Constants.Category.CurrentLocation, withFilters: filter!)
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Potentially incomplete method implementation.
        // Return the number of sections.
        return 0
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete method implementation.
        // Return the number of rows in the section.
        return 0
    }

    /*
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("reuseIdentifier", forIndexPath: indexPath) as! UITableViewCell

        // Configure the cell...

        return cell
    }
    */

    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return NO if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return NO if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */

}
