//
//  CardViewController.swift
//  Hackathon
//
//  Created by master on 7/30/15.
//  Copyright (c) 2015 ferologics. All rights reserved.
//

import UIKit

class CardViewController: UIViewController {
    
    @IBOutlet var rootView: UIView!
    @IBOutlet weak var cardView: HackathonCardView!

    @IBOutlet var tapRecognizer: UITapGestureRecognizer!
//    @IBOutlet var swipeRecognizer: UISwipeGestureRecognizer!
    
    @IBOutlet weak var logo: UIImageView!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var desc: UILabel!
    @IBOutlet weak var date: UILabel!
    @IBOutlet weak var ticketNames: UILabel!
    @IBOutlet weak var ticketCosts: UILabel!
    @IBOutlet weak var ticketAvailability: UILabel!
    
    
    var hackathon: Hackathon?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(animated: Bool) {
        UIApplication.sharedApplication().setStatusBarStyle(.LightContent, animated: true)
        cardView.layer.cornerRadius = 25
        initCardWithHackathon()
        
    }
    
    override func viewWillDisappear(animated: Bool) {
        UIApplication.sharedApplication().setStatusBarStyle(.Default, animated: true)
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
            let location = sender.locationInView(nil)
            
            if (!self.view.pointInside(self.view.convertPoint(location, fromView: cardView), withEvent: nil)) // FIXME: tap on left and top doesn't work
            {
                self.dismissViewControllerAnimated(true, completion: { () -> Void in
                    println("dismissed by tap")
                })
            }
//            if (swipeRecognizer.direction == UISwipeGestureRecognizerDirection.Left || swipeRecognizer.direction == UISwipeGestureRecognizerDirection.Right)
//            {
//                self.presentingViewController!.dismissViewControllerAnimated(true, completion: { () -> Void in
//                    println("dismissed by swipe")
//                })
//            } TODO: eventually implement swiping off
        }
    }
}

// MARK: general helper methods

extension CardViewController
{
    func initCardWithHackathon()
    {
        self.name.text = hackathon?.name
        self.desc.text = hackathon?.descript // TODO: not displaying the
        println(hackathon?.descript)
        
        setHackathonCardLogoAsynch(logo,hackathon: hackathon!)

    }
    
    func getDataFromUrl(urL:NSURL, completion: ((data: NSData?) -> Void)) {
        NSURLSession.sharedSession().dataTaskWithURL(urL) { (data, response, error) in
            completion(data: data)
            }.resume()
    }
    
    func setHackathonCardLogoAsynch(imageView:UIImageView, hackathon: Hackathon) {
        
        if let url = NSURL(string: hackathon.logo!) { // set hackathon logo
            
            getDataFromUrl(url) { data in
                dispatch_async(dispatch_get_main_queue()) {
                    imageView.contentMode = UIViewContentMode.ScaleAspectFit
                    imageView.image = UIImage(data: data!)
                }
            }
        }
    }
}




