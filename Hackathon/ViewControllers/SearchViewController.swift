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

class SearchViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UIViewControllerTransitioningDelegate
{
    @IBOutlet weak var tableView:    UITableView!
    @IBOutlet weak var switchButton: UIButton!
    @IBOutlet weak var categoryButton: UIButton!
    @IBOutlet weak var searchButton: UIButton!
    
    @IBOutlet weak var topConstraint: NSLayoutConstraint!
    
    var plusButtonView: LGPlusButtonsView!
    let transition               = BubbleTransition()
    
    var query:PFQuery?
    var hackathons               = [Hackathon]()
    var filterContentForCategory = [Hackathon]()
    var filteredHackathons       = [Hackathon]()
    
    // search stuff
    var searchCriteria = SearchCriteria()
    var search: UISearchBar?
    var searchController: UISearchController?
    enum State {
        case Off
        case SearchMode
    }
    
    var state: State = .Off {
        didSet {
            switch (state) {
            case .Off:
                // dismiss the previous results (empty strings and such, reset)
                // fill the table view with hackathons for current category
                // hide the search bar
                
            case .SearchMode:
                
                // display the search bar
                // animate the transition from button (constrains)
                // trigger keyboard?
                
                let searchText = searchBar?.text ?? ""
                query = ParseHelper.searchUsers(searchText, completionBlock:updateList)
            }
        }
    }
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        HackathonHelper.queryForTable(searchCriteria, onComplete: { (query) -> Void in
            self.deployQuery(query)
        })
        
        updateButtons()
        self.initPlusButtonView()
//      updateSearchBar()

        if ( FBSDKAccessToken.currentAccessToken() != nil ) { ParseLoginHelper.updateFacebookData() } // update users friends and whatnot
        
    }
    
    override func viewWillAppear(animated: Bool) {
        
        UIApplication.sharedApplication().setStatusBarStyle(.LightContent, animated: true)
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
        cell.capacityLabel?.text = hackathon.capacity?.stringValue
        
        HackathonHelper.getDistanceFromUser(hackathon.geoPoint!, complete: { (str) -> Void in
            cell.distanceLabel?.text = str
        })
        
        HackathonHelper.setHackathonCellLogoAsynch(hackathon, onComplete: { (image) -> Void in
            cell.logoImage.contentMode = UIViewContentMode.ScaleAspectFit
            cell.logoImage.image       = image
        })
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
                println("current location")
//                self.viewDidLayoutSubviews()
                
                HackathonHelper.queryForTable(searchCriteria, onComplete: { (query) -> Void in
                    self.deployQuery(query)
                })
            
            case 1:
                searchCriteria.category = .Global
                categoryButton.setImage(UIImage(named: "global"), forState: UIControlState.Normal)
                showOrHideCategories()
                println("global")
                
                HackathonHelper.queryForTable(searchCriteria, onComplete: { (query) -> Void in
                    self.deployQuery(query)
                })
            
            case 2:
                searchCriteria.category = .Friends
                categoryButton.setImage(UIImage(named: "friends"), forState: UIControlState.Normal)
                showOrHideCategories()
                println("friends")
                
                HackathonHelper.queryForTable(searchCriteria, onComplete: { (query) -> Void in
                    self.deployQuery(query)
                })
            
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
        plusButtonView.offset = CGPointMake(-10.7, 60.0)
        
        plusButtonView.setButtonsTitleFont(UIFont.boldSystemFontOfSize(buttonsFontSize))
        
        plusButtonView.plusButton.titleLabel?.font = UIFont.systemFontOfSize(plusButtonFontSize)
        plusButtonView.plusButton.titleOffset = CGPointMake(0.0, -plusButtonFontSize*0.1);
        
        plusButtonView.buttonsSize = CGSizeMake(buttonSide, buttonSide);
        plusButtonView.setButtonsLayerCornerRadius(buttonSide/2)
        plusButtonView.setButtonsLayerBorderColor(UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.1), borderWidth: 1.0)
//        plusButtonView.backgroundColor = UIColor.whiteColor()
        plusButtonView.setButtonsLayerMasksToBounds(true)
        
//        plusButtonView.setButtonsBackgroundImage(backgroundImage: UIImage!, forState: UIControlState) TODO: implement a transparent circular image here
        
        for (var i=0; i<plusButtonView.buttons.count; i++)
        {
            switch i {
            case 0:
                plusButtonView.buttons[i].setImage(UIImage(named: "currentLocation"), forState: UIControlState.Normal)
//                plusButtonView.buttons[i].setBackgroundImage(UIImage(named: "currentLocation"), forState: UIControlState.Normal) // TODO: set to transparent
            case 1:
                plusButtonView.buttons[i].setImage(UIImage(named: "global"),          forState: UIControlState.Normal)
            case 2:
                plusButtonView.buttons[i].setImage(UIImage(named: "friends"),         forState: UIControlState.Normal)
                
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
    func initializeSearchBar
    {
        search = UISearchBar(frame: CGRectMake(0, 0, 320, 44))
        
        search!.delegate = self;
        search!.showsCancelButton = true
        self.searchController = UISearchController(searchResultsController: self)
        
        self.searchController?.delegate = SearchViewController()
        self.searchController?.searchResultsController = self
        self.searchController.searchre = SearchViewController()
        
        [self.view addSubview:searchBar];
        
        search.hidden = true
        [searchController setActive:NO animated:NO];
    }
    
    func deployQuery(query: PFQuery)
    {
        query.findObjectsInBackgroundWithBlock(
            { (results, error) -> Void in
                self.hackathons = results as! [Hackathon]
                self.tableView.reloadData()
        })
    }
    
    func updateButtons()
    {
        switchButton.layer.cornerRadius   = 22
        categoryButton.layer.cornerRadius = 22
        searchButton.layer.cornerRadius   = 22
    }
    
    func updateTableView() { tableView.backgroundColor = mainColor }
    
}

extension SearchViewController: UISearchBarDelegate
{
    func searchBarTextDidBeginEditing(searchBar: UISearchBar) {
        searchBar.setShowsCancelButton(true, animated: true)
        state = .SearchMode
    }
    
    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        searchBar.text = ""
        searchBar.setShowsCancelButton(false, animated: true)
        state = .DefaultMode
    }
    
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        ParseHelper.searchUsers(searchText, completionBlock:updateList)
    }
}










