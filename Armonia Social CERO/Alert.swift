//
//  Alert.swift
//  Armonia Social CERO
//
//  Created by Alfonso Tapia on 7/3/17.
//  Copyright © 2017 Paranoid Interactive. All rights reserved.
//

import Foundation
import UIKit



class Alert{
    
    enum AlertType{
        case simple
        case binary
    }
    
    class func getAlert(type:AlertType,settings:AlertSettings,completions:(()->())...) -> UIAlertController {
        switch type {
        case .simple where completions.count > 0:
            return getSimpleAlert(settings: settings, completion: completions[0])
        case .simple where completions.count == 0:
            return getSimpleAlert(settings: settings)
        case .simple where completions.count > 1:
            return getBinaryAlert(settings: settings, onYes: completions[0], onNo: completions[1])
        case .simple where completions.count == 1:
            return getBinaryAlert(settings: settings, onYes: completions[0])
        default:
            fatalError("AlertError: Not enough Completion Handlers dor the selected option")
        }
    }
    
    private class func getSimpleAlert(settings:AlertSettings,completion: (()->())? = nil) -> UIAlertController{
        let alert = UIAlertController(title: settings.title, message: settings.message, preferredStyle: .alert)
        let ok = UIAlertAction(title: "OK", style: .default) { (alertAction) in
            completion?()
        }
        alert.addAction(ok)
        return alert
    }
    
    private class func getBinaryAlert(settings:AlertSettings,onYes:@escaping ()->(),onNo:(()->())? = nil) -> UIAlertController{
        let alert = UIAlertController(title: settings.title, message: settings.message, preferredStyle: .alert)
        let ok = UIAlertAction(title: "Si", style: .default) { (alertAction) in
            onYes()
        }
        let notOk = UIAlertAction(title: "No", style: .cancel) { (alertAction) in
            onNo?()
        }
        alert.addAction(ok)
        alert.addAction(notOk)
        return alert
    }
}

struct AlertSettings {
    let title:String
    var message:String
}
