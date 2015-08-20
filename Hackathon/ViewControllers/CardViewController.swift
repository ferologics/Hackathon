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
import EventKit
import CoreLocation
import Mixpanel

class CardViewController: UIViewController {
    
    let mixpanel = Mixpanel.sharedInstance()
    
    let store = EKEventStore()
    var accessGranted = false
    
    @IBOutlet var rootView: UIView!
    @IBOutlet weak var cardView: HackathonCardView!

    @IBOutlet var tapRecognizer: UITapGestureRecognizer!
    @IBOutlet var swipeRecognizerRight: UISwipeGestureRecognizer!
    @IBOutlet var swipeRecognizerLeft: UISwipeGestureRecognizer!

    var markdown = "register through here"
//    var htmlString = MMMarkdow
    
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
    
    var locationAllowed = CLLocationManager.locationServicesEnabled()
    var mapInfo: MapInfo?
    
    var expanded = false
    var tracking = false {
        didSet {
            
            if  tracking == true
            {
                if let name = hackathon?.name { self.mixpanel.track("tracking", properties: ["name":name]) }
                
                UIView.animateWithDuration(0.5, animations: { () -> Void in
                    self.track.highlighted = true
                    self.track.imageView!.transform = CGAffineTransformMakeRotation(CGFloat(2*M_PI))
                    self.view.layoutIfNeeded()
                })
            }
            else
            {
                UIView.animateWithDuration(0.5, animations: { () -> Void in
                    self.track.highlighted = false
                    self.track.imageView!.transform = CGAffineTransformIdentity
                    self.view.layoutIfNeeded()
                })
            }
        }
    }
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        Mixpanel.sharedInstanceWithToken(token)
    }
    
    override func viewWillAppear(animated: Bool)
    {
        UIApplication.sharedApplication().setStatusBarStyle(.LightContent, animated: true)
        
        if Reachability.isConnectedToNetwork() {
            
            updateMapView()
            updateCardView()
            watchlist.isTrackingHackathon(hackathon!, onComplete: { (isTracking) -> Void in
                self.tracking = isTracking
                
                self.initCardWithHackathon()
            })
        }
        else { ErrorHandling.displayErrorForNetwork(self) }
    }
    
    override func viewWillDisappear(animated: Bool)
    {
        UIApplication.sharedApplication().setStatusBarStyle(.Default, animated: true)
        self.mapView.delegate = nil
    }
    
    @IBAction func trackTapped(sender: AnyObject)
    {
        if (tracking == true)
        {
            self.watchlist.stopTrackingHackathon(self.hackathon!, onComplete: { (tracking) -> Void in
                
                NSNotificationCenter.defaultCenter().postNotificationName("reloadProfile", object: nil)
                self.tracking = !tracking // tracking is false
            })
        }
        else
        {
            self.watchlist.startTrackingHackathon(self.hackathon!, onComplete: { (tracking) -> Void in
                
                NSNotificationCenter.defaultCenter().postNotificationName("reloadProfile", object: nil)
                self.tracking = tracking // tracking is true
            })
        }
    }
    
    @IBAction func expandTaped(sender: AnyObject)
    { // TODO: make the animation more natural somehow?
        if (expanded == false)
        {
            expanded = true
            
            UIView.animateWithDuration(0.5)
            {
                self.expand.imageView!.transform = CGAffineTransformMakeRotation(CGFloat(M_PI))
                self.view.layoutIfNeeded()
            }
            
            let delay = 0.3 * Double(NSEC_PER_SEC)
            let time = dispatch_time(DISPATCH_TIME_NOW, Int64(delay))
            
            dispatch_after(time, dispatch_get_main_queue())
            {
                UIView.animateWithDuration(0.5)
                {
                    self.descriptionHeight.active = false
                    self.view.layoutIfNeeded()
                }
            }
        }
        else
        {
            expanded = false
            
            UIView.animateWithDuration(0.5)
            {
                self.expand.imageView!.transform = CGAffineTransformIdentity
                self.view.layoutIfNeeded()
            }
            
            let delay = 0.3 * Double(NSEC_PER_SEC)
            let time = dispatch_time(DISPATCH_TIME_NOW, Int64(delay))
            
            dispatch_after(time, dispatch_get_main_queue())
            {
                UIView.animateWithDuration(0.5)
                {
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
    @IBAction func dismissCard(sender: AnyObject)
    {
        UIView.animateWithDuration(0.5, animations: { () -> Void in
            self.cancel.imageView?.transform = CGAffineTransformMakeRotation(-CGFloat(M_PI_2))
            
            self.view.layoutIfNeeded()
        })
        
        let delay = 0.3 * Double(NSEC_PER_SEC)
        let time = dispatch_time(DISPATCH_TIME_NOW, Int64(delay))
        
        dispatch_after(time, dispatch_get_main_queue())
        {
            self.dismissViewControllerAnimated(true, completion: { () -> Void in
                println("dismissed by tap")
            })
        }
    }
    
    func gestureRecognizerShouldBegin(gestureRecognizer: UIGestureRecognizer) -> Bool { return true }
    
    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldReceiveTouch touch: UITouch) -> Bool { return true }
    
    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWithGestureRecognizer otherGestureRecognizer: UIGestureRecognizer) -> Bool { return true }
    
    @IBAction func gestureOutside(sender: AnyObject) { dismissIfOutside(sender) }
    
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
        self.name.text = hackathon?.name
        self.desc.text = hackathon?.descript

        if Reachability.isConnectedToNetwork()
        {
            HackathonHelper.setHackathonCellLogoAsynch(hackathon!, onComplete: { (image) -> Void in
                self.logo.image = image
                self.logo.contentMode = UIViewContentMode.ScaleAspectFit
            })
        } else { ErrorHandling.displayErrorForNetwork(self) }
        
        if let start = hackathon?.start, end = hackathon?.end { self.date.text = formatForCard(start, end: end) }
        
        self.ticketNames.text = ticketClassNames()
        self.ticketCosts.text = ticketClassCost()
        self.ticketAvailability.text = ticketClassAvailability()
        self.url.text = hackathon?.url!
}
    
    func formatForCard(start: NSDate, end: NSDate) -> String
    {
        var dateFormatter = NSDateFormatter()
        var dayFormatter = NSDateFormatter()
        dayFormatter.dateFormat = "d"
        dateFormatter.dateFormat = "d MMM' 'H:mm" // format date
        
        var dayString = dayFormatter.stringFromDate(start)
        var dateString = dateFormatter.stringFromDate(end)
        
        return "\(dayString)-\(dateString)"
    }
    
    func ticketClassNames() -> String
    {
        var str = ""
        if let classes = hackathon?.ticketClassesCosts
        {
            for name in classes
            {
                str += "\(name)\n"
            }
        }
        return str
    }
    
    func ticketClassCost() -> String
    {
        var str = ""
        if let classes = hackathon?.ticketClassesNames
        {
            for cost in classes
            {
                str += "\(cost)\n"
            }
        }
        return str
    }
    
    func ticketClassAvailability() -> String
    {
        var str = ""
        if let classes = hackathon?.ticketClassesOnSaleStatuses
        {
            for availability in classes
            {
                str += "\(availability.lowercaseString)\n"
            }
        }
        return str
    }
    
    func updateCardView()
    {
        cardView.layer.cornerRadius = 25
        cardView.layer.masksToBounds = true
        self.view.layoutIfNeeded()
    }
}

