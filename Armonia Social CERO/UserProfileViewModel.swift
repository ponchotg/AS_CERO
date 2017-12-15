//
//  UserProfileViewModel.swift
//  Armonia Social CERO
//
//  Created by Alfonso Tapia on 9/8/17.
//  Copyright © 2017 Paranoid Interactive. All rights reserved.
//

import Foundation
import UIKit
import Firebase

enum GradeType:String{
    case behavior
    case performance
    
    func fbName() -> String {
        switch self {
        case .behavior:
            return "Com"
        default:
            return "Des"
        }
    }
}

class UserProfileViewModel {
    var user:User
    weak var viewController:UserProfileVMDelegate?
    var profile:UserProfile?
    
    init(delegate:UserProfileVMDelegate,user:User) {
        self.viewController = delegate
        self.user = user
        doInitialSetup()
    }
    
    func getTitleFor(indexPath:IndexPath) -> String?{
        return profile?.getObjectAt(indexPath.row)
    }
    
    func getSubtitleFor(indexPath:IndexPath) -> String?{
        return profile?.getKeyAt(indexPath.row)
    }
    
    func getImage(to imageView:UIImageView){
        user.setProfilePicture(on: imageView)
    }
    
    private func doInitialSetup(){
        viewController?.updateName(to: user.name + " " + user.lastName)
        viewController?.updateArea(to: user.area)
        guard let project = Loging.sharedInstance.project else {return}
        let uid = user.uid
        let ref = Database.database().reference().child(project).child(Constants.kFirebaseProfileBranch).child(uid)
        
        ref.observeSingleEvent(of: .value, with: {
            [weak self](snapshot) in
            guard let snapDict = snapshot.value as? [String:String] else {return}
            self?.profile = UserProfile(dictionary: snapDict)
            self?.viewController?.reloadTableView()
        })
    }
}
