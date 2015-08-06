//
//  CardViewController.swift
//  Hackathon
//
//  Created by master on 7/30/15.
//  Copyright (c) 2015 ferologics. All rights reserved.
//

import UIKit
import Parse

class CardViewController: UIViewController {
    
    @IBOutlet var rootView: UIView!
    @IBOutlet weak var cardView: HackathonCardView!

    @IBOutlet var tapRecognizer: UITapGestureRecognizer!
    @IBOutlet var swipeRecognizerRight: UISwipeGestureRecognizer!
    @IBOutlet var swipeRecognizerLeft: UISwipeGestureRecognizer!

    
    @IBOutlet weak var logo: UIImageView!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var desc: UILabel!
    @IBOutlet weak var date: UILabel!
    @IBOutlet weak var ticketNames: UILabel!
    @IBOutlet weak var ticketCosts: UILabel!
    @IBOutlet weak var ticketAvailability: UILabel!
    
    @IBOutlet weak var track: UIButton!
    @IBOutlet weak var expand: UIButton!
    
    @IBOutlet weak var descriptionHeight: NSLayoutConstraint!
    var backupConstraint:NSLayoutConstraint? // TODO: edit this to be 
    
    var hackathon: Hackathon?
    var watchlist = Watchlist()
    
    var expanded = false
    var tracking = false {
        didSet {
            
            if  tracking == true  {
                self.track.highlighted = true
                
//                if oldValue == false
//                {
//                    println(UIImage(named: "track"))
//                    println(UIImage(named: "tracking"))
//                    let imagesForAnimation = [UIImage(named: "track")!, UIImage(named: "tracking")!]
//                    
//                    if let button = track
//                    {
//                        button.imageView?.animationImages      = imagesForAnimation
//                        button.imageView?.animationDuration    = 1.0
//                        button.imageView?.animationRepeatCount = 1
//                        button.imageView?.startAnimating()
//                    }
//                    
//                    let delay = 0.9 * Double(NSEC_PER_SEC)
//                    let time = dispatch_time(DISPATCH_TIME_NOW, Int64(delay))
//                    dispatch_after(time, dispatch_get_main_queue()) {
//                        self.track.highlighted = true
//                    }
//
//                }
//                else { self.track.highlighted = true }
                
            } else {
                
                self.track.highlighted = false
                
//                if oldValue == true
//                {
//                    let imagesForAnimation = [UIImage(named: "tracking")!, UIImage(named: "track")!] // TODO: add more images, just scale them
//                    track.imageView?.animationImages = imagesForAnimation
//                    track.imageView?.animationDuration = 1.0
//                    track.imageView?.animationRepeatCount = 1
//                    track.imageView?.startAnimating()
//                    
//                    let delay = 0.9 * Double(NSEC_PER_SEC)
//                    let time = dispatch_time(DISPATCH_TIME_NOW, Int64(delay))
//                    dispatch_after(time, dispatch_get_main_queue()) {
//                        self.track.highlighted = false
//                    }
//
//                }
//                else { self.track.highlighted = false }
            }
        }
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(animated: Bool) {
        
        UIApplication.sharedApplication().setStatusBarStyle(.LightContent, animated: true)
        cardView.layer.cornerRadius = 25
        watchlist.isTrackingHackathon(hackathon!, onComplete: { (isTracking) -> Void in
            self.tracking = isTracking
            self.initCardWithHackathon()
        })
         // ??? figure out why the card has shade only on the first time it's tapped
    }
    
    override func viewWillDisappear(animated: Bool) {
        UIApplication.sharedApplication().setStatusBarStyle(.Default, animated: true)
    }
    

    @IBAction func trackTapped(sender: AnyObject) {
            
        if (tracking == true)
        {
            self.watchlist.stopTrackingHackathon(self.hackathon!, onComplete: { (tracking) -> Void in
                self.tracking = tracking
            })
        }
        else
        {
            self.watchlist.startTrackingHackathon(self.hackathon!, onComplete: { (tracking) -> Void in
                self.tracking = tracking
            })
        }
    }
    
    @IBAction func expandTaped(sender: AnyObject) { // TODO: make the animation more natural somehow?
        
        if (expanded == false)
        {
            expanded = true
            self.backupConstraint = self.descriptionHeight
            
            UIView.animateWithDuration(1.0) { self.descriptionHeight.active = false ; self.view.layoutIfNeeded() }
//            let expandImage = UIImage(named: "expand")!.CIImage
//            expand.setImage(UIImage(CIImage: expandImage!, scale: 1.0, orientation: UIImageOrientation.UpMirrored), forState: UIControlState.Normal) // TODO : animate the expansion image
        }
        else
        {
            expanded = false
            self.descriptionHeight = self.backupConstraint
            UIView.animateWithDuration(1.0) { self.descriptionHeight.active = true ; self.view.layoutIfNeeded() }
        }
        
    }
}

// MARK: gesture recognizer delegate and related functions

extension CardViewController: UIGestureRecognizerDelegate
{
    func gestureRecognizerShouldBegin(gestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldReceiveTouch touch: UITouch) -> Bool {
        return true
    }
    
    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWithGestureRecognizer otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    @IBAction func gestureOutside(sender: AnyObject) {
        dismissIfOutside(sender)
    }
    
    func dismissIfOutside(sender:AnyObject)
    {
        if (sender.state == UIGestureRecognizerState.Ended)
        {
            let location = sender.locationInView(self.cardView)
            if (!self.cardView.pointInside(location, withEvent: nil)) // FIXME: tap on left and top doesn't work
            {
                self.dismissViewControllerAnimated(true, completion: { () -> Void in
                    println("dismissed by tap")
                })
            }
        }
    }
}

// MARK: general helper methods

extension CardViewController
{
    
    func initCardWithHackathon()
    {
//        println(hackathon)
        self.name.text = hackathon?.name
        self.desc.text = hackathon?.descript
//        println(hackathon?.descript)
        HackathonHelper.setHackathonCellLogoAsynch(hackathon!, onComplete: { (image) -> Void in
            self.logo.image = image
            self.logo.contentMode = UIViewContentMode.ScaleAspectFit
        })
    }
}




