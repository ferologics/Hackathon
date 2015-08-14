//
//  ProfileViewController.swift
//  Hackathon
//
//  Created by master on 7/21/15.
//  Copyright (c) 2015 ferologics. All rights reserved.
//

import UIKit
import QuartzCore
import Mixpanel

class ProfileViewController: UIViewController, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var switchButton: UIButton!
    @IBOutlet weak var profilePhoto: UIImageView!
    @IBOutlet weak var name: UILabel!
    
    var searchController = SearchViewController()
    var hackathons = [Hackathon]()
    
    let token = "baee9c7274a02339f3ac1f16d6084602"
    let mixpanel = Mixpanel.sharedInstance()
    
    override func viewDidLoad() {
        updateView()
        Mixpanel.sharedInstanceWithToken(token)
        mixpanel.track("used profile")
        registerNotificationCenter()
    }
    
    override func viewDidAppear(animated: Bool) {
        updateTableView()
    }
    
    @objc func updateTableView(notification: NSNotification){
           updateTableView()
    }
    
    override func viewWillAppear(animated: Bool) {
        UIApplication.sharedApplication().setStatusBarStyle(.LightContent, animated: true)
    }
    
    override func viewWillDisappear(animated: Bool) {
        UIApplication.sharedApplication().setStatusBarStyle(.Default, animated: true)
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?)
    {
        println("\(segue.identifier)")
        if let detailsView = segue.destinationViewController as? CardViewController
        {
            let index = tableView.indexPathForSelectedRow()!.row
            let hackathon = hackathons[index]
            detailsView.hackathon = hackathon
        }
    }
    
}

extension ProfileViewController: UITableViewDelegate
{
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        // TODO return filtered hackathons count instead?
        return hackathons.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        let cell      = tableView.dequeueReusableCellWithIdentifier("ProfileHackathonCell", forIndexPath: indexPath) as! ProfileTableViewCell
        var hackathon = hackathons[indexPath.row]
//        println(hackathon.name)
        self.initCellWithHackathon(cell, hackathon: hackathon)
        return cell
    }
    
    func initCellWithHackathon(cell: ProfileTableViewCell, hackathon: Hackathon)
    {
        cell.selectionStyle = UITableViewCellSelectionStyle.None
        cell.nameLabel?.text = hackathon.name
        cell.dateLabel?.text = HackathonHelper.utcToString( hackathon.start! )
        cell.capacityLabel?.text = searchController.costRange(hackathon)
        
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
// MARK: helper functions for the profile
extension ProfileViewController
{
    
    func updateTableView() {
        
        if Reachability.isConnectedToNetwork() {
            self.getUsersHackathons()
            self.updateProile()
        }
        else { ErrorHandling.displayErrorForNetwork(self) }
    }
    
    func getUsersHackathons()
    {
        var user = PFUser.currentUser()
        var relation = user?.relationForKey("tracking")
        var query = relation?.query() // can also be further refined
        
        query?.findObjectsInBackgroundWithBlock({ (objects, error) -> Void in
            if let hackathons = objects as? [Hackathon]
            {
                self.hackathons = hackathons
                self.tableView.reloadData()
            }
        })
    }
    
    func updateProile()
    {
        var user = PFUser.currentUser()
        var profilePhotoURL = ""
        if ( FBSDKAccessToken.currentAccessToken() != nil ) {
            if let photo = user?.objectForKey("picture") as? String {
                profilePhotoURL =  photo// cast to a string
                HackathonHelper.getDataFromUrl((NSURL(string: profilePhotoURL))!, completion: { (data) -> Void in // cast to a nsurl
                    self.profilePhoto.layer.cornerRadius = self.profilePhoto.frame.width / 2
                    self.profilePhoto.layer.masksToBounds = true
                    self.profilePhoto.image = UIImage(data: data!)! ?? UIImage(named: "noImage")// TODO: just store tihis inside parse as a file
                    self.profilePhoto.contentMode = UIViewContentMode.ScaleAspectFit
                })
            } else {
                profilePhotoURL = "http://thumb7.shutterstock.com/display_pic_with_logo/567124/99335579/stock-vector-no-user-profile-picture-hand-drawn-99335579.jpg"
                HackathonHelper.getDataFromUrl((NSURL(string: profilePhotoURL))!, completion: { (data) -> Void in // cast to a nsurl
                    self.profilePhoto.layer.cornerRadius = self.profilePhoto.frame.width / 2
                    self.profilePhoto.layer.masksToBounds = true
                    self.profilePhoto.image = UIImage(data: data!)! // TODO: just store tihis inside parse as a file
                    self.profilePhoto.contentMode = UIViewContentMode.ScaleAspectFit
                })
            }
       }
        name.text = user?.objectForKey("username") as? String
    }
    
    func registerNotificationCenter()
    {
        NSNotificationCenter.defaultCenter().addObserver(
            self,
            selector: "updateTableView:",
            name: "reloadProfile",
            object: nil)
    }
    
    func updateView() {
        
        switchButton.layer.cornerRadius   = 30
        switchButton.layer.borderColor = mainColor.CGColor!
        switchButton.layer.borderWidth = 0.5
        switchButton.layer.masksToBounds = true
        
        tableView.layer.cornerRadius = 10
        tableView.layer.borderColor = mainColor.CGColor
        tableView.layer.borderWidth = 0.4
    }
}

// MARK: -
// MARK: BubbleTransition methods and such
extension ProfileViewController
{
    @IBAction func closeAction(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
}