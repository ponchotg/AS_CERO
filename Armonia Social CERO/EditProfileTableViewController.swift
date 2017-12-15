//
//  EditProfileTableViewController.swift
//  Armonia Social CERO
//
//  Created by Alfonso Tapia on 7/26/17.
//  Copyright © 2017 Paranoid Interactive. All rights reserved.
//

import Foundation
import UIKit

class EditProfileTableViewController:UITableViewController{
    @IBOutlet weak var profilePicture:UIImageView!
    @IBOutlet weak var changePictureBtn:UIButton!
    @IBOutlet weak var nameLabel:UILabel!
    @IBOutlet weak var areaLabel:UILabel!
    @IBOutlet weak var personalQuote:UITextField!
    @IBOutlet weak var position:UITextField!
    @IBOutlet weak var hobbie:UITextField!
    @IBOutlet weak var email:UITextField!
    var viewInitialPosition:CGRect?
    var keyboardFrame:CGRect = CGRect()
    lazy var viewModel:EditProfileViewModel = EditProfileViewModel(delegate: self)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.backgroundView = UIImageView(image: #imageLiteral(resourceName: "tryjpeg"))
        viewModel.initialSetup()
        self.tableView.isScrollEnabled = false
        self.tableView.tableFooterView = UIView()
        personalQuote.delegate = self
        position.delegate = self
        hobbie.delegate = self
        email.delegate = self
        viewModel.setUserPicture(to: profilePicture)
        
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
    
    @objc func keyboardWillShow(_ notification: Notification){
        guard let info = (notification as NSNotification).userInfo else {return}
        self.keyboardFrame = (info[UIKeyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        let duration = info[UIKeyboardAnimationDurationUserInfoKey] as! Double
        animateViewOffsetFromKeyboard(duration: duration)
    }
    
    @objc func keyboardWillHide(_ notification: Notification){
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
            self.tableView.contentOffset = CGPoint(x: iP.minX, y: ypos)
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
    
    @IBAction func saveChanges(){
        var dict:[String:String] = [:]
        if let pqText = personalQuote.text {
            dict["PersonalQuote"] = pqText
        }
        if let positionText = position.text{
            dict["Position"] = positionText
        }
        if let hobbieText = hobbie.text{
            dict["Hobbie"] = hobbieText
        }
        if let emailText = email.text{
            dict["Email"] = emailText
        }
        guard dict.count > 0 else {return}
        viewModel.saveProfileToFirebase(profile: dict)
    }
    
    @IBAction func changeDefaultImage(_ sender:AnyObject){
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.allowsEditing = false
        imagePicker.sourceType = .photoLibrary
        self.present(imagePicker, animated: true)
    }
}

extension EditProfileTableViewController:EditProfileVMDelegate{
    
    func updateEmail(to text:String) {
        DispatchQueue.main.async {
            [weak self] in
            self?.email.text = text
        }
    }
    
    func updateQuote(to text:String) {
        DispatchQueue.main.async {
            [weak self] in
            self?.personalQuote.text = text
        }
    }
    
    func updateHobbie(to text:String) {
        DispatchQueue.main.async {
            [weak self] in
            self?.hobbie.text = text
        }
    }
    
    func updatePosition(to text:String) {
        DispatchQueue.main.async {
            [weak self] in
            self?.position.text = text
        }
    }
    
    func updateImageView(with image:UIImage){
        DispatchQueue.main.async {
            [weak self] in
            self?.profilePicture.image = image
        }
    }
    
    func returnToPreviousView() {
        self.navigationController?.popToRootViewController(animated: true)
    }
    
}

extension EditProfileTableViewController:UITextFieldDelegate{
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard string == "\n" else {return false}
        textField.resignFirstResponder()
        return true
    }
}

extension EditProfileTableViewController:UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            self.viewModel.userDidSelectImage(image: image)
        } else{
            print("Something went wrong")
        }
        
        self.dismiss(animated: true)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        self.dismiss(animated: true)
    }
}

class SubEditProfileTableViewController:EditProfileTableViewController{
    @IBOutlet weak var menuButton:UIBarButtonItem!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.revealViewControllerSetup(with: menuButton)
    }
}
