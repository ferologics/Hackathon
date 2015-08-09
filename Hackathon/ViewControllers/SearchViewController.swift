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
import FBSDKCoreKit
import SwiftyJSON
import Mixpanel

class SearchViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UIViewControllerTransitioningDelegate
{
    @IBOutlet weak var tableView:    UITableView!
    @IBOutlet weak var switchButton: UIButton!
    @IBOutlet weak var categoryButton: UIButton!
    @IBOutlet weak var searchButton: UIButton!
    
    var plusButtonView: LGPlusButtonsView!
    let transition = BubbleTransition()
    
    var query:PFQuery?
    var hackathons = [Hackathon]()
    
    // hide set of constrains for the searchBar
    @IBOutlet var searchButtonLeadingSpace: NSLayoutConstraint!
    @IBOutlet var centerAlongSearchButton: NSLayoutConstraint!
    @IBOutlet var height: NSLayoutConstraint!
    
    // show set of constrains
    @IBOutlet var centerX: NSLayoutConstraint!
    @IBOutlet var viewLeadingSpace: NSLayoutConstraint!
    @IBOutlet var topSpace: NSLayoutConstraint!
    
    // search stuff
    @IBOutlet weak var search: UISearchBar!
    
    var searchCriteria = SearchCriteria()
    var searchController: UISearchController?
    
    let token = "baee9c7274a02339f3ac1f16d6084602"
    let mixpanel = Mixpanel.sharedInstance() // MIXPANEL
    
    enum State {
        case OffMode
        case SearchMode
    }
    
    var state: State = .OffMode {
        didSet {
            
            let showSet = [centerX, viewLeadingSpace, topSpace]
            let hideSet = [searchButtonLeadingSpace, centerAlongSearchButton, height]
            
            switch (state) {
            case .OffMode:
                
                searchCriteria.searchString = nil
                
                for constraint in showSet {
                    constraint.active = false
                }
                
                for constraint in hideSet {
                    constraint.active = true
                }
                
                UIView.animateWithDuration(0.5, animations: { () -> Void in
                    self.view.backgroundColor = UIColor.whiteColor()
                    self.categoryButton.alpha = 1
                    self.categoryButton.hidden = false
                    self.searchButton.hidden = false
                    self.searchButton.alpha = 1
                    self.search.alpha = 0
                    self.view.layoutIfNeeded()
                })
                
                self.tableView.reloadData()
                println("off u biach")
                
            case .SearchMode:
                
                mixpanel.track("search", properties:["category":"search"])
                
                for constraint in showSet {
                    constraint.active = true
                }
                
                for constraint in hideSet {
                    constraint.active = false
                }
                
                UIView.animateWithDuration(0.5, animations: { () -> Void in
                    self.view.backgroundColor = mainColor
                    self.categoryButton.alpha = 0
                    self.categoryButton.hidden = true
                    self.searchButton.hidden = true
                    self.searchButton.alpha = 0
                    self.search.alpha = 1
                    self.view.layoutIfNeeded()
                })
                
                self.search.becomeFirstResponder()
                
                searchCriteria.searchString = search?.text ?? nil
                HackathonHelper.queryForTable(searchCriteria, onComplete: { (query) -> Void in
                    println("Querying for type \(query.parseClassName)")
                    self.deployQuery(query)
                })
            }
        }
    }
    
    override func viewDidLoad() // MARK: viewdidload
    {
        super.viewDidLoad()
        Mixpanel.sharedInstanceWithToken(token)
        updateUI()

    }
    
    override func viewDidAppear(animated: Bool) {
        checkIfLocationEnabled()
        
        loadHackathons()
        
         // update users friends and whatnot
    }
    
    override func viewWillAppear(animated: Bool) {
        UIApplication.sharedApplication().setStatusBarStyle(.LightContent, animated: false)
        // ??? figure out why the card has shade only on the first time it's tapped
    }
    
