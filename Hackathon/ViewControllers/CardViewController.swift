//
//  CardViewController.swift
//  Hackathon
//
//  Created by master on 7/30/15.
//  Copyright (c) 2015 ferologics. All rights reserved.
//

import UIKit
import Parse
import MapKit
import AddressBook

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
    @IBOutlet weak var url: UITextView!
    
    @IBOutlet weak var mapView: MKMapView!
    
    @IBOutlet weak var track: UIButton!
    @IBOutlet weak var cancel: UIButton!
    @IBOutlet weak var expand: UIButton!
    
    @IBOutlet var descriptionHeight: NSLayoutConstraint!
    
    var hackathon: Hackathon?
    var watchlist = Watchlist()
    
    var mapInfo: MapInfo?
    
    var expanded = false
    var tracking = false {
        didSet {
            
            if  tracking == true  {
                UIView.animateWithDuration(0.5, animations: { () -> Void in
                    self.track.highlighted = true
                    self.track.imageView!.transform = CGAffineTransformMakeRotation(CGFloat(2*M_PI))
                    self.view.layoutIfNeeded()
                })
                
                
            } else {
                UIView.animateWithDuration(0.5, animations: { () -> Void in
                    self.track.highlighted = false
                    self.track.imageView!.transform = CGAffineTransformIdentity
                    self.view.layoutIfNeeded()
                })
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        updateMapView()
        
        mapView.delegate = self
        cardView.layer.cornerRadius = 25
        cardView.layer.masksToBounds = true
        self.view.layoutIfNeeded()
    }
    
    override func viewWillAppear(animated: Bool) {
        
        UIApplication.sharedApplication().setStatusBarStyle(.LightContent, animated: true)

        watchlist.isTrackingHackathon(hackathon!, onComplete: { (isTracking) -> Void in
            self.tracking = isTracking
            self.initCardWithHackathon()
        })
    }
    
    override func viewWillDisappear(animated: Bool) {
        UIApplication.sharedApplication().setStatusBarStyle(.Default, animated: true)
    }
    

    @IBAction func trackTapped(sender: AnyObject) {
            
        if (tracking == true)
        {
            self.watchlist.stopTrackingHackathon(self.hackathon!, onComplete: { (tracking) -> Void in
                self.tracking = !tracking // tracking is false
                NSNotificationCenter.defaultCenter().postNotificationName("reloadProfile", object: nil)
            })
        }
        else
        {
            self.watchlist.startTrackingHackathon(self.hackathon!, onComplete: { (tracking) -> Void in
                self.tracking = tracking // tracking is true
                NSNotificationCenter.defaultCenter().postNotificationName("reloadProfile", object: nil)
            })
        }
    }
    
    @IBAction func expandTaped(sender: AnyObject) { // TODO: make the animation more natural somehow?
        
        if (expanded == false)
        {
            expanded = true
            
            UIView.animateWithDuration(0.5) {
                self.expand.imageView!.transform = CGAffineTransformMakeRotation(CGFloat(M_PI))
                self.view.layoutIfNeeded()
            }
            
            let delay = 0.3 * Double(NSEC_PER_SEC)
            let time = dispatch_time(DISPATCH_TIME_NOW, Int64(delay))
            
            dispatch_after(time, dispatch_get_main_queue()) {
                
                UIView.animateWithDuration(0.5) {
                    self.descriptionHeight.active = false
                    self.view.layoutIfNeeded()
                }
            }
            
        }
        else
        {
            expanded = false
            
            UIView.animateWithDuration(0.5) {
                self.expand.imageView!.transform = CGAffineTransformIdentity
                self.view.layoutIfNeeded()
            }
            
            let delay = 0.3 * Double(NSEC_PER_SEC)
            let time = dispatch_time(DISPATCH_TIME_NOW, Int64(delay))
            
            dispatch_after(time, dispatch_get_main_queue()) {
                
                UIView.animateWithDuration(0.5) {
                    self.descriptionHeight.active = true
                    self.view.layoutIfNeeded()
                }
            }
        }
        
    }
}

// MARK: gesture recognizer delegate and related functions

extension CardViewController: UIGestureRecognizerDelegate
{
    
    
    @IBAction func dismissCard(sender: AnyObject) {
        
        UIView.animateWithDuration(0.5, animations: { () -> Void in
            self.cancel.imageView?.transform = CGAffineTransformMakeRotation(-CGFloat(M_PI_2))
            
            self.view.layoutIfNeeded()
        })
        
        let delay = 0.3 * Double(NSEC_PER_SEC)
        let time = dispatch_time(DISPATCH_TIME_NOW, Int64(delay))
        
        dispatch_after(time, dispatch_get_main_queue()) {
            
            self.dismissViewControllerAnimated(true, completion: { () -> Void in
                
                println("dismissed by tap")
            })
        }
    }
    
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
            if (!self.cardView.pointInside(location, withEvent: nil))
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
        
        if let start = hackathon?.start, end = hackathon?.end {
            self.date.text = formatForCard(start, end: end)
        }
        
        self.ticketNames.text = ticketClassNames()
        self.ticketCosts.text = ticketClassCost()
        self.ticketAvailability.text = ticketClassAvailability()
        self.url.text = hackathon?.url
        
        // mapview
}
    
    func formatForCard(start: NSDate, end: NSDate) -> String {
        
        var dateFormatter = NSDateFormatter()
        var dayFormatter = NSDateFormatter()
        dayFormatter.dateFormat = "d"
        dateFormatter.dateFormat = "d MMM' 'H:mm" // format date
        //"yyyy-MM-dd'T'HH:mm:ss'Z'" maybe?
        
        var dayString = dayFormatter.stringFromDate(start)
        var dateString = dateFormatter.stringFromDate(end)
        
        return "\(dayString)-\(dateString)"
    }
    
    func ticketClassNames() -> String
    {
        var str = ""
        if let classes = hackathon?.ticketClassesCosts {
            for name in classes {
                str += "\(name)\n"
            }
        }
        return str
    }
    
    func ticketClassCost() -> String
    {
        var str = ""
        if let classes = hackathon?.ticketClassesNames {
            for cost in classes {
                str += "\(cost)\n"
            }
        }
        return str
    }
    
    func ticketClassAvailability() -> String
    {
        var str = ""
        if let classes = hackathon?.ticketClassesOnSaleStatuses {
            for availability in classes {
                str += "\(availability.lowercaseString)\n"
            }
        }
        return str
    }
}

