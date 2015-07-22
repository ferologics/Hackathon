//
//  ProfileViewController.swift
//  Hackathon
//
//  Created by master on 7/21/15.
//  Copyright (c) 2015 ferologics. All rights reserved.
//

import UIKit

class ProfileViewController: UIViewController {

    @IBOutlet weak var switchButtom: UIButton!
    
    override func viewDidLoad() {
        switchButtom.transform = CGAffineTransformMakeRotation(CGFloat(M_PI_4))
    }
    
    @IBAction func closeAction(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    override func viewWillAppear(animated: Bool) {
        UIApplication.sharedApplication().setStatusBarStyle(.LightContent, animated: true)
    }
    
    override func viewWillDisappear(animated: Bool) {
        UIApplication.sharedApplication().setStatusBarStyle(.Default, animated: true)
    }

}
