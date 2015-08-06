//
//  ProfileViewController.swift
//  Hackathon
//
//  Created by master on 7/21/15.
//  Copyright (c) 2015 ferologics. All rights reserved.
//

import UIKit
import QuartzCore

class ProfileViewController: UIViewController, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var switchButton: UIButton!
    @IBOutlet weak var profilePhoto: UIImageView!
    @IBOutlet weak var name: UILabel!
    
    var hackathons = [Hackathon]()
    
    override func viewDidLoad() {
        updateView()
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
// MARK: helper functions for the profile
extension ProfileViewController
{
    func updateTableView() {
        tableView.layer.cornerRadius = 10
        self.getUsersHackathons()
        self.updateProile()
    }
    
    func getUsersHackathons()
    {
        var user = PFUser.currentUser()
        var relation = user?.relationForKey("tracking")
        var query = relation?.query() // can also be further refined
        //        query?.whereKeyExists("tracking")
        query?.findObjectsInBackgroundWithBlock({ (objects, error) -> Void in
            self.hackathons = objects as! [Hackathon]
            self.tableView.reloadData()
        })
    }
    
    func updateProile()
    {
        var user = PFUser.currentUser()
        var profilePhotoURL = user?.objectForKey("picture") as! String // cast to a string
        HackathonHelper.getDataFromUrl((NSURL(string: profilePhotoURL))!, completion: { (data) -> Void in // cast to a nsurl
            self.profilePhoto.layer.cornerRadius = self.profilePhoto.frame.width / 2
            self.profilePhoto.layer.masksToBounds = true
            self.profilePhoto.image = UIImage(data: data!)! // TODO: just store tihis inside parse as a file
            self.profilePhoto.contentMode = UIViewContentMode.ScaleAspectFit
        })
        name.text = user?.objectForKey("username") as? String
    }
    
    func updateView() {
        //        switchButton.transform = CGAffineTransformMakeRotation(CGFloat(M_PI_4))
        switchButton.layer.cornerRadius = 22
        
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