extension CardViewController: MKMapViewDelegate
{
    func updateMapView()
    {
        mapView.delegate = self
        
        var locationName = hackathon?.address_1!
        var address_2 = ""
        if let ad2 = hackathon?.address_2 { address_2 = ad2 }
        else {  } // no address
        
        if let point = hackathon?.geoPoint, title = hackathon?.name!, locName = locationName
        {
            centerMapOnLocation(point)
            mapInfo = MapInfo(title: title, locationName: locName, address_2: address_2, coordinate: point)
        }
        
        mapView.addAnnotation(mapInfo)
    }
    
    func centerMapOnLocation(location: PFGeoPoint)
    {
        let coordinate = CLLocation(latitude: location.latitude, longitude: location.longitude)
        let regionRadius: CLLocationDistance = 1000
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(coordinate.coordinate, regionRadius * 2.0, regionRadius * 2.0)
        mapView.setRegion(coordinateRegion, animated: true)
    }
    
    func mapView(mapView: MKMapView!, viewForAnnotation annotation: MKAnnotation!) -> MKAnnotationView!
    {
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
                view.calloutOffset = CGPoint(x: -7,y: 7)
                view.rightCalloutAccessoryView = UIButton.buttonWithType(.DetailDisclosure) as! UIView
            }
            return view
        }
        return nil
    }
    
    func mapView(mapView: MKMapView!, annotationView view: MKAnnotationView!,
        calloutAccessoryControlTapped control: UIControl!)
    {
        let location = view.annotation as! MapInfo
        let launchOptions = [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving]
        location.mapItem().openInMapsWithLaunchOptions(launchOptions)
        
        self.mixpanel.track("got directions")
    }
}

