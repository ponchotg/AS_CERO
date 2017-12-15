//
//  UserPickerTableViewController.swift
//  Armonia Social CERO
//
//  Created by Alfonso Tapia on 8/31/17.
//  Copyright © 2017 Paranoid Interactive. All rights reserved.
//

import UIKit

class UserPickerTableViewController: UITableViewController,UserPickerTableVMDelegate {
    
    @IBOutlet weak var menuButton:UIBarButtonItem!
    @IBOutlet weak var searchBar:UISearchBar!
    
    lazy var viewModel:UserPickerTableViewModel = UserPickerTableViewModel(delegate: self)
    var selectionType:UserSelectionType = .alphabetical

    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.backgroundView = UIImageView(image: #imageLiteral(resourceName: "tryjpeg"))
        self.searchBar.delegate = self
        self.viewModel.initialSetup()
        self.revealViewControllerSetup(with: menuButton)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return viewModel.getNumberOfSections(for: self.selectionType)
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.getNumberOfRows(for: section, searchType: self.selectionType)
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        guard let user = viewModel.getUser(for: indexPath, searchType: selectionType) else {return cell}
        cell.textLabel?.text = "\(user.name) \(user.lastName)"
        cell.detailTextLabel?.text = user.area
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.viewModel.selectedUser = viewModel.getUser(for: indexPath, searchType: selectionType)
        self.performSegue(withIdentifier: "ToUserProfile", sender: self)
        searchBar.resignFirstResponder()
    }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let nextView = segue.destination as? UserProfileViewController else {return}
        guard let selectedUser = viewModel.selectedUser else {return}
        nextView.viewModel = UserProfileViewModel(delegate: nextView, user: selectedUser)
        searchBar.resignFirstResponder()
    }
    
    // MARK: - User Interaction
    @IBAction func changeSortMethod(_ sender:AnyObject){
        let alert = UIAlertController(title: "Ordenar", message: "Selecciona una opción", preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Orden Alfabetico", style: .default, handler: { (action) in
            self.selectionType = .alphabetical
            self.reloadTableView()
        }))
        alert.addAction(UIAlertAction(title: "Ordenar por Area", style: .default, handler: { (action) in
            self.selectionType = .area
            self.reloadTableView()
        }))
        alert.addAction(UIAlertAction(title: "Cancelar", style: .cancel))
        self.presentAlert(alert: alert)
    }

}

extension UserPickerTableViewController:UISearchBarDelegate{
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        guard searchText.count > 0 else {
            self.selectionType = .alphabetical
            self.reloadTableView()
            return
        }
        let arrOfSearch = searchText.components(separatedBy: " ").filter{$0.count > 0}
        self.selectionType = .filtered(with: arrOfSearch)
        self.reloadTableView()
    }
}
