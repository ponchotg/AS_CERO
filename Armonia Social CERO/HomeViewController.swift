//
//  HomeViewController.swift
//  Armonia Social CERO
//
//  Created by Alfonso Tapia on 7/17/17.
//  Copyright © 2017 Paranoid Interactive. All rights reserved.
//

import Foundation
import UIKit
import SWRevealViewController

class HomeViewController:UIViewController {
    
    @IBOutlet weak var menuButton:UIBarButtonItem!
    @IBOutlet weak var tableView:UITableView!
    @IBOutlet weak var userProfilePicture:UIImageView!
    @IBOutlet weak var bLabel: UILabel!
    @IBOutlet weak var pLabel:UILabel!
    @IBOutlet weak var scoreLabel:UILabel!
    @IBOutlet weak var nameLabel:UILabel!
    @IBOutlet weak var areaLabel:UILabel!
    lazy var viewModel:HomeViewModel = HomeViewModel(delegate: self)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.revealViewControllerSetup(with: menuButton)
        viewModel.doInitialSetup()
        viewModel.getUserPicture(to: userProfilePicture)
    }
}


extension HomeViewController: HomeVMDelegate {
    
    func updateScoreLabel(to text:String){
        DispatchQueue.main.async {
            [weak self] in
            self?.scoreLabel.text = text
        }
    }
    
    func updateScore(type:SearchType, to text:String){
        switch type {
        case .behavior:
            DispatchQueue.main.async{
                [weak self] in
                self?.bLabel.text = text
            }
        case .performance:
            DispatchQueue.main.async {
                [weak self] in
                self?.pLabel.text = text
            }
        }
    }
}

extension HomeViewController:UITableViewDelegate,UITableViewDataSource{
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return viewModel.getSectionCount()
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return viewModel.titleForSection(section)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let sectionItems = viewModel.objectFor(section: section) else {return 0}
        return sectionItems.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCell(withIdentifier: "CommentsCell")!
        cell.textLabel?.text = viewModel.objectFor(indexPath: indexPath)
        return cell
    }
    
    
    
}
