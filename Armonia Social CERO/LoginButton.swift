//
//  CustomViews.swift
//  Armonia Social CERO
//
//  Created by Alfonso Tapia on 7/10/17.
//  Copyright © 2017 Paranoid Interactive. All rights reserved.
//

import Foundation
import UIKit

@IBDesignable class LoginButton:UIButton{
    
    @IBInspectable var rounded:Bool = true {
        didSet{
            layer.cornerRadius = rounded ? frame.size.height / 2 : 0
        }
    }
    
}
