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


class SearchViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UIViewControllerTransitioningDelegate, UISearchBarDelegate, UISearchDisplayDelegate {

    @IBOutlet weak var tableView:    UITableView!
    @IBOutlet weak var switchButton: UIButton!
    @IBOutlet weak var searchBar:    UISearchBar!

    
    var hackathons = [Hackathon]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateButton()
        updateSearchBar()
        // Do any additional setup after loading the view.
        
        
        
        var criteria          = SearchCriteria()
        criteria.searchString = "Hack"
        criteria.primarySort  = Sort(column: "start", ascending: true)
        
        let query = SearchTableViewController.queryForTable("Hackathon", searchCriteria: criteria)

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
    // TODO change this as a extension

    func filterContentForSearchText(searchText: String) {
      // Filter the array using the filter method
      self.filteredCandies = self.hackathons.filter({( hackathon: Hackathon) -> Bool in
        let name = (scope == "All") || (candy.category == scope)
        let stringMatch = candy.name.rangeOfString(searchText)
        return categoryMatch && (stringMatch != nil)
      })
    }

    func searchDisplayController(controller: UISearchDisplayController!, shouldReloadTableForSearchString searchString: String!) -> Bool {
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
            controller.transitioningDelegate = self
            controller.modalPresentationStyle = .Custom
        }
    }
    
    // MARK: UIViewControllerTransitioningDelegate
    
    func animationControllerForPresentedController(presented: UIViewController, presentingController presenting: UIViewController, sourceController source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        transition.transitionMode = .Present
        transition.startingPoint = switchButton.center
        transition.bubbleColor = switchButton.backgroundColor!
        return transition
    }
    
    func animationControllerForDismissedController(dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        transition.transitionMode = .Dismiss
        transition.startingPoint = switchButton.center
        transition.bubbleColor = switchButton.backgroundColor!
        return transition
    }
}

extension SearchViewController
{
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return hackathons.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("HackathonCell", forIndexPath: indexPath) as! UITableViewCell
        var hackathon = hackathons[indexPath.row]
        cell.configure(name: hackathon.name, ticketClasses: (hackathon.[ticketClassNames] as [String], [hackathon.[cost] as [Int]), capacity: hackathon.capacity as Int, date: hackathon.start as NSDate)
        return cell
    }
}