extension CardViewController: MKMapViewDelegate
{
    func updateMapView()
    {
        if let point = hackathon?.geoPoint {
            centerMapOnLocation(point)
            mapInfo = MapInfo(title: hackathon?.name!, locationName: hackathon?.adres_1!, address_2: hackathon?.adres_2, coordinate: point)
        }
    }
    
    func centerMapOnLocation(location: PFGeoPoint)
    {
        let coordinate = CLLocation(latitude: location.latitude, longitude: location.longitude)
        let regionRadius: CLLocationDistance = 1000
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(coordinate.coordinate, regionRadius * 2.0, regionRadius * 2.0)
        mapView.setRegion(coordinateRegion, animated: true)
    }
    
    func mapView(mapView: MKMapView!, viewForAnnotation annotation: MKAnnotation!) -> MKAnnotationView! {
        if let annotation = annotation as? MapInfo
        {
            let identifier = "pin"
            
            var view: MKPinAnnotationView
            if let dequedView = mapView.dequeueReusableAnnotationViewWithIdentifier(identifier) as? MKPinAnnotationView
            {
                dequedView.annotation = annotation
                view = dequedView
            }
            else
            {
                view = MKPinAnnotationView(annotation: annotation, reuseIdentifier: identifier)
                view.canShowCallout = true
                view.calloutOffset = CGPoint(x: -5,y: 5)
                view.rightCalloutAccessoryView = UIButton.buttonWithType(.DetailDisclosure) as! UIView
            }
            return view
        }
        return nil
    }
    
    // func mapItem() -> MKMapItem
}




