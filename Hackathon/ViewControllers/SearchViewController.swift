//
//  SearchViewController.swift
//  Hackathon
//
//  Created by master on 7/21/15.
//  Copyright (c) 2015 ferologics. All rights reserved.
//

import UIKit
import BubbleTransition
import QuartzCore

class SearchViewController: UIViewController, UIViewControllerTransitioningDelegate {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var switchButton: UIButton!
    @IBOutlet weak var searchBar: UISearchBar!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateButton()
        updateSearchBar()
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Navigation

    let transition = BubbleTransition()
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let controller = segue.destinationViewController as? UIViewController {
            controller.transitioningDelegate = self
            controller.modalPresentationStyle = .Custom
        }
    }
    
    // MARK: UIViewControllerTransitioningDelegate
    
    func animationControllerForPresentedController(presented: UIViewController, presentingController presenting: UIViewController, sourceController source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        transition.transitionMode = .Present
        transition.startingPoint = switchButton.center
        transition.bubbleColor = switchButton.backgroundColor!
        return transition
    }
    
    func animationControllerForDismissedController(dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        transition.transitionMode = .Dismiss
        transition.startingPoint = switchButton.center
        transition.bubbleColor = switchButton.backgroundColor!
        return transition
    }
    
    // MARK: - custom methods
    
    func updateButton() {
        switchButton.layer.cornerRadius = 22
        switchButton.backgroundColor = secondaryColor
    }
    
    func updateSearchBar() {
        
    }
    
    func updateTableView() {
        tableView.backgroundColor = mainColor
        
    }
}
