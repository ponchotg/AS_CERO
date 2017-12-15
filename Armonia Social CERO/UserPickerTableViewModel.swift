//
//  UserPickerTableViewModel.swift
//  Armonia Social CERO
//
//  Created by Alfonso Tapia on 8/31/17.
//  Copyright © 2017 Paranoid Interactive. All rights reserved.
//

import Foundation
import UIKit
import Firebase

enum UserSelectionType{
    case area
    case alphabetical
    case filtered(with:[String])
    
    func base() -> Int {
        switch self {
        case .alphabetical:
            return 0
        case .area:
            return 1
        default:
            return 2
        }
    }
}

class UserPickerTableViewModel {
    
    var users:[User]?
    var areaUsers:[String:[User]]?
    var areaSet:[String]?
    var filteredUsers:[User]?
    var selectedUser:User?
    weak var viewController:UserPickerTableVMDelegate?
    
    init (delegate:UserPickerTableVMDelegate){
        self.viewController = delegate
    }
    
    func initialSetup(){
        guard let usersList = Loging.sharedInstance.userList else {return}
        self.users = usersList.sorted{$0.name < $1.name}
        updateTableView()
        sortUsersByArea()
    }
    
    func updateTableView(){
        viewController?.reloadTableView()
    }
    
    //MARK:TableViewFunctions
    func getNumberOfSections(for searchType:UserSelectionType) -> Int{
        guard searchType.base() == 1 else {return 1}
        return areaUsers?.count ?? 0
    }
    
    func getNumberOfRows(for section:Int, searchType:UserSelectionType) -> Int{
        switch searchType {
        case .alphabetical:
            return users?.count ?? 0
        case .area:
            guard let areaName = areaSet?[section] else {return 0}
            return areaUsers?[areaName]?.count ?? 0
        case .filtered(with: let arr):
            guard let users = users else {return 0}
            let mfilteredUsers:[User] = users.filter{
                if arr.count > 1{
                    return ($0.name.contains(arr[0]) && $0.lastName.contains(arr[1]) || ($0.name.contains(arr[1]) && $0.lastName.contains(arr[0])))
                } else {
                    return ($0.name.checkMatching(arr) || $0.lastName.checkMatching(arr))
                }
            }
            filteredUsers = mfilteredUsers
            return mfilteredUsers.count
        }
    }
    
    func getUser(for indexPath:IndexPath,searchType:UserSelectionType) -> User?{
        switch searchType {
        case .alphabetical:
            return users?[indexPath.row]
        case .area:
            guard let areaName = areaSet?[indexPath.section] else {return nil}
            return areaUsers?[areaName]?[indexPath.row]
        case .filtered(with: _):
            return filteredUsers?[indexPath.row]
        }
    }
    
    func sortUsersByArea(){
        guard let users = users else {return}
        guard users.count > 1 else {return}
        DispatchQueue.global().async {
            let aSet = Set(users.flatMap{$0.area})
            self.areaSet = aSet.flatMap{String($0)}.sorted{$0 < $1}
            print(self.areaSet!)
            self.areaUsers = [:]
            for area in self.areaSet!{
                self.areaUsers?[area] = users.filter{$0.area == area}
            }
        }
    }
    
}
