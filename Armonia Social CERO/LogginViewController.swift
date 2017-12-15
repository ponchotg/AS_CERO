//
//  ViewController.swift
//  Armonia Social CERO
//
//  Created by Alfonso Tapia on 6/4/17.
//  Copyright © 2017 Paranoid Interactive. All rights reserved.
//

import UIKit
import MBProgressHUD


class LogginViewController: UIViewController, LogginViewModelDelegate {
    
    //MARK:Properties
    
    @IBOutlet weak var passField:UITextField!
    @IBOutlet weak var userField:UITextField!
    @IBOutlet weak var logginBtn:LoginButton!
    var keyboardFrame: CGRect = CGRect.null
    var keyboardIsShowing: Bool = false
    var viewInitialPosition: CGRect?
    private var proggressHUD:MBProgressHUD?
    lazy var viewModel:LogginViewModel = LogginViewModel(delegate:self)
    
    //MARK: UIViewController
    
    override func viewDidLoad() {
        super.viewDidLoad()
        guard let email = viewModel.getUserEmail() else {return}
        userField.text = email
        guard viewModel.checkLocalAuthAvailable(email: email) else {return}
        viewModel.context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: "Inicia Sesión con TouchID", reply: {
            succes, error in
            guard succes else {self.viewModel.touchIDFailed(error: error!);return}
            self.viewModel.logginUserWith(email: email, password: nil, TID: succes)
        })
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        viewModel.viewController = nil
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    //MARK: User Interaction
    
    @IBAction func logginClick(sender:AnyObject){
        viewModel.logginUserWith(email: userField.text, password: passField.text)
        textViewsResignFirstResponder()
    }
    
    //MARK: ViewModelDelegate
    
    func showLoadingViewWith(text:String){
        DispatchQueue.main.async {
            [unowned self] in
            self.proggressHUD = MBProgressHUD.showAdded(to: self.view, animated: true)
            self.proggressHUD?.label.text = text
        }
    }
    
    func changeLoadingViewText(to message:String){
        DispatchQueue.main.async {
            [weak self] in
            self?.proggressHUD?.label.text = message
        }
    }
    
    func removeLoadingView(){
        DispatchQueue.main.async {
            [weak self] in
            self?.proggressHUD?.hide(animated: true)
        }
    }
    
    func performLogingSegue() {
        DispatchQueue.main.async {
            [weak self] in
            self?.performSegue(withIdentifier: "toNormalView", sender: self)
        }
    }

}

extension LogginViewController:UITextFieldDelegate{
    
    override func viewDidAppear(_ animated: Bool) {
        passField.delegate = self
        userField.delegate = self
        self.viewInitialPosition = self.view.frame
        NotificationCenter.default.addObserver(
            self, selector: #selector(keyboardWillShow(_:)),
            name: NSNotification.Name.UIKeyboardWillShow,
            object: nil)
        NotificationCenter.default.addObserver(
            self, selector: #selector(keyboardWillHide(_:)),
            name: NSNotification.Name.UIKeyboardWillHide,
            object: nil)
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard string == "\n" else {return true}
        if textField === passField{
            viewModel.logginUserWith(email: userField.text, password: passField.text)
        }
        textField.resignFirstResponder()
        return false
    }
    
    @objc func keyboardWillShow(_ notification: Notification){
        self.keyboardIsShowing = true
        guard let info = (notification as NSNotification).userInfo else {return}
        self.keyboardFrame = (info[UIKeyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        let duration = info[UIKeyboardAnimationDurationUserInfoKey] as! Double
        animateViewOffsetFromKeyboard(duration: duration)
    }
    
    @objc func keyboardWillHide(_ notification: Notification){
        self.keyboardIsShowing = false
        guard let info = (notification as NSNotification).userInfo else {return}
        let duration = info[UIKeyboardAnimationDurationUserInfoKey] as! Double
        self.animateViewToInitialFrame(duration: duration)
    }
    
    func animateViewOffsetFromKeyboard(duration:Double){
        guard let iP = viewInitialPosition else {return}
        UIView.animate(withDuration: duration){
            [unowned self] in
            let ypos = iP.minY - self.keyboardFrame.size.height
            self.view.frame = CGRect(x: iP.minX, y: ypos , width: iP.width, height: iP.height)
            self.view.layoutIfNeeded()
        }
    }
    
    func animateViewToInitialFrame(duration:Double){
        guard let initialP = viewInitialPosition else {return}
        UIView.animate(withDuration: duration){
            [weak self] in
            self?.view.frame = initialP
            self?.view.layoutIfNeeded()
        }
    }
    
    func textViewsResignFirstResponder(){
        self.passField.resignFirstResponder()
        self.userField.resignFirstResponder()
    }
}

