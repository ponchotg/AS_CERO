//
//  LogginViewModel.swift
//  Armonia Social CERO
//
//  Created by Alfonso Tapia on 6/18/17.
//  Copyright © 2017 Paranoid Interactive. All rights reserved.
//

import Foundation
import UIKit
import MBProgressHUD
import LocalAuthentication
import SwiftKeychainWrapper


class LogginViewModel{
    
    var usrData:(email:String,pass:String)?
    weak var viewController:LogginViewModelDelegate?
    lazy var context = LAContext()
    
    init(delegate:LogginViewModelDelegate) {
        self.viewController = delegate
        Loging.sharedInstance.delegate = self
    }
    
    deinit {
        print("Deinit Logging ViewModel")
    }
    
    
    //MARK:LogginViewController Functions
    
    func logginUserWith(email:String?, password:String?, TID:Bool = false){
        print("Starting Loggin")
        viewController?.showLoadingViewWith(text: "Verificando Usuario")
        var fields = (email: "", pass: "")
        do{
            if TID {
                guard let pass = KeychainWrapper.standard.string(forKey: GlobalProperties.PassKey) else {return}
                fields = try testEmailAndPassword(email: getUserEmail(), pass: pass)
            } else {
                fields = try testEmailAndPassword(email: email, pass: password)
            }
            viewController?.changeLoadingViewText(to: "Autentificando")
            Loging.sharedInstance.logginWith(userName: fields.email, password: fields.pass)
            usrData = fields
        } catch let error {
            var message = AlertSettings(title: "Error", message: "")
            switch error {
                case UserPassError.emptyField(let field):
                    message.message = "Campo de \(field) no puede estar vacío"
                case UserPassError.notEmailForm():
                    message.message = "El usuario no tiene un formato valido"
                case UserPassError.shortPassword():
                    message.message = "Contraseña incorrecta o muy corta"
                default:
                    message.message = error.localizedDescription
            }
            let alert = Alert.getAlert(type: .simple, settings: message, completions: {
                [unowned self] in
                self.viewController?.removeLoadingView()
            })
            viewController?.presentAlert(alert: alert)
        }
    }
    
    func touchIDFailed(error:Error){
        var message = AlertSettings(title: "Error", message: "")
        switch error {
        case LAError.authenticationFailed:
            message.message = "Problema verificando Identidad"
        default:
            message.message = error.localizedDescription
        }
        let alert = Alert.getAlert(type: .simple, settings: message)
        viewController?.presentAlert(alert: alert)
    }
    
    func checkLocalAuthAvailable(email:String) -> Bool{
        let first = context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: nil)
        let second = email == getUserEmail()
        guard let third = UserDefaults.standard.object(forKey: GlobalProperties.tidEnabled) as? Bool else {return false}
        return first && second && third
    }
    
    func storeUserName() {
        guard let usrData = usrData else {return}
        let userDefaults = UserDefaults.standard
        userDefaults.set(usrData.email, forKey: GlobalProperties.userKey)
    }
    
    func storeNameAndPassToKeyChain(){
        guard let usrData = usrData else {return}
        let userDefaults = UserDefaults.standard
        KeychainWrapper.standard.set(usrData.pass, forKey: GlobalProperties.PassKey)
        userDefaults.set(true, forKey: GlobalProperties.tidEnabled)
        userDefaults.synchronize()
        
    }
    
    func logginViewWillDisapear(){
        Loging.sharedInstance.delegate = nil
    }
    
    func performFinalSegue(){
        Loging.sharedInstance.mainUser?.getMainUserInfo()
        GlobalFunctions.delayAfter(seconds: 3){
            self.viewController?.removeLoadingView()
            self.viewController?.performLogingSegue()
        }
    }
    
    //MARK:ReturningFunctions
   
    func getUserEmail() -> String? {
        guard let email = UserDefaults.standard.object(forKey: GlobalProperties.userKey) as? String else {return nil}
        return email
    }
    
    //MARK: Private Functions
    
    private func testEmailAndPassword(email:String?,pass:String?)throws -> (email:String, pass:String){
        guard let email = email else {throw UserPassError.emptyField(field: "Usuario")}
        guard let pass = pass else {throw UserPassError.emptyField(field: "Contraseña")}
        guard pass.count >= 6 else {throw UserPassError.shortPassword()}
        guard email.isValidEmail() else {throw UserPassError.notEmailForm()}
        return (email,pass)
    }
    
}



//MARK:LogginDelegate
extension LogginViewModel:LogginDelegate{
    func applicationDidSetUser() {
        print("loaded main user")
        self.storeUserName()
        GlobalFunctions.delayAfter(seconds: 1){
            self.performFinalSegue()
        }
        guard context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: nil) else {return}
        if let third = UserDefaults.standard.object(forKey: GlobalProperties.tidEnabled) as? Bool{
            guard !third else {return}
        }
        let settings = AlertSettings(title:"Touch ID",message:"Te gustaría usar TouchId en tu proximo Login")
        let alert = Alert.getAlert(type: .binary, settings: settings) {
            self.storeNameAndPassToKeyChain()
        }
        viewController?.presentAlert(alert: alert)
        
        
    }
    
    func applicationChangedLoginState(to newState:Bool) {
        guard newState == true else {return}
        self.viewController?.changeLoadingViewText(to: "Descargando datos de Usuario")
    }
    
    func applicationFailedLogginWith(error: String) {
        usrData = nil
        let settings = AlertSettings(title: "Error", message: error)
        let alert = Alert.getAlert(type: .simple, settings: settings) {
            [unowned self] in
            self.viewController?.removeLoadingView()
        }
        viewController?.presentAlert(alert: alert)
    }
}
