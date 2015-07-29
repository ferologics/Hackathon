//
//  ProfileViewController.swift
//  Hackathon
//
//  Created by master on 7/21/15.
//  Copyright (c) 2015 ferologics. All rights reserved.
//

import UIKit
import QuartzCore

class ProfileViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var switchButton: UIButton!
    
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

    func updateView() {
        view.backgroundColor = mainColor
//        switchButton.transform = CGAffineTransformMakeRotation(CGFloat(M_PI_4))
        switchButton.layer.cornerRadius = 22
        switchButton.backgroundColor = secondaryColor
    }
    
    func updateTableView() {
//        self.navigationController?.setToolbarHidden(true, animated: false)
        tableView.layer.cornerRadius = 10
//        tableView.backgroundColor = lightColor
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