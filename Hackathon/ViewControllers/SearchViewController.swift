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
import CoreLocation

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
    let transition               = BubbleTransition()
    
    var hackathons               = [Hackathon]()
    var filterContentForCategory = [Hackathon]()
    var filteredHackathons       = [Hackathon]()
    
    var searchCriteria = SearchCriteria()
    var query:PFQuery?
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        updateSwitchButton()
//        updateSearchBar()
//        criteria.cityString = locationManager.locality // TODO text from searchbar
        
        HackathonHelper.queryForTable(searchCriteria, onComplete: { (query) -> Void in
            self.deployQuery(query)
        })
        
        self.initPlusButtonView()

    }
    
    override func viewWillLayoutSubviews()
    {
        super.viewWillLayoutSubviews()
        self.setupPlusButtons()
    }
    
//    @IBAction func sortTapped(sender: AnyObject)
//    {
//        let selectedSegmentIndex = sortSegment.selectedSegmentIndex
//        segmentAtIndexTouched(selectedSegmentIndex)
//    }
    
    @IBAction func categoryTapped(sender: AnyObject)
    {
        self.plusButtonsViewPlusButtonPressed(plusButtonView)
    }
    
//    @IBAction func searchTapped(sender: AnyObject)
//    {
//        if ( categoryButton.touchInside )
//        {
//            // TODO searchBar overlay animation, present the searchViewController 'n stuff
//        }
//    }

    override func didReceiveMemoryWarning()
    {
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
//    func searchDisplayController(controller: UISearchController, shouldReloadTableForSearchString searchString: String!) -> Bool {
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

   
}

// MARK: -
// MARK: bubbleTransitionMethods and helpers
extension SearchViewController
{
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?)
    {
        if let controller = segue.destinationViewController as? ProfileViewController
        {
            controller.transitioningDelegate  = self
            controller.modalPresentationStyle = .Custom
        }
    }
    
    // MARK: UIViewControllerTransitioningDelegate
    func animationControllerForPresentedController(presented: UIViewController, presentingController presenting: UIViewController, sourceController source: UIViewController) -> UIViewControllerAnimatedTransitioning?
    {
        transition.transitionMode = .Present
        transition.startingPoint  = switchButton.center
        transition.bubbleColor    = switchButton.backgroundColor!
        return transition
    }
    
    func animationControllerForDismissedController(dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning?
    {
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
        let cell      = tableView.dequeueReusableCellWithIdentifier("HackathonCell", forIndexPath: indexPath) as! SearchTableViewCell
        var hackathon = hackathons[indexPath.row]
        println(hackathon.name)
        self.initCellWithHackathon(cell, hackathon: hackathon)
        return cell
    }
}

                                                                        // MARK: -
                                                                        // MARK: LGPlusButtonSetup
extension SearchViewController: LGPlusButtonsViewDelegate
{
    func plusButtonsViewPlusButtonPressed(plusButtonsView: LGPlusButtonsView!) {
        showOrHideCategories()
    }
    
    func plusButtonsView(plusButtonsView: LGPlusButtonsView!, buttonPressedWithTitle title: String!, description: String!, index: UInt)
    {
        switch index
        {
            case 0:
                searchCriteria.category = .CurrentLocation
                showOrHideCategories()
                println("current location")
                
            case 1:
                searchCriteria.category = .Global
                showOrHideCategories()
                println("global")
                
            case 2:
                searchCriteria.category = .Friends
                showOrHideCategories()
                println("friends")
                
            default: println("whoops")
        }
    }
    
