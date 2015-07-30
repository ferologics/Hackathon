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
    let locationManager          = CLLocationManager()
    
    var hackathons               = [Hackathon]()
    var filterContentForCategory = [Hackathon]()
    var filteredHackathons       = [Hackathon]()
    
    var searchCriteria = SearchCriteria()
    var query:PFQuery?
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        setUpLocationManager()
        updateSwitchButton()
//        updateSearchBar()
//        criteria.cityString = locationManager.locality // TODO text from searchbar 
        deployQuery(HackathonHelper.queryForTable(searchCriteria))
        
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
    func updateSwitchButton()
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
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?)
    {
        if let controller = segue.destinationViewController as? UIViewController
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
    
    func segmentAtIndexTouched(index:Int)
    {
        
        let segmentWidth = sortSegment.bounds.width/3
        println(segmentWidth)
        let greenImage = getImageWithColor(UIColor.greenColor(), size:  CGSizeMake(25, segmentWidth))
        let redImage = getImageWithColor(UIColor.greenColor(), size:  CGSizeMake(25, segmentWidth))
        let clearImage = getImageWithColor(UIColor.greenColor(), size:  CGSizeMake(25, segmentWidth))
        
        switch index {
            case 0: // CAPACITY
                
                if ( searchCriteria.primarySort?.state == .Off ) // set the state to ascending
                {
                    searchCriteria.primarySort?.state = .Ascending
                    deployQuery(HackathonHelper.queryForTable(searchCriteria))

                    if (searchCriteria.primarySort?.isPrimary == false && searchCriteria.secondarySort?.isPrimary == false) { searchCriteria.primarySort?.isPrimary = true } // change CAPACITY sort to be primary
                    
                    sortSegment.setImage(greenImage, forSegmentAtIndex: index)
                }
                if ( searchCriteria.primarySort?.state == .Ascending) // set the state to descending
                {
                    searchCriteria.primarySort?.state = .Descending
                    deployQuery(HackathonHelper.queryForTable(searchCriteria))

                    sortSegment.setImage(redImage, forSegmentAtIndex: index)
                }
                if ( searchCriteria.primarySort?.state == .Descending) // set the state to off
                {
                    searchCriteria.primarySort?.state = .Off
                    sortSegment.setImage(clearImage, forSegmentAtIndex: index)
                    deployQuery(HackathonHelper.queryForTable(searchCriteria))
                    
                    if ((searchCriteria.primarySort?.isPrimary == true) && (searchCriteria.secondarySort?.state != .Off)) // set isPrimary off for capacity and if date is on set it to primary
                    {
                        searchCriteria.primarySort?.isPrimary = false
                        searchCriteria.secondarySort?.isPrimary = true
                    }
                    else if (searchCriteria.primarySort?.isPrimary == true) // set isPrimary off
                    {
                        searchCriteria.primarySort?.isPrimary = false
                    }
                }
            
            case 1: // DATE
                
                if ( searchCriteria.secondarySort?.state == .Off ) // set the state to ascending
                {
                    searchCriteria.secondarySort?.state = .Ascending
                    deployQuery(HackathonHelper.queryForTable(searchCriteria))

                    if (searchCriteria.secondarySort?.isPrimary == false && searchCriteria.primarySort?.isPrimary == false) { searchCriteria.secondarySort?.isPrimary = true } // change DATE sort to be primary
                    sortSegment.setImage(greenImage, forSegmentAtIndex: index)
                }
                if ( searchCriteria.secondarySort?.state == .Ascending) // set the state to descending
                {
                    searchCriteria.secondarySort?.state = .Descending
                    deployQuery(HackathonHelper.queryForTable(searchCriteria))

                    sortSegment.setImage(redImage, forSegmentAtIndex: index)
                }
                if ( searchCriteria.secondarySort?.state == .Descending) // set the state to off
                {
                    searchCriteria.secondarySort?.state = .Off
                    sortSegment.setImage(clearImage, forSegmentAtIndex: index)
                    
                    deployQuery(HackathonHelper.queryForTable(searchCriteria))

                    if ((searchCriteria.secondarySort?.isPrimary == true) && (searchCriteria.primarySort?.state != .Off)) // set isPrimary off for date and if capacity is on set it to primary
                    {
                        searchCriteria.secondarySort?.isPrimary = false
                        searchCriteria.primarySort?.isPrimary = true
                    }
                    else if (searchCriteria.secondarySort?.isPrimary == true) // set isPrimary off
                    {
                        searchCriteria.secondarySort?.isPrimary = false
                    }
                }
            
            default:
                println("whoops") // debug
        }
    } // TODO implement icon change and searchCriteria change
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
// MARK: Core Location Delegate

extension SearchViewController: CLLocationManagerDelegate // TODO use parse instead of the cllocationmanager
{
    
    func setUpLocationManager()
    {
        self.locationManager.delegate = self
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
        self.locationManager.requestWhenInUseAuthorization()
        self.locationManager.startUpdatingLocation()
    }
    
    func locationManager(manager: CLLocationManager!, didUpdateLocations locations: [AnyObject]!)
    {
        CLGeocoder().reverseGeocodeLocation(manager.location, completionHandler:
        {(placemarks, error)->Void in
            
            if (error != nil)
            {
                println("Error: " + error.localizedDescription)
                return
            }
            
            if placemarks.count > 0
            {
                let pm = placemarks[0] as! CLPlacemark
                self.displayLocationInfo(pm)
            }
            else
            {
                println("Error with the data.")
            }
        })
    }
    
    func displayLocationInfo(placemark: CLPlacemark)
    {
        self.locationManager.stopUpdatingLocation()
        searchCriteria.cityString = placemark.locality
        println(placemark.locality)
        println(placemark.postalCode)
        println(placemark.administrativeArea)
        println(placemark.country)
    }
    
    func locationManager(manager: CLLocationManager!, didFailWithError error: NSError!)
    {
        // TODO setup erroor handler here
        println(error.localizedDescription)
    }
    
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
        cell.distanceLabel?.text = getDistanceFromUser(hackathon.geoPoint!)
        if let url = NSURL(string: hackathon.logo!) { // set hackathon logo
            if let data = NSData(contentsOfURL: url){
                cell.logoImage.contentMode = UIViewContentMode.ScaleAspectFit
                cell.logoImage.image = UIImage(data: data)
            }
        }
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
    
    func getDistanceFromUser(geopoint: PFGeoPoint) -> String {
        var distance = "Unknown"
        HackathonHelper.saveAndReturnCurrentLocation { (point) -> Void in
            
            distance = point.distanceInKilometersTo(point).description
        }
        return distance
    }
}