    override func viewWillDisappear(animated: Bool) {
        UIApplication.sharedApplication().setStatusBarStyle(.Default, animated: true)
    }
    
    override func viewWillLayoutSubviews()
    {
        super.viewWillLayoutSubviews()
        self.setupPlusButtons()
    }
    
    @IBAction func categoryTapped(sender: AnyObject)
    {
        self.plusButtonsViewPlusButtonPressed(plusButtonView)
    }
    
    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}

// MARK: -
// MARK: bubbleTransitionMethods and helpers

extension SearchViewController
{
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?)
    {
        println("\(segue.identifier)")
        if let profile = segue.destinationViewController as? ProfileViewController
        {
            profile.transitioningDelegate  = self
            profile.modalPresentationStyle = .Custom
        }
        if let detailsView = segue.destinationViewController as? CardViewController
        {
            let index = tableView.indexPathForSelectedRow()!.row
            let hackathon = hackathons[index]
            detailsView.hackathon = hackathon
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

// MARK: -
// MARK: UITableViewCell

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
        //        println(hackathon.name)
        self.initCellWithHackathon(cell, hackathon: hackathon)
        return cell
    }
    
    func initCellWithHackathon(cell: SearchTableViewCell, hackathon: Hackathon)
    {
        cell.selectionStyle = UITableViewCellSelectionStyle.None
        cell.nameLabel?.text = hackathon.name
        cell.dateLabel?.text = HackathonHelper.utcToString( hackathon.start! )
        cell.capacityLabel?.text = costRange(hackathon)
        
        HackathonHelper.getDistanceFromUser(hackathon.geoPoint!, complete: { (str) -> Void in
            cell.distanceLabel?.text = str
        })
        
        if Reachability.isConnectedToNetwork() {
            HackathonHelper.setHackathonCellLogoAsynch(hackathon, onComplete: { (image) -> Void in
                cell.logoImage.contentMode = UIViewContentMode.ScaleAspectFit
                cell.logoImage.image       = image
            })
        } else { ErrorHandling.displayErrorForNetwork(self) }
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
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
            categoryButton.setImage(UIImage(named: "currentLocation"), forState: UIControlState.Normal)
            showOrHideCategories()

            mixpanel.track("search", properties:["global":"current location"])

            //                self.viewDidLayoutSubviews()
            if Reachability.isConnectedToNetwork(){ queryShizzle() }
            else { ErrorHandling.displayErrorForNetwork(self) }
            
        case 1:
            searchCriteria.category = .Global
            categoryButton.setImage(UIImage(named: "global"), forState: UIControlState.Normal)
            showOrHideCategories()
            
            mixpanel.track("search", properties:["category":"global"])
            
            if Reachability.isConnectedToNetwork(){ queryShizzle() }
            else { ErrorHandling.displayErrorForNetwork(self) }
            
        case 2:
            searchCriteria.category = .Friends
            categoryButton.setImage(UIImage(named: "friends"), forState: UIControlState.Normal)
            showOrHideCategories()

            mixpanel.track("search", properties:["category":"friends"])
            
            if Reachability.isConnectedToNetwork(){ queryShizzle() }
            else { ErrorHandling.displayErrorForNetwork(self) }
            
        default: println("whoops")
        }
    }
    
    func setupPlusButtons()
    {
        if plusButtonView.buttons == nil { return }
        
        plusButtonView.plusButton = plusButtonView.buttons.firstObject as! LGPlusButton
        
        let isPortrait = UIInterfaceOrientationIsPortrait(UIApplication.sharedApplication().statusBarOrientation)
        
        let buttonSide:CGFloat = (isPortrait ? 44.0 : 36.0)
        let inset:CGFloat = (isPortrait ? 3.0 : 2.0)
        let buttonsFontSize:CGFloat = (isPortrait ? 15.0 : 10.0)
        let plusButtonFontSize:CGFloat = buttonsFontSize*1.5 // TODO figure out why the font on first button is different
        
        plusButtonView.buttonInset = UIEdgeInsetsMake(inset, inset, inset, inset)
        plusButtonView.contentInset = UIEdgeInsetsMake(inset, inset, inset, inset)
        plusButtonView.offset = CGPointMake(-10.5, 65.0)
        
        plusButtonView.setButtonsTitleFont(UIFont.boldSystemFontOfSize(buttonsFontSize))
        
        plusButtonView.plusButton.titleLabel?.font = UIFont.systemFontOfSize(plusButtonFontSize)
        plusButtonView.plusButton.titleOffset = CGPointMake(0.0, -plusButtonFontSize*0.1);
        
        plusButtonView.buttonsSize = CGSizeMake(buttonSide, buttonSide);
        plusButtonView.setButtonsLayerCornerRadius(buttonSide/2)
        plusButtonView.setButtonsLayerBorderColor(mainColor, borderWidth: 0.5)
        //        plusButtonView.backgroundColor = UIColor.whiteColor()
        plusButtonView.setButtonsLayerMasksToBounds(true)
        
        //        plusButtonView.setButtonsBackgroundImage(backgroundImage: UIImage!, forState: UIControlState) TODO: implement a transparent circular image here
        
        var whiteImage = getImageWithColor(UIColor.whiteColor(), size: CGSize(width: 44.0,height: 44.0))
        
        for (var i=0; i<plusButtonView.buttons.count; i++)
        {
            switch i {
            case 0:
                plusButtonView.buttons[i].setImage(UIImage(named: "currentLocation"), forState: UIControlState.Normal)
                plusButtonView.buttons[i].setBackgroundImage(whiteImage, forState: UIControlState.Normal)
            case 1:
                plusButtonView.buttons[i].setImage(UIImage(named: "global"),          forState: UIControlState.Normal)
                plusButtonView.buttons[i].setBackgroundImage(whiteImage, forState: UIControlState.Normal)
            case 2:
                plusButtonView.buttons[i].setImage(UIImage(named: "friends"),         forState: UIControlState.Normal)
                plusButtonView.buttons[i].setBackgroundImage(whiteImage, forState: UIControlState.Normal)
                //                plusButtonView.buttons[i].cornerRadius = 22.0
            default: println("something went wrong along the way");
            }
        }
    }
    
    func initPlusButtonView()
    {
        plusButtonView = LGPlusButtonsView(view: self.view, numberOfButtons: 3,showsPlusButton: false, actionHandler:
            { (view:LGPlusButtonsView!, title:String!, description:String!, index: UInt) -> Void in
                println("\(title), \(description), \(index)")
            }, plusButtonActionHandler: nil)
        
        plusButtonView.delegate = self
        
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

// MARK: UIImage form a UIColor and handle changes on sortSegment

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
// MARK: Search HELPERS logic searchbar

extension SearchViewController
{
    
    @IBAction func searchTapped(sender: AnyObject)
    {
        // set the states
        if ( self.state == .OffMode ) { self.state = .SearchMode}
        else if ( self.state == .SearchMode ) {self.state = .OffMode}
    }
    
}

// MARK: -
// MARK: general helper methods

extension SearchViewController
{
    @objc func updateTableView(notification: NSNotification){
        updateTableView()
    }
    
    func queryShizzle()
    {
        HackathonHelper.queryForTable(searchCriteria, onComplete: { (query) -> Void in
            self.deployQuery(query)
        })
    }
    
    func loadHackathons()
    {
        if Reachability.isConnectedToNetwork()
        {
            HackathonHelper.queryForTable(searchCriteria, onComplete: { (query) -> Void in
                self.deployQuery(query)
            })
            
            if ( FBSDKAccessToken.currentAccessToken() != nil ) { ParseLoginHelper.updateFacebookData() }
        }
        else
        {
            ErrorHandling.displayErrorForNetwork(self)
        }
    }
    
    func checkIfLocationEnabled() {
        
        if (!NSUserDefaults.standardUserDefaults().boolForKey("HasLaunchedOnce"))
        {
            let manager = CLLocationManager()
            switch CLLocationManager.authorizationStatus() {
            case .Restricted, .Denied:
                
                let alertController = UIAlertController(
                    title: "Background Location Access Disabled",
                    message: "In order to see hackathons near you, please open this app's settings and set location access to 'While Using the App'.",
                    preferredStyle: .Alert)
                
                let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: nil)
                alertController.addAction(cancelAction)
                
                let openAction = UIAlertAction(title: "Open Settings", style: .Default) { (action) in
                    if let url = NSURL(string:UIApplicationOpenSettingsURLString) {
                        UIApplication.sharedApplication().openURL(url)
                    }
                }
                
                alertController.addAction(openAction)
                
                NSUserDefaults.standardUserDefaults().setBool(false, forKey:"HasLaunchedOnce")
                NSUserDefaults.standardUserDefaults().synchronize()
                
                self.presentViewController(alertController, animated: true, completion: nil)
                
            case .NotDetermined:
                manager.requestWhenInUseAuthorization()
                checkIfLocationEnabled()
                
            case .AuthorizedWhenInUse:
                NSUserDefaults.standardUserDefaults().setBool(true, forKey:"HasLaunchedOnce")
                NSUserDefaults.standardUserDefaults().synchronize()
            default: return
            }
            
        }
    }
    
    func costRange(hack: Hackathon) -> String
    {
        var min = ""
        var minCost = hack.ticketClassesCosts?.first
        
        if let minC = minCost {
            min = minC
        }
        
        let str = "from \(min)"
        return str
    }
    
    func deployQuery(query: PFQuery)
    {
        query.findObjectsInBackgroundWithBlock(
            { (results, error) -> Void in
                self.hackathons = (results as? [Hackathon]) ?? []
                self.tableView.reloadData()
                
                if (error != nil) { self.mixpanel.track("error", properties:["category":"query"]) }
        })
    }
    
    func updateUI()
    {
        self.initPlusButtonView()
        updateButtonsAndTableView()
        updateSearchBar()
        updateViewConstraints()
        self.view.layoutIfNeeded()
    }
    
    func updateSearchBar()
    {
        self.search.alpha = 0
    }
    
    func updateButtonsAndTableView()
    {
        switchButton.layer.cornerRadius   = 30
        switchButton.layer.borderColor = mainColor.CGColor!
        switchButton.layer.borderWidth = 0.5
        switchButton.layer.masksToBounds = true
        
        categoryButton.layer.cornerRadius = 22
        categoryButton.layer.borderColor = mainColor.CGColor!
        categoryButton.layer.borderWidth = 0.5
        categoryButton.layer.masksToBounds = true
        
        searchButton.layer.cornerRadius   = 22
        searchButton.layer.borderColor = mainColor.CGColor!
        searchButton.layer.borderWidth = 0.5
        searchButton.layer.masksToBounds = true
        
        self.tableView.contentInset = UIEdgeInsets(top: 50, left: 0, bottom: 70, right: 0)
    }
    
    func registerNotificationCenter()
    {
        NSNotificationCenter.defaultCenter().addObserver(
            self,
            selector: "updateTableView:",
            name: "reloadSearchView",
            object: nil)
    }
    
    func updateTableView() {
        queryShizzle()
    }
    
}

extension SearchViewController: UISearchBarDelegate
{
    func searchBarTextDidBeginEditing(searchBar: UISearchBar) {
        searchBar.setShowsCancelButton(true, animated: true)
        state = .SearchMode // FIXME : when taps category it changes but doesnt load
    }
    
    func searchBarTextDidEndEditing(searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    
    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        searchBar.setShowsCancelButton(false, animated: true)
        state = .OffMode
    }
    
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        searchCriteria.searchString = searchText
        if Reachability.isConnectedToNetwork(){ queryShizzle() }
        else { ErrorHandling.displayErrorForNetwork(self) }
    }
    
}










