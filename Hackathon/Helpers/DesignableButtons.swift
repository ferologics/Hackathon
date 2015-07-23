//
//  Designable.swift
//  Hackathon
//
//  Created by master on 7/22/15.
//  Copyright (c) 2015 ferologics. All rights reserved.
//

import UIKit

@IBDesignable class DesignableButtons: UIButton {
    
    @IBInspectable var cornerRadius:CGFloat? {
        didSet{
            self.layer.cornerRadius = cornerRadius
        }
    }
    
}