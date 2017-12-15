//
//  Logging.swift
//  Armonia Social CERO
//
//  Created by Alfonso Tapia on 6/17/17.
//  Copyright © 2017 Paranoid Interactive. All rights reserved.
//

import Foundation
import UIKit
import Firebase
import LocalAuthentication

protocol LogginDelegate:class {
    func applicationDidSetUser()
    func applicationChangedLoginState(to: Bool)
    func applicationFailedLogginWith(error:String)
}

class Loging {
    
    static var sharedInstance:Loging = Loging()
    private var app = UIApplication.shared.delegate as! AppDelegate
    private var listenerHandle:AuthStateDidChangeListenerHandle?
    private (set) var userId:String?
    private (set) var project:String?
    private (set) var userList:[User]?
    private (set) var loggedIn:Bool = false {
        didSet{
            app.applicationDidChangeLogginState(to: loggedIn)
            delegate?.applicationChangedLoginState(to: loggedIn)
        }
    }
    private (set) var mainUser:MainUser? {
        didSet{
            guard mainUser != nil else {return}
            GlobalFunctions.delayAfter(seconds: 1){
                [unowned self] in
                self.delegate?.applicationDidSetUser()
            }
        }
    }
    private (set) var auth = Auth.auth()
    
    weak var delegate:LogginDelegate?
    
    func addHandler(){
        listenerHandle = auth.addStateDidChangeListener {[unowned self] (auth, user) in
            guard user == nil else {return}
            self.loggedIn = false
            self.mainUser = nil
            self.userList = nil
            self.userId = nil
        }
    }
    
    
    
    func removeLogginHandler(){
        print("Called de listener")
        self.auth.removeStateDidChangeListener(listenerHandle!)
    }
    
    private func getProject(){
        guard let uuid = userId else {return}
        let projectReference = Database.database().reference().child(Constants.kFirebaseUserBranch).child(uuid).child("Project")
        projectReference.observeSingleEvent(of: .value, with: {
            [unowned self] snapshot in
            guard let pName = snapshot.value as? String else {return}
            self.project = pName
            self.downloadUsers()
        })
    }
    
    private func downloadUsers(){
        print("downloading users")
        guard let uuid = userId else {return}
        guard let project = project else {return}
        let userReference = Database.database().reference().child(project).child(Constants.kFirebaseUserBranch)
        self.userList = []
        userReference.observe(.childAdded, with: {
            [unowned self] snapshot in
            guard let dict = snapshot.value as? [String:Any] else {return}
            let isMain = snapshot.key == uuid ? true : false
            let user = isMain ? try? MainUser(uuid: snapshot.key, dictionary: dict):try? User(uuid: snapshot.key, dictionary: dict)
            guard let aUser = user else {return}
            isMain ? self.mainUser = (aUser as! MainUser) : self.userList?.append(aUser)
        })
    }
    
    func logginWith(userName:String,password:String,completion:((String?,Error?)->())? = nil){
        print("init loggin")
        auth.signIn(withEmail: userName, password: password, completion: {
            user, error in
            completion?(user?.uid,error)
            if let user = user {
                self.userId = user.uid
                self.loggedIn = true
                self.getProject()
            } else if let error = error {
                self.delegate?.applicationFailedLogginWith(error: error.localizedDescription)
            }
            
        })
    }
    func loggoutFromFirebase(){
        do{
            try Loging.sharedInstance.auth.signOut()
        } catch let error {
            print("Logout Error \(error.localizedDescription)")
        }
        
    }
}


