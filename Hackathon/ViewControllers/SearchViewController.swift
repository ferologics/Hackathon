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
import LGPlusButtonsView

// TODO setup categories button, filter bar and search bar here
// TODO customize search bar to animate constrains and such... read mindmaps

class SearchViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UIViewControllerTransitioningDelegate, UISearchBarDelegate, UISearchDisplayDelegate
{
    @IBOutlet weak var tableView:    UITableView!
    @IBOutlet weak var switchButton: UIButton!
    @IBOutlet weak var categoryButton: UIButton!
    @IBOutlet weak var searchButton: UIButton!
    @IBOutlet weak var sortSegment: UISegmentedControl!
    
    var sortNameInc:Int = 0, sortDateInc:Int = 0, sortCapacityInc:Int = 0 // uisegmentController sort tracking variables (asc, desc, off)
    
    var plusButtonView: LGPlusButtonsView!
//    @IBOutlet weak var searchBar:    UISearchBar! // TODO searchBar
    let transition = BubbleTransition()
    var hackathons               = [Hackathon]()
    var filterContentForCategory = [Hackathon]()
    var filteredHackathons       = [Hackathon]()
    var criteria                 = SearchCriteria()

    override func viewDidLoad()
    {
        
        super.viewDidLoad()
        updateButton()
//        updateSearchBar()
        
        criteria.category     = .CurrentLocation
        criteria.searchString = "Hack" // TODO text from searchbar
        criteria.primarySort  = Sort(column: "start", ascending: true) // TODO not setting this here at all but in IBAction button pressed or whatnot when filter is added
        // TODO increment i on each touch, based on that set color of the button and set the sort order to asc/desc
        
        let query = SearchTableViewController.queryForTable(criteria)
        
        query.findObjectsInBackgroundWithBlock(
        { (results, error) -> Void in
            self.hackathons = results as! [Hackathon]
            self.tableView.reloadData()
        })
        
        self.initPlusButtonView()

    }
    
    override func viewWillLayoutSubviews()
    {
        super.viewWillLayoutSubviews()
        self.setupPlusButtons()
    
    }
    
    @IBAction func sortTapped(sender: AnyObject)
    {
        let selectedSegmentIndex = sortSegment.selectedSegmentIndex
        segmentAtIndexTouched(selectedSegmentIndex)
    }
    
    @IBAction func categoryTapped(sender: AnyObject)
    {
        showOrHideCategories() // TODO change the searchCriteria category
    }
    
//    @IBAction func searchTapped(sender: AnyObject)
//    {
//        if ( categoryButton.touchInside )
//        {
//            // TODO searchBar overlay animation, present the searchViewController 'n stuff
//        }
//    }
    
    // date button tapped -> set filter to Date

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // func filterContentForCategory(category: Category) {
    //     self.filteredHackathons = self.hackathons.filter({( hackathon: Hackathon) -> Bool in
    //     // let categoryMatch = (scope == .CurrentLocation) || (searchCriteria.category == scope)
        
    //     return /*categoryMatch &&*/ categoryMatch
    //   })
    // }
    
//    func searchcontroller
//    
//    func searchDisplayController(controller: UISearchController, shouldReloadTableForSearchString searchString: String!) -> Bool { // TODO setup similar methods for categories through lgbutton
//
//        self.filterContentForSearchText(searchString)
//        return true
//    }
// 
//    func searchDisplayController(controller: UISearchController, shouldReloadTableForSearchScope searchOption: Int) -> Bool {
//      self.filterContentForSearchText(self.searchDisplayController!.searchBar.text)
//      return true
//    }

    // MARK: - custom methods
    func updateButton() // TODO change this function name to updateSwitchButton
    {
        switchButton.layer.cornerRadius = 22
        switchButton.backgroundColor    = secondaryColor
    }
    
    func updateTableView()
    {
        tableView.backgroundColor = mainColor
    }
   
}

// MARK: -
// MARK: bubbleTransitionMethods and helpers
extension SearchViewController
{
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let controller = segue.destinationViewController as? UIViewController {
            controller.transitioningDelegate  = self
            controller.modalPresentationStyle = .Custom
        }
    }
    
    // MARK: -
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
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        // TODO return filtered hackathons count instead?
        return hackathons.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        let cell      = tableView.dequeueReusableCellWithIdentifier("HackathonCell", forIndexPath: indexPath) as! ProfileTableViewCell
        var hackathon = hackathons[indexPath.row]
        cell.nameLabel?.text = hackathon.name
//        cell.dateLabel?.text = hackathon.start
//        cell.capacityLabel?.text = hackathon.capacity
//        cell.configure(name: hackathon.name, ticketClasses: hackathon.ticketClassNames as [String], hackathon.cost] as [Int]), capacity: hackathon.capacity as Int, date: hackathon.start as NSDate)
        return cell // TODO setup hackathon custom cell
    }
}