// MARK: eventstore
// MARK: -
extension CardViewController
{
    
    @IBAction func addToCallendar(sender: AnyObject)
    {
        updateAuthorizationStatusToAccessEventStore()
        
        if accessGranted
        {
//            store.saveEvent(event, span: EKSpanThisEvent, commit: true, error: &err)
//            self.savedEventId = event.eventIdentifier //save event id to access this particular event later
            
            var event = EKEvent(eventStore: store)
            event.title = hackathon?.name
            event.startDate = hackathon?.start
            event.endDate = hackathon?.end
            event.calendar = store.defaultCalendarForNewEvents
            
            let interval: NSTimeInterval = -24 * 60 * 60 * 2
            let absoluteAlarm = EKAlarm(absoluteDate: event.startDate)
            let offsetAlarm = EKAlarm(relativeOffset: interval)

            event.alarms = [absoluteAlarm, offsetAlarm]
            
            var err: NSError?
            
            store.saveEvent(event, span: EKSpanThisEvent, commit: true, error: &err)
            if ( err == nil )
            {
                self.mixpanel.track("calendar access", properties: ["granted":true])
                
                let alert = UIAlertView(title: "Let's Hack!", message: "Event added. Do you want to see it in your calendar?", delegate: self, cancelButtonTitle: "No", otherButtonTitles: "Take me there")
                alert.tag = 1
                alert.show()
            }
            else { mixpanel.track("error", properties:["category":"event"]) }
        }
    }
    
    func updateAuthorizationStatusToAccessEventStore()
    {
        let authorizationStatus = EKEventStore.authorizationStatusForEntityType(EKEntityTypeEvent)
        
        switch (authorizationStatus)
        {
            case EKAuthorizationStatus.Denied:
                return
            
            case EKAuthorizationStatus.Restricted:
                self.accessGranted = false
                let alertView = UIAlertView(title: "Access Denied", message: "This app doesn't have access to your calendar, to add event enable access in settings", delegate: self, cancelButtonTitle: "Dismiss")
                alertView.show()
            
            case EKAuthorizationStatus.Authorized:
                self.accessGranted = true
                
            self.mixpanel.track("calendar", properties: ["access granted":true])
            
            case EKAuthorizationStatus.NotDetermined:
                store.requestAccessToEntityType(EKEntityTypeEvent, completion: { (granted, error) -> Void in
                    
                    dispatch_async(dispatch_get_main_queue()) { self.accessGranted = granted }
            })
        }
    }
    
    func openEventDayInCalendar()
    {
        if let day = hackathon?.start
        {
            let today = NSDate()
            let timeSince = NSDate.timeIntervalSinceReferenceDate() // this plus
            let todayToFutureDate = day.timeIntervalSinceDate(today)
            let finalInterval = todayToFutureDate + timeSince
            
            self.mixpanel.track("calendar", properties: ["opened" : true])
            
            UIApplication.sharedApplication().openURL(NSURL(string: "calshow:\(finalInterval)")!)
        }
    }
}

extension CardViewController: UIAlertViewDelegate
{
    func alertView(alertView: UIAlertView, clickedButtonAtIndex buttonIndex: Int)
    {
        if alertView.tag == 1
        {
            switch buttonIndex
            {
                case 0: self.mixpanel.track("calendar", properties: ["opened" : false])
                case 1: openEventDayInCalendar()
                default: return
            }
        }
    }
}



