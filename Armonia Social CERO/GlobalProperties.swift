//
//  GlobalProperties.swift
//  Armonia Social CERO
//
//  Created by Alfonso Tapia on 6/18/17.
//  Copyright © 2017 Paranoid Interactive. All rights reserved.
//

import Foundation
import UIKit

class GlobalFunctions{
    static func delayAfter(seconds:Double,closure:@escaping ()->()){
        DispatchQueue.global().asyncAfter(deadline: .now() + seconds, execute: closure)
    }
}

class GlobalProperties{
    static let shared = GlobalProperties()
    static let userKey = "UserName"
    static let PassKey = "UserASUP"
    static let tidEnabled = "HasKey"
    let imageCache = NSCache<NSString,UIImage>()
}

class Constants{
    /**NOTE: Update with the correct branch name of the Firebase folders**/
    
    //TODO: Update With Branches
    static let kFirebaseUserBranch = ""
    static let kFirebaseGradingBranch = ""
}
