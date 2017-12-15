//
//  UserGradingViewModel.swift
//  Armonia Social CERO
//
//  Created by Alfonso Tapia on 9/19/17.
//  Copyright © 2017 Paranoid Interactive. All rights reserved.
//

import Foundation
import UIKit
import Firebase

class UserGradingViewModel{
    weak var viewController:UserGradingVMDelegate?
    let gradeType:GradeType
    var stars:[StarButton]?
    var user:User!
    var minimumGrade:Int = 0
    var grade = Grade()
    
    init(delegate:UserGradingVMDelegate?,gradeType:GradeType,user:User){
        self.viewController = delegate
        self.gradeType = gradeType
        self.user = user
        grade.sender = user.uid
        grade.senderLevel = user.level
        self.initialSetup()
    }
    
    func setButtonTags(for buttons:[StarButton]){
        self.stars = buttons
        stars?.enumerated().forEach{$0.element.tag = $0.offset + 1}
    }
    
    func gradeChanged(to grade:Int){
        stars?.forEach{$0.gradeChanged(to: grade)}
        self.grade.score = grade
    }
    
    func checkGradeForUpload(){
        guard grade.isReady.0 else{
            let settings = AlertSettings(title: "Error", message: "Es necesario selecciónar al menos un comentario")
            let alert = Alert.getAlert(type: .simple, settings: settings)
            viewController?.presentAlert(alert: alert)
            return
        }
        do{
            let data = try grade.asDictionary()
            self.addGradeToDataBase(options:data)
        } catch let error{
            print(error.localizedDescription)
        }
    }

    private func initialSetup(){
        viewController?.updateName(to: user.name + " " + user.lastName)
        viewController?.updateArea(to: user.area)
        self.setInitialStars()
        guard let project = Loging.sharedInstance.project else {return}
        self.getMinumumScoreSettingFor(project: project)
    }
    
    private func addGradeToDataBase(options:[String:Any]){
        //TODO: Save the grade to the Users Database
        guard let project = Loging.sharedInstance.project else {return}
        guard let date = try? DateHandler().getDateTime() else {return}
        var ref = Database.database().reference()
        ref = ref.child(project).child("Reportes").child(gradeType.fbName()).child(user.uid).child(date)
        ref.setValue(options) {
            [unowned self](error, reference) in
            var settings:AlertSettings!
            if error == nil {
                settings = AlertSettings(title: "Envío completado", message: "Calificación enviada correctamente")
            } else {
                settings = AlertSettings(title: "Error", message: "La calificación no pudo ser enviada en este momento intente nuevamente")
            }
            let alert = Alert.getAlert(type: .simple, settings: settings, completions: {
                self.viewController?.returnToPreviousView()
            })
            self.viewController?.presentAlert(alert: alert)
        }
    }
    
    private func getMinumumScoreSettingFor(project:String){
        guard let project = Loging.sharedInstance.project else {return}
        let ref = Database.database().reference().child(project).child("MinScore")
        ref.observeSingleEvent(of: .value) {
            [weak self](snapshot) in
            guard let max = snapshot.value as? Int else {return}
            self?.minimumGrade = max
        }
    }
    
    private func setInitialStars(){
        stars?.forEach{$0.gradeChanged(to: 4)}
        grade.score = 4
    }
    
    
}
