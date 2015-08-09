//
//  AppDelegate.swift
//  Hackathon
//
//  Created by Master on 7/7/15.
//  Copyright (c) 2015 ferologics. All rights reserved.
//

import UIKit
import Parse
import FBSDKCoreKit
import ParseUI
import ParseFacebookUtilsV4
import Mixpanel

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var overlay : UIView?
    var parseLoginHelper: ParseLoginHelper!

    override init() {
        super.init()
        
        parseLoginHelper = ParseLoginHelper {[unowned self] user, error in
            // Initialize the ParseLoginHelper with a callback
            if let error = error {
                // 1
                ErrorHandling.defaultErrorHandler(error)
                
                Mixpanel.sharedInstanceWithToken(token)
                let mixpanel = Mixpanel.sharedInstance()
                mixpanel.track("error", properties:["category":"login"])
                
            } else  if let user = user {
                // if login was successful, display the TabBarController
                // 2    
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let tabBarController = storyboard.instantiateViewControllerWithIdentifier("SearchViewController") as! UIViewController
                // 3
                self.window?.rootViewController!.presentViewController(tabBarController, animated:true, completion:nil)
            }
        }
    }

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
    
        
        Mixpanel.sharedInstanceWithToken(token)
        let mixpanel = Mixpanel.sharedInstance()
        mixpanel.track("App launched")
        
        if application.applicationState == UIApplicationState.Inactive {
            NSNotificationCenter.defaultCenter().postNotificationName("reloadSearchView", object: nil)
        }
        
        Parse.setApplicationId("1kQEKpgZG525SU9GiCXl4xkrpbiwjy5OpZK9QKlA", clientKey: "XWXzoPY6cVmBPjzJwBkGaXUm6qvHjkjjLl9NLHYb")
        
        PFFacebookUtils.initializeFacebookWithApplicationLaunchOptions(launchOptions)
        
        // check if we have logged in user
        // 2
        
        let user = PFUser.currentUser()
        
        let startViewController: UIViewController;
        
        if (user != nil) {
            // 3
            // if we have a user, set the SearchViewController to be the initial View Controller
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            startViewController = storyboard.instantiateViewControllerWithIdentifier("SearchViewController") as! UIViewController
        } else {
            // 4
            // Otherwise set the LoginViewController to be the first
            let loginViewController = PFLogInViewController()
            loginViewController.fields = .Facebook //.UsernameAndPassword | .LogInButton | .SignUpButton | .PasswordForgotten |
            loginViewController.delegate = parseLoginHelper
            loginViewController.signUpController?.delegate = parseLoginHelper
            loginViewController.facebookPermissions = ["email","user_friends","public_profile"]
            
            var asdView = UIView()
            var logoImageLog = UIImageView()
            logoImageLog.image = UIImage(named: "splash")
            
            asdView.addSubview(logoImageLog)
            
            loginViewController.logInView?.logo = asdView
            
//            var logoImageReg = UIImageView()
//            logoImageReg.image = UIImage(named: "AppIcon")
//            loginViewController.signUpController?.signUpView?.logo = logoImageReg
            
            startViewController = loginViewController
        }
        
        // 5
        self.window = UIWindow(frame: UIScreen.mainScreen().bounds)
        self.window?.rootViewController = startViewController
        self.window?.makeKeyAndVisible()
        
        let acl = PFACL()
        acl.setPublicReadAccess(true)
        PFACL.setDefaultACL(acl, withAccessForCurrentUser: true)
        
        return FBSDKApplicationDelegate.sharedInstance().application(application, didFinishLaunchingWithOptions: launchOptions)
    }
    
    func applicationDidBecomeActive(application: UIApplication) {
        FBSDKAppEvents.activateApp()
    }
    
    func application(application: UIApplication, openURL url: NSURL, sourceApplication: String?, annotation: AnyObject?) -> Bool {
        return FBSDKApplicationDelegate.sharedInstance().application(application, openURL: url, sourceApplication: sourceApplication, annotation: annotation)
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

