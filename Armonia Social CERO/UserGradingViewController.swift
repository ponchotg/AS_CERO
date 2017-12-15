//
//  UserGradingViewController.swift
//  Armonia Social CERO
//
//  Created by Alfonso Tapia on 9/19/17.
//  Copyright © 2017 Paranoid Interactive. All rights reserved.
//

import Foundation
import UIKit

class UserGradingViewController:UIViewController{
    @IBOutlet weak var star1:StarButton!
    @IBOutlet weak var star2:StarButton!
    @IBOutlet weak var star3:StarButton!
    @IBOutlet weak var star4:StarButton!
    @IBOutlet weak var star5:StarButton!
    @IBOutlet weak var nameLabel:UILabel!
    @IBOutlet weak var areaLabel:UILabel!
    
    
    var viewModel:UserGradingViewModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel.setButtonTags(for: [star1,star2,star3,star4,star5])
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func changeGrade(_ sender:AnyObject){
        guard let sender = sender as? StarButton else {return}
        viewModel.gradeChanged(to: sender.tag)
    }
    
}

extension UserGradingViewController: UserGradingVMDelegate{
    func returnToPreviousView() {
        self.navigationController?.popToRootViewController(animated: true)
    }
    
    
}

