//
//  VMDelegate.swift
//  Armonia Social CERO
//
//  Created by Alfonso Tapia on 7/20/17.
//  Copyright © 2017 Paranoid Interactive. All rights reserved.
//

import Foundation
import UIKit

protocol VMDelegate:class {
    func present(_ viewControllerToPresent:UIViewController, animated: Bool, completion: (() -> Void)?)
}

extension VMDelegate{
    func presentAlert(alert:UIAlertController){
        DispatchQueue.main.async {
            [weak self] in
            self?.present(alert, animated: true, completion: nil)
        }
    }
}

protocol VMTVDelegate:VMDelegate {
    weak var tableView:UITableView!{get set}
}

extension VMTVDelegate{
    func reloadTableView(){
        DispatchQueue.main.async {
            [weak self] in
            self?.tableView.reloadData()
        }
    }
}

protocol BasicInfoVMDelegate:class {
    weak var nameLabel:UILabel!{get set}
    weak var areaLabel:UILabel!{get set}
}

extension BasicInfoVMDelegate{
    func updateName(to text:String){
        DispatchQueue.main.async {
            [weak self] in
            self?.nameLabel.text = text
        }
    }
    func updateArea(to text:String){
        DispatchQueue.main.async {
            [weak self] in
            self?.areaLabel.text = text
        }
    }
}

protocol LogginViewModelDelegate:VMDelegate{
    func showLoadingViewWith(text:String)
    func changeLoadingViewText(to:String)
    func removeLoadingView()
    func performLogingSegue()
}

protocol HomeVMDelegate:VMTVDelegate,BasicInfoVMDelegate{
    func updateScoreLabel(to text:String)
    func updateScore(type:SearchType, to text:String)
}

protocol EditProfileVMDelegate:VMDelegate{
    func updateHobbie(to text:String)
    func updatePosition(to text:String)
    func updateEmail(to text:String)
    func updateQuote(to text:String)
    func updateImageView(with image:UIImage)
    func returnToPreviousView()
}

protocol UserPickerTableVMDelegate:VMTVDelegate {}
protocol UserProfileVMDelegate:VMTVDelegate,BasicInfoVMDelegate {}
protocol UserGradingVMDelegate:VMDelegate, BasicInfoVMDelegate{
    func returnToPreviousView()
}
