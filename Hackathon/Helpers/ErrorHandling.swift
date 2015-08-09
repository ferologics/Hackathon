//
//  ErrorHandling.swift
//  Makestagram
//
//  Created by Benjamin Encz on 4/10/15.
//  Copyright (c) 2015 Make School. All rights reserved.
//

import UIKit
import ConvenienceKit
import Foundation
import SystemConfiguration
import Mixpanel

/**
  This struct provides basic Error handling functionality.
*/
struct ErrorHandling {
  
  static let ErrorTitle           = "Error"
  static let ErrorOKButtonTitle   = "Ok"
  static let ErrorDefaultMessage  = "Something unexpected happened, sorry for that!"
  
  /** 
    This default error handler presents an Alert View on the topmost View Controller 
  */
      static func defaultErrorHandler(error: NSError) {
        var alert = UIAlertController(title: ErrorTitle, message: ErrorDefaultMessage, preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: ErrorOKButtonTitle, style: UIAlertActionStyle.Default, handler: nil))
        
        let window = UIApplication.sharedApplication().windows[0] as! UIWindow

        window.rootViewController?.presentViewControllerFromTopViewController(alert, animated: true, completion: nil)
      }
      
      /** 
        A PFBooleanResult callback block that only handles error cases. You can pass this to completion blocks of Parse Requests 
      */
      static func errorHandlingCallback(success: Bool, error: NSError?) -> Void {
        if let error = error {
          ErrorHandling.defaultErrorHandler(error)
        }
      }
  
    static func displayErrorForNetwork(controller: UIViewController)
    {
        let alertController = UIAlertController(
            title: "No access to the internet",
            message: "Unable to load hackathons. Check your internet connection.",
            preferredStyle: .Alert)
        
        let cancelAction = UIAlertAction(title: "Dismiss", style: .Cancel, handler: nil)
        alertController.addAction(cancelAction)
        
        let openAction = UIAlertAction(title: "Open Settings", style: .Default) { (action) in
            if let url = NSURL(string:"prefs:root") {
                UIApplication.sharedApplication().openURL(url)
            }
        }
        alertController.addAction(openAction)
        
        Mixpanel.sharedInstanceWithToken(token)
        let mixpanel = Mixpanel.sharedInstance()
        mixpanel.track("error", properties:["category":"network"])
        
        controller.presentViewController(alertController, animated: true, completion: nil)
    }
    
}

public class Reachability {
    
    class func isConnectedToNetwork() -> Bool {
        
        var zeroAddress = sockaddr_in(sin_len: 0, sin_family: 0, sin_port: 0, sin_addr: in_addr(s_addr: 0), sin_zero: (0, 0, 0, 0, 0, 0, 0, 0))
        zeroAddress.sin_len = UInt8(sizeofValue(zeroAddress))
        zeroAddress.sin_family = sa_family_t(AF_INET)
        
        let defaultRouteReachability = withUnsafePointer(&zeroAddress) {
            SCNetworkReachabilityCreateWithAddress(nil, UnsafePointer($0)).takeRetainedValue()
        }
        
        var flags: SCNetworkReachabilityFlags = 0
        if SCNetworkReachabilityGetFlags(defaultRouteReachability, &flags) == 0 {
            return false
        }
        
        let isReachable = (flags & UInt32(kSCNetworkFlagsReachable)) != 0
        let needsConnection = (flags & UInt32(kSCNetworkFlagsConnectionRequired)) != 0
        
        return (isReachable && !needsConnection) ? true : false
    }
    
}