// MARK: -
// MARK: LGPlusButtonSetup
extension SearchViewController
{
    
    
    func setupPlusButtons()
    {
        if plusButtonView.buttons == nil { return }
        //        var asd = plusButtonView.buttons[1] as! LGPlusButton
        //        asd.imageView?.image =
        
        plusButtonView.plusButton = plusButtonView.buttons.firstObject as! LGPlusButton
        
        var viewFrame = plusButtonView.frame
        viewFrame.origin = CGPointMake(viewFrame.origin.x, viewFrame.origin.y + 80)
        plusButtonView.frame = viewFrame
        
        var firstPlusButton = plusButtonView.buttons.firstObject as! LGPlusButton
        
        let isPortrait = UIInterfaceOrientationIsPortrait(UIApplication.sharedApplication().statusBarOrientation)
        
        let buttonSide:CGFloat = (isPortrait ? 44.0 : 36.0)
        let inset:CGFloat = (isPortrait ? 3.0 : 2.0)
        let buttonsFontSize:CGFloat = (isPortrait ? 15.0 : 10.0)
        let plusButtonFontSize:CGFloat = buttonsFontSize*1.5
        
        plusButtonView.buttonInset = UIEdgeInsetsMake(inset, inset, inset, inset)
        plusButtonView.contentInset = UIEdgeInsetsMake(inset, inset, inset, inset)
        
        plusButtonView.setButtonsTitleFont(UIFont.boldSystemFontOfSize(buttonsFontSize))
        
        plusButtonView.plusButton.titleLabel?.font = UIFont.systemFontOfSize(plusButtonFontSize)
        plusButtonView.plusButton.titleOffset = CGPointMake(0.0, -plusButtonFontSize*0.1);
        
        plusButtonView.buttonsSize = CGSizeMake(buttonSide, buttonSide);
        plusButtonView.setButtonsLayerCornerRadius(buttonSide/2)
        plusButtonView.setButtonsLayerBorderColor(UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.1), borderWidth: 1.0)
        plusButtonView.setButtonsLayerMasksToBounds(true)
        plusButtonView.setButtonsBackgroundColor(UIColor(red: 0.0, green: 0.5, blue: 1.0, alpha: 1.0), forState:UIControlState.Normal)
        plusButtonView.setButtonsBackgroundColor(UIColor(red: 0.2, green: 0.7, blue: 1.0, alpha: 1.0), forState:UIControlState.Highlighted)
        plusButtonView.setButtonsBackgroundColor(UIColor(red: 0.2, green: 0.7, blue: 1.0, alpha: 1.0), forState:UIControlState.Highlighted|UIControlState.Selected)
        
    }
    
    func initPlusButtonView()
    {
        plusButtonView = LGPlusButtonsView(view: self.view, numberOfButtons: 4,showsPlusButton: false, actionHandler:
            { (view:LGPlusButtonsView!, title:String!, description:String!, index: UInt) -> Void in
                println("\(title), \(description), \(index)")
            }, plusButtonActionHandler: nil)
        
        plusButtonView.setButtonsTitles(["1","2","3","4"], forState: UIControlState.Normal)
        plusButtonView.setDescriptionsTexts(["Current Location","City", "Global", "Friends"])
        plusButtonView.position = LGPlusButtonsViewPositionTopRight
        plusButtonView.appearingAnimationType = LGPlusButtonsAppearingAnimationTypeCrossDissolveAndPop
        plusButtonView.setButtonsTitleColor(UIColor.whiteColor(), forState:UIControlState.Normal)
        plusButtonView.setButtonsAdjustsImageWhenHighlighted(false)
    } // TODO iset the whole view so it's under the categories button
            
    func showOrHideCategories()
    {
        if (plusButtonView.showing)
        {
            plusButtonView.hideAnimated(true, completionHandler:nil);
        }
        else
        {
            plusButtonView.showAnimated(true, completionHandler:nil);
        }
    }
}

// MARK: -
// MARK: UISEGMENT HELPERS logic - UIImage form a UIColor and handling segment changes based on index of segment
extension SearchViewController
{
    
    func getImageWithColor(color: UIColor, size: CGSize) -> UIImage
    {
        let rect = CGRectMake(0, 0, size.width, size.height)
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        color.setFill()
        UIRectFill(rect)
        let image: UIImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
    
    func segmentAtIndexTouched(index:Int)
    {
        let segmentWidth = sortSegment.bounds.width/3
        if      ( index == 0 ) { if ( sortNameInc == 3 )     { sortNameInc = 0 } }
        else if ( index == 1 ) { if ( sortDateInc == 3 )     { sortDateInc = 0 } }
        else if ( index == 2 ) { if ( sortCapacityInc == 3 ) { sortCapacityInc = 0 } }
        // change the primarySortType and color
        
        if ( sortNameInc == 0 ) // cost segment
        {
            sortSegment.setImage(getImageWithColor(UIColor.greenColor(), size:  CGSizeMake(25, segmentWidth)), forSegmentAtIndex: index)
        }
        else if ( sortNameInc == 1 ) // capacity segment
        {
            sortSegment.setImage(getImageWithColor(UIColor.redColor(), size:  CGSizeMake(25, segmentWidth)), forSegmentAtIndex: index)
        }
        else if ( sortNameInc == 2 ) // date segment
        {
            sortSegment.setImage(getImageWithColor(UIColor.clearColor(), size:  CGSizeMake(25, segmentWidth)), forSegmentAtIndex: index)
        }
        
        if      ( index == 0 ) { sortNameInc++ }
        else if ( index == 1 ) { sortDateInc++ }
        else if ( index == 2 ) { sortCapacityInc++ }
    } // TODO implement icon change and searchCriteria change
}

// MARK: -
// MARK: FILTERING HELPERS logic
extension SearchViewController
{
    func filterContentForSearchTextOrCategory(searchText: String, category: Category)
    {
        // Filter the array using the filter method
        self.filteredHackathons = self.hackathons.filter(
        {( hackathon: Hackathon) -> Bool in
            
            let categoryMatch = (category == .CurrentLocation) || (self.criteria.category == category)
            let stringMatch   = hackathon.name!.rangeOfString(searchText)
            return (categoryMatch && (stringMatch != nil)) || categoryMatch //  either filter for search text and category or just category
        })
    } // TODO revisit this when implementing search bar, reimplement probably
}

