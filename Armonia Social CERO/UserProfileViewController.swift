//
//  UserProfileViewController.swift
//  Armonia Social CERO
//
//  Created by Alfonso Tapia on 9/8/17.
//  Copyright © 2017 Paranoid Interactive. All rights reserved.
//

import Foundation
import UIKit

class UserProfileViewController:UIViewController{
    @IBOutlet weak var tableView:UITableView!
    @IBOutlet weak var btnGradeB:UIBarButtonItem!
    @IBOutlet weak var btnGradeP:UIBarButtonItem!
    @IBOutlet weak var profileImageView:UIImageView!
    @IBOutlet weak var nameLabel:UILabel!
    @IBOutlet weak var areaLabel:UILabel!
    
    var viewModel:UserProfileViewModel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel?.getImage(to: profileImageView)
        self.tableView.isScrollEnabled = false
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
}

extension UserProfileViewController:UITableViewDelegate,UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel?.profile?.count ?? 0
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = self.tableView.dequeueReusableCell(withIdentifier: "Cell") else {
            fatalError("Cell is not correctly set")
        }
        cell.textLabel?.text = viewModel?.getTitleFor(indexPath: indexPath)
        cell.detailTextLabel?.text = viewModel?.getSubtitleFor(indexPath: indexPath)
        return cell
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let btnsender = sender as? UIBarButtonItem else {return}
        guard let vc = segue.destination as? UserGradingViewController else {return}
        guard let vmUser = viewModel?.user else {return}
        let type:GradeType = (btnsender === btnGradeB) ? .behavior : .performance
        let vm = UserGradingViewModel(delegate: vc, gradeType: type, user: vmUser)
        vc.viewModel = vm
    }
    
    @IBAction func gradeUser(_ sender:AnyObject){
        guard let sender = sender as? UIBarButtonItem else {return}
        self.performSegue(withIdentifier: "toGradeView", sender: sender)
    }

}

extension UserProfileViewController:UserProfileVMDelegate{}
