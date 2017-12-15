//
//  EditProfileViewModel.swift
//  Armonia Social CERO
//
//  Created by Alfonso Tapia on 7/26/17.
//  Copyright © 2017 Paranoid Interactive. All rights reserved.
//

import Foundation
import UIKit
import Firebase

class EditProfileViewModel:NSObject,UIImagePickerControllerDelegate{
    weak var viewController:EditProfileVMDelegate?
    
    init(delegate:EditProfileVMDelegate) {
        super.init()
        viewController = delegate
    }
    
    func initialSetup(){
        guard let project = Loging.sharedInstance.project else {return}
        guard let uid = Loging.sharedInstance.userId else {return}
        let ref = Database.database().reference().child(project).child(Constants.kFirebaseProfileBranch).child(uid)
        ref.observeSingleEvent(of: .value, with: {
            [weak self](snapshot) in
            guard let snapDict = snapshot.value as? [String:String] else {return}
            for (key,val) in snapDict{
                switch key{
                case "PersonalQuote":
                    self?.viewController?.updateQuote(to: val)
                case "Position":
                    self?.viewController?.updatePosition(to: val)
                case "Hobbie":
                    self?.viewController?.updateHobbie(to: val)
                case "Email":
                    self?.viewController?.updateEmail(to: val)
                default:
                    print("Something is not right")
                    break
                }
            } 
        })
    }
    
    func setUserPicture(to imageView:UIImageView){
        Loging.sharedInstance.mainUser?.setProfilePicture(on: imageView)
    }
    
    func userDidSelectImage(image:UIImage){
        guard let project = Loging.sharedInstance.project else {return}
        guard let name = Loging.sharedInstance.mainUser?.name else {return}
        guard let last = Loging.sharedInstance.mainUser?.lastName else {return}
        do{
            let resizedImage = try ImageHandler.resizeImage(image: image, targetSize: CGSize(width: 500, height: 500))
            let pngImage = try ImageHandler.makePng(image: resizedImage)
            let storageRef = Storage.storage().reference().child("\(project)/\(name)\(last).png")
            let uploadTask = storageRef.putData(pngImage, metadata: nil) {
                (metadata, error) in
                guard let metadata = metadata else {
                    let settings = AlertSettings(title: "Error", message: "Se produjo un error al subir la imagen, Intente de nuevo más tarde")
                    let alert = Alert.getAlert(type: .simple, settings: settings)
                    self.viewController?.presentAlert(alert: alert)
                    return
                }
                guard let downloadURL = metadata.downloadURL() else {return}
                self.saveImageUrlToFirebase(url: downloadURL)
                self.viewController?.updateImageView(with: resizedImage)
            }
            uploadTask.resume()
        } catch let error {
            print(error.localizedDescription)
            let settings = AlertSettings(title: "Error", message: "Se produjo un error al subir la imagen, Intente de nuevo más tarde")
            let alert = Alert.getAlert(type: .simple, settings: settings)
            self.viewController?.presentAlert(alert: alert)
        }
    }
    
    func saveProfileToFirebase(profile:[String:String]){
        guard let project = Loging.sharedInstance.project else {return}
        guard let uid = Loging.sharedInstance.userId else {return}
        let ref = Database.database().reference().child(project).child(Constants.kFirebaseProfileBranch).child(uid)
        ref.setValue(profile)
        self.viewController?.returnToPreviousView()
    }
    
    func saveImageUrlToFirebase(url:URL){
        guard let project = Loging.sharedInstance.project else {return}
        guard let uid = Loging.sharedInstance.userId else {return}
        let ref = Database.database().reference().child(project).child(Constants.kFirebaseUserBranch).child(uid).child("Picture")
        ref.setValue(url.absoluteString)
        Loging.sharedInstance.mainUser?.updateUserPicture(url: url.absoluteString)
    }
}
