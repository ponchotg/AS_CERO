//
//  StarButton.swift
//  Armonia Social CERO
//
//  Created by Alfonso Tapia on 9/25/17.
//  Copyright © 2017 Paranoid Interactive. All rights reserved.
//

import Foundation
import UIKit

@IBDesignable
class StarButton:UIButton{
    @IBInspectable var checked:Bool = false {
        didSet{
            switchImageFor(state: checked)
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func switchImageFor(state:Bool){
        switch state{
        case true:
            self.imageView?.alpha = 1
        case false:
            self.imageView?.alpha = 0.3
        }
    }
    
    
    
    func gradeChanged(to grade:Int){
        self.checked = grade > self.tag
    }
    
}
