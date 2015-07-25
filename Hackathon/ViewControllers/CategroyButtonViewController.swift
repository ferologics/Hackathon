
//
//  CategroyButtonViewController.swift
//  Hackathon
//
//  Created by master on 7/24/15.
//  Copyright (c) 2015 ferologics. All rights reserved.
//

import UIKit
import LGPlusButtonsView

class CategroyButtonViewController: UIViewController {

    @IBOutlet weak var categoryButtons: LGPlusButtonsView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        LGPlusButtonsView(view: categoryButtons, numberOfButtons: 4, showsPlusButton: true, delegate: self)
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    



    
    

}

extension SearchViewController: LGPlusButtonsViewDelegate {
    
    func plusButtonsView(plusButtonsView: LGPlusButtonsView!, buttonPressedWithTitle title: String!, description: String!, index: UInt) {
        //code
    }
    func plusButtonsViewPlusButtonPressed(plusButtonsView: LGPlusButtonsView!) {
        //code
    }
}