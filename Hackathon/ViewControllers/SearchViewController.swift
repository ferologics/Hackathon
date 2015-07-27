//
//  SearchViewController.swift
//  Hackathon
//
//  Created by master on 7/21/15.
//  Copyright (c) 2015 ferologics. All rights reserved.
//

import UIKit
import BubbleTransition
import QuartzCore

// TODO setup categories button, filter bar and search bar here
// TODO customize search bar to animate constrains and such... read mindmaps

class SearchViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UIViewControllerTransitioningDelegate, UISearchBarDelegate, UISearchDisplayDelegate {

    @IBOutlet weak var tableView:    UITableView!
    @IBOutlet weak var switchButton: UIButton!
    @IBOutlet weak var searchBar:    UISearchBar!

    
    var hackathons               = [Hackathon]()
    var filterContentForCategory = [Hackathon]()
    var criteria                 = SearchCriteria()

    override func viewDidLoad() {
        super.viewDidLoad()
        updateButton()
        updateSearchBar()
        // Do any additional setup after loading the view.
        
        criteria.category     = .CurrentLocation
        criteria.searchString = "Hack" // TODO text from searchbar
        criteria.primarySort  = Sort(column: "start", ascending: true) // TODO not setting this here at all but in IBAction button pressed or whatnot when filter is added
        // TODO increment i on each touch, based on that set color of the button and set the sort order to asc/desc

        let query = SearchTableViewController.queryForTable(searchCriteria: criteria)

        query.findObjectsInBackgroundWithBlock({ (results, error) -> Void in
            self.hackathons = results as! [Hackathon]
            self.tableView.reloadData()
        })

    }
    
    // date button tapped -> set filter to Date

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: -
    // MARK: delegate methods or what
    // TODO set this up as an extension

    func filterContentForSearchTextOrCategory(searchText: String, category: Category) {
      // Filter the array using the filter method
      self.filteredHackathons = self.hackathons.filter({( hackathon: Hackathon) -> Bool in

        let categoryMatch = (category == .CurrentLocation) || (searchCriteria.category == category)
        let stringMatch   = hackathon.name.rangeOfString(searchText)
        return (categoryMatch && (stringMatch != nil)) || categoryMatch //  either filter for search text and category or just category 
      })
    }

    // func filterContentForCategory(category: Category) {
    //     self.filteredHackathons = self.hackathons.filter({( hackathon: Hackathon) -> Bool in
    //     // let categoryMatch = (scope == .CurrentLocation) || (searchCriteria.category == scope)
        
    //     return /*categoryMatch &&*/ categoryMatch
    //   })
    // }

    func searchDisplayController(controller: UISearchDisplayController!, shouldReloadTableForSearchString searchString: String!) -> Bool { // TODO setup similar methods for categories through lgbutton
      self.filterContentForSearchText(searchString)
      return true
    }
 
    func searchDisplayController(controller: UISearchDisplayController!, shouldReloadTableForSearchScope searchOption: Int) -> Bool {
      self.filterContentForSearchText(self.searchDisplayController!.searchBar.text)
      return true
    }

    // MARK: - custom methods
    
    func updateButton() {
        switchButton.layer.cornerRadius = 22
        switchButton.backgroundColor    = secondaryColor
    }
    
    func updateSearchBar() {
        
    }
    
    func updateTableView() {
        tableView.backgroundColor = mainColor
        
    }
    
    // MARK: - Navigation

    let transition = BubbleTransition()
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let controller = segue.destinationViewController as? UIViewController {
            controller.transitioningDelegate  = self
            controller.modalPresentationStyle = .Custom
        }
    }
    
    // MARK: UIViewControllerTransitioningDelegate
    
    func animationControllerForPresentedController(presented: UIViewController, presentingController presenting: UIViewController, sourceController source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        transition.transitionMode = .Present
        transition.startingPoint  = switchButton.center
        transition.bubbleColor    = switchButton.backgroundColor!
        return transition
    }
    
    func animationControllerForDismissedController(dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        transition.transitionMode = .Dismiss
        transition.startingPoint  = switchButton.center
        transition.bubbleColor    = switchButton.backgroundColor!
        return transition
    }
}

extension SearchViewController
{
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // TODO filtered hackathons???
        return hackathons.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell      = tableView.dequeueReusableCellWithIdentifier("HackathonCell", forIndexPath: indexPath) as! UITableViewCell
        var hackathon = hackathons[indexPath.row]
        cell.configure(name: hackathon.name, ticketClasses: (hackathon.[ticketClassNames] as [String], [hackathon.[cost] as [Int]), capacity: hackathon.capacity as Int, date: hackathon.start as NSDate)
        return cell
    }
}


