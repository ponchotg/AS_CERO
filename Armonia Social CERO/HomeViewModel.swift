//
//  HomeViewModel.swift
//  Armonia Social CERO
//
//  Created by Alfonso Tapia on 7/20/17.
//  Copyright © 2017 Paranoid Interactive. All rights reserved.
//

import Foundation
import UIKit

class HomeViewModel:NSObject{
    weak var viewController:HomeVMDelegate?
    var topComments:[SearchType:[String]] = [:]
    init(delegate:HomeVMDelegate){
        viewController = delegate
    }
    
    func doInitialSetup(){
        Loging.sharedInstance.mainUser?.addObserver(self, forKeyPath: "bComments", options: [.new,.old], context: nil)
        Loging.sharedInstance.mainUser?.addObserver(self, forKeyPath: "pComments", options: [.new, .old], context: nil)
        guard let mainUser = Loging.sharedInstance.mainUser else {return}
        getUpdatedArray()
        viewController?.updateName(to: mainUser.name + " " + mainUser.lastName)
        viewController?.updateScore(type: .behavior, to: String(mainUser.bScore))
        viewController?.updateScore(type: .performance, to: String(mainUser.pScore))
        viewController?.updateScoreLabel(to: String((mainUser.bScore + mainUser.pScore) / 2))
        viewController?.updateArea(to: mainUser.area)
    }
    
    func getUserPicture(to imegeView:UIImageView){
        guard let user = Loging.sharedInstance.mainUser else {return}
        user.setProfilePicture(on: imegeView)
    }
    
    //MARK: Returning Functions
    
    func getScore(of type:SearchType, to label:UILabel) -> Double?{
        switch type {
        case .behavior:
            return Loging.sharedInstance.mainUser?.bScore
        default:
            return Loging.sharedInstance.mainUser?.pScore
        }
    }
    
    
    func objectFor(section:Int) -> [String]?{
        switch section {
        case 0:
            guard let toRet = topComments[.behavior] else {return nil}
            return toRet
        case 1:
            guard let toRet = topComments[.performance] else {return nil}
            return toRet
        default:
            return nil
        }
    }
    
    func titleForSection(_ section:Int) -> String{
        if section == 0{
            return "Comportamiento"
        } else {
            return "Desempeño"
        }
    }
    
    func objectFor(indexPath:IndexPath) -> String?{
        switch indexPath.section {
        case 0:
            guard let toRet = topComments[.behavior] else {return nil}
            return toRet[indexPath.row]
        case 1:
            guard let toRet = topComments[.performance] else {return nil}
            return toRet[indexPath.row]
        default:
            return nil
        }
    }
    
    func getSectionCount() -> Int {
        var count = 0
        if let _ = topComments[.behavior] {count += 1}
        if let _ = topComments[.performance] {count += 1}
        return count
    }
    
    //MARK: KVO
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        guard let keyPath = keyPath else {return}
        guard keyPath == "pComments" || keyPath == "bComments" else {return}
        getUpdatedArray()
    }
    
    // MARK: Private
    private func getUpdatedArray(){
        guard let mainUser = Loging.sharedInstance.mainUser else {return}
        guard let bcomments = try? mainUser.getComents(top: 3, type: .behavior) else {return}
        topComments[.behavior] = bcomments
        guard let pcomments = try? mainUser.getComents(top: 3, type: .performance) else {return}
        topComments[.performance] = pcomments
        viewController?.reloadTableView()
        
    }
    
    // MARK: Deinit
    deinit{
        Loging.sharedInstance.mainUser?.removeObserver(self, forKeyPath: "pComments", context: nil)
        Loging.sharedInstance.mainUser?.removeObserver(self, forKeyPath: "bComments", context: nil)
    }
    
}