    func setupPlusButtons()
    {
        if plusButtonView.buttons == nil { return }
        //        var asd = plusButtonView.buttons[1] as! LGPlusButton
        //        asd.imageView?.image =
        
        plusButtonView.plusButton = plusButtonView.buttons.firstObject as! LGPlusButton
        
//        var viewFrame = plusButtonView.frame
//        viewFrame.origin = CGPointMake(viewFrame.origin.x, viewFrame.origin.y + 80)
//        plusButtonView.frame = viewFrame
        
//        var firstPlusButton = plusButtonView.buttons.firstObject as! LGPlusButton // ???
        
        let isPortrait = UIInterfaceOrientationIsPortrait(UIApplication.sharedApplication().statusBarOrientation)
        
        let buttonSide:CGFloat = (isPortrait ? 44.0 : 36.0)
        let inset:CGFloat = (isPortrait ? 3.0 : 2.0)
        let buttonsFontSize:CGFloat = (isPortrait ? 15.0 : 10.0)
        let plusButtonFontSize:CGFloat = buttonsFontSize*1.5 // TODO figure out why the font on first button is different
        
        plusButtonView.buttonInset = UIEdgeInsetsMake(inset, inset, inset, inset)
        plusButtonView.contentInset = UIEdgeInsetsMake(inset, inset, inset, inset)
        plusButtonView.offset = CGPointMake(0.0, 50.0)
 
        
        plusButtonView.setButtonsTitleFont(UIFont.boldSystemFontOfSize(buttonsFontSize))
        
        plusButtonView.plusButton.titleLabel?.font = UIFont.systemFontOfSize(plusButtonFontSize)
        plusButtonView.plusButton.titleOffset = CGPointMake(0.0, -plusButtonFontSize*0.1);
        
        plusButtonView.buttonsSize = CGSizeMake(buttonSide, buttonSide);
        plusButtonView.setButtonsLayerCornerRadius(buttonSide/2)
        plusButtonView.setButtonsLayerBorderColor(UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.1), borderWidth: 1.0)
        plusButtonView.setButtonsLayerMasksToBounds(true)
        plusButtonView.setButtonsBackgroundColor(UIColor(red: 0.0, green: 0.5, blue: 1.0, alpha: 1.0), forState:UIControlState.Normal) // TODO change the color from palette
        plusButtonView.setButtonsBackgroundColor(UIColor(red: 0.2, green: 0.7, blue: 1.0, alpha: 1.0), forState:UIControlState.Highlighted)
        plusButtonView.setButtonsBackgroundColor(UIColor(red: 0.2, green: 0.7, blue: 1.0, alpha: 1.0), forState:UIControlState.Highlighted|UIControlState.Selected)
        plusButtonView.setButtonsImage(self.getImageWithColor(UIColor.redColor(), size: plusButtonView.buttonsSize), forState: UIControlState.Normal)
        
    }
    
    func initPlusButtonView()
    {
        plusButtonView = LGPlusButtonsView(view: self.view, numberOfButtons: 3,showsPlusButton: false, actionHandler:
            { (view:LGPlusButtonsView!, title:String!, description:String!, index: UInt) -> Void in
                println("\(title), \(description), \(index)")
            }, plusButtonActionHandler: nil)
        
        plusButtonView.delegate = self // SET THE DELEGATE TO SELF
//        plusButtonView.setButtonsTitles(["1","2","3","4"], forState: UIControlState.Normal) // TODO initialize the buttons with images
        plusButtonView.setDescriptionsTexts(["Current Location", "Global", "Friends"])
        plusButtonView.position = LGPlusButtonsViewPositionTopRight
        plusButtonView.appearingAnimationType = LGPlusButtonsAppearingAnimationTypeCrossDissolveAndPop
        plusButtonView.setButtonsTitleColor(UIColor.whiteColor(), forState:UIControlState.Normal)
        plusButtonView.setButtonsAdjustsImageWhenHighlighted(false)
        
    }
    
    func showOrHideCategories() // efficient function to show or hide the plusbuttonview
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
// MARK: UISEGMENT HELPERS logic - UIImage form a UIColor and handle changes on sortSegment

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
}

// MARK: -
// MARK: FILTERING HELPERS logic searchbar

extension SearchViewController
{
    func filterContentForSearchTextOrCategory(searchText: String, category: Category)
    {
        // Filter the array using the filter method
        self.filteredHackathons = self.hackathons.filter(
        {( hackathon: Hackathon) -> Bool in
            
            let categoryMatch = (category == .CurrentLocation) || (self.searchCriteria.category == category)
            let stringMatch   = hackathon.name!.rangeOfString(searchText)
            return (categoryMatch && (stringMatch != nil)) || categoryMatch //  either filter for search text and category or just category
        })
    } // TODO revisit this when implementing search bar, reimplement probably
}

// MARK: -
// MARK: general helper methods
extension SearchViewController
{
    func initCellWithHackathon(cell: SearchTableViewCell, hackathon: Hackathon)
    {
        cell.nameLabel?.text = hackathon.name
        cell.dateLabel?.text = HackathonHelper.utcToString( hackathon.start! )
        cell.capacityLabel?.text = hackathon.capacity?.stringValue
        
        getDistanceFromUser(hackathon.geoPoint!, complete: { (str) -> Void in
            cell.distanceLabel?.text = str
        })
        
        setHackathonCellLogoAsynch(cell, hackathon: hackathon) 
        
        
    }
    
    func deployQuery(query: PFQuery)
    {
        query.findObjectsInBackgroundWithBlock(
            { (results, error) -> Void in
                self.hackathons = results as! [Hackathon]
                println()
                self.tableView.reloadData()
        })
    }
    
    func getDistanceFromUser(geopoint: PFGeoPoint, complete: (String) -> Void ) {
        var distance:String?
        HackathonHelper.saveAndReturnCurrentLocation { (point) -> Void in
            
            distance = point.distanceInKilometersTo(geopoint).description
            complete(distance!)
        }
    }
    
    func getDataFromUrl(urL:NSURL, completion: ((data: NSData?) -> Void)) {
        NSURLSession.sharedSession().dataTaskWithURL(urL) { (data, response, error) in
            completion(data: data)
            }.resume()
    }
    
    func setHackathonCellLogoAsynch(cell:SearchTableViewCell, hackathon: Hackathon) {
        
        if let url = NSURL(string: hackathon.logo!) { // set hackathon logo
            
            getDataFromUrl(url) { data in
                dispatch_async(dispatch_get_main_queue()) {
                    cell.logoImage.contentMode = UIViewContentMode.ScaleAspectFit
                    cell.logoImage.image = UIImage(data: data!)
                }
            }
        }
    }
    
    func updateSwitchButton() {
        switchButton.layer.cornerRadius = 22
        switchButton.backgroundColor    = secondaryColor
    }
    
    func updateTableView() { tableView.backgroundColor = mainColor }
}










