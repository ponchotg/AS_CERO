//
//  User.swift
//  Armonia Social CERO
//
//  Created by Alfonso Tapia on 6/17/17.
//  Copyright © 2017 Paranoid Interactive. All rights reserved.
//

import Foundation
import UIKit
import Firebase



enum SearchType {
    case behavior
    case performance
}

class User:NSObject{
    private (set) var uid:String
    private (set) var name:String
    private (set) var lastName:String
    private (set) var key:Int
    private (set) var level:Int
    private (set) var area:String
    private (set) var pictureUrl:String?
    
    //MARK: Init
    
    init(uuid:String,dictionary:[String:Any]) throws {
        guard let name = dictionary["Name"] as? String else {throw UserError.lineNotFound("Name")}
        guard let lName = dictionary["LastName"] as? String else {throw UserError.lineNotFound("lastName")}
        guard let level = dictionary["Level"] as? Int else {throw UserError.lineNotFound("Level")}
        guard let area = dictionary["Area"] as? String else {throw UserError.lineNotFound("Area")}
        guard let key = dictionary["Key"] as? Int else {throw UserError.lineNotFound("Key")}
        self.uid = uuid
        self.name = name
        self.lastName = lName
        self.key = key
        self.level = level
        self.area = area
        self.pictureUrl = dictionary["Picture"] as? String
    }
    
    //MARK: Class Functionality
    func setProfilePicture(on view:UIImageView) {
        guard let pictureUrl = pictureUrl else {return}
        if let image = GlobalProperties.shared.imageCache.object(forKey: pictureUrl as NSString){
            DispatchQueue.main.async {
                view.image = image
            }
        } else {
            Networking.downloadData(from: pictureUrl, completionHandler: {
                (error, data) in
                guard error == nil else {return}
                guard let data = data else {return}
                guard let image = UIImage(data: data) else {return}
                GlobalProperties.shared.imageCache.setObject(image, forKey: pictureUrl as NSString)
                DispatchQueue.main.async {
                    view.image = image
                }
            })
        }
    }
    
    func updateUserPicture(url:String){
        self.pictureUrl = url
    }
    
}

class MainUser:User{
    private (set) var pScore:Double
    private (set) var bScore:Double
    @objc dynamic private (set) var pComments = NSCountedSet()
    @objc dynamic private (set) var bComments = NSCountedSet()
    
    override init(uuid:String,dictionary:[String:Any]) throws {
        guard let scoreb = dictionary["BScore"] as? Double else {throw UserError.hasNoScore(.behavior)}
        guard let scorep = dictionary["PScore"] as? Double else {throw UserError.hasNoScore(.performance)}
        self.bScore = scoreb
        self.pScore = scorep
        do{
            try super.init(uuid: uuid, dictionary: dictionary)
        } catch let error as UserError {
            throw error
        }
        
    }
    
    func getMainUserInfo(){
        guard let project = Loging.sharedInstance.project else {return}
        let referenceb = Database.database().reference().child(project).child("Reportes").child("Com").child(self.uid)
        let referencec = Database.database().reference().child(project).child("Reportes").child("Des").child(self.uid)
        referenceb.observe(.childAdded, with: getObserveFunction(for: .behavior))
        referencec.observe(.childAdded, with: getObserveFunction(for: .performance))
    }
    
    func getObserveFunction(for searchType:SearchType) -> (DataSnapshot) -> Void{
        return {
            (snapshot) in
            var aComment = NSCountedSet()
            if searchType == .behavior {aComment = self.bComments}
            if searchType == .performance {aComment = self.pComments}
            guard let dict = snapshot.value as? [String:Any] else {return}
            guard let options = dict["Options"] as? [String:String] else {return}
            for (_,value) in options{
                aComment.add(value)
            }
            if searchType == .behavior {self.bComments = aComment}
            if searchType == .performance {self.pComments = aComment}
        }
    }
    
    func getComents(top:Int, type:SearchType)throws -> [String]{
        var searchSet = NSCountedSet()
        if type == .behavior {
            searchSet = bComments
        } else {
            searchSet = pComments
        }
        guard searchSet.count >= top else {throw UserError.notEnoughComments(type)}
        let array:[String] = searchSet.flatMap{
            return $0 as? String
        }
        let sorted = array.sorted{searchSet.count(for: $0) > searchSet.count(for: $1)}
        print(sorted.prefix(top).filter{$0 == $0})
        return sorted.prefix(top).filter{$0 == $0}
    }
    
    
}

struct UserProfile {
    var hobbie:String?
    var quote:String?
    var position:String?
    var email:String?
    var count:Int {
        var simpleCount = 0
        if self.hobbie != nil {simpleCount += 1}
        if self.quote != nil {simpleCount += 1}
        if self.position != nil {simpleCount += 1}
        if self.email != nil {simpleCount += 1}
        return simpleCount
        
    }
    
    init(dictionary:[String:String]) {
        for (key,val) in dictionary{
            switch key{
            case "PersonalQuote":
                quote = val
            case "Position":
                position = val
            case "Hobbie":
                hobbie = val
            case "Email":
                email = val
            default:
                print("Something is not right")
                break
            }
        }
    }
    
    func getKeyAt(_ position:Int) -> String{
        switch position {
        case 0:
            return "Puesto"
        case 1:
            return "Hobbie"
        case 0:
            return "Frase Personal"
        case 0:
            return "E-Mail"
        default:
            return "Error Desconocido"
        }
    }
    
    func getObjectAt(_ position:Int) -> String?{
        switch position {
        case 0:
            return self.position
        case 1:
            return self.hobbie
        case 2:
            return self.quote
        case 3:
            return self.email
        default:
            return nil
        }
    }
}

