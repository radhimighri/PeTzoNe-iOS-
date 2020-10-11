//
//  PeopleTableViewController.swift
//  PeTzoNe
//
//  Created by Radhi Mighri on 13/08/2020.
//  Copyright © 2020 Radhi Mighri. All rights reserved.
//

import UIKit
import FirebaseAuth


class PeopleTableViewController: UITableViewController, UISearchResultsUpdating {
    

    
    var users: [User] = []
    var searchController: UISearchController = UISearchController(searchResultsController: nil)
    var searchResults: [User] = []
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupSearchBarController()
        setupNavigationBar()
        observeUsers()
        setupTableView()
        
        
    }
    
    func setupTableView() {
        tableView.tableFooterView = UIView() // remove the separators between the cells by assigning an empty view
        // or judt :
        //tableView.separatorStyle = .none
    }
    
    func observeUsers() {
        Api.User.observeUsers { (user) in
            self.users.append(user)
            self.tableView.reloadData()
        }
    }
    
    func setupSearchBarController() {
        searchController.searchResultsUpdater = self
        searchController.dimsBackgroundDuringPresentation = true
        searchController.searchBar.placeholder = "Search users..."
        searchController.searchBar.barTintColor = UIColor.white
        searchController.obscuresBackgroundDuringPresentation = false
        definesPresentationContext = true
        navigationItem.hidesSearchBarWhenScrolling = false
        navigationItem.searchController = searchController
    }
    
    
    func setupNavigationBar() {
        navigationItem.title = "People"
        navigationController?.navigationBar.prefersLargeTitles = true
        
                let iconView = UIImageView(image: UIImage(named: "icon_top"))
        iconView.contentMode = .scaleAspectFit
        navigationItem.titleView = iconView
        
        let location = UIBarButtonItem(image: UIImage(named: "icon-location"), style: UIBarButtonItem.Style.plain, target: self, action: #selector(locationDidTapped))
        navigationItem.leftBarButtonItem = location
    }
    
      @objc func locationDidTapped() {
        print("location")
           // switch to UsersAroundVC
       let storyboard = UIStoryboard(name: "Main", bundle: nil)
       let usersAroundVC = storyboard.instantiateViewController(withIdentifier: IDENTIFIER_USER_AROUND) as! UsersAroundViewController

       self.navigationController?.pushViewController(usersAroundVC, animated: true)

       }
       
    func updateSearchResults(for searchController: UISearchController) {
        if searchController.searchBar.text == nil || searchController.searchBar.text!.isEmpty {
            view.endEditing(true)
        } else {
            let textLowercased = searchController.searchBar.text!.lowercased()
            filterContent(for: textLowercased)
        }
        tableView.reloadData()
    }
    
    func filterContent(for searchText: String) {
        searchResults = self.users.filter {
            return $0.username.lowercased().range(of: searchText) != nil
        }
    }
    // MARK: - Table view data source
    
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return searchController.isActive ? searchResults.count : self.users.count
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: IDENTIFIER_CELL_USERS, for: indexPath) as! UserTableViewCell
        
        let user = users[indexPath.row]
        cell.delegate = self
        cell.loadData(user)
        
        return cell
    }
    
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        // Return false if you do not want the specified item to be editable.
        return 108
    }
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let cell = tableView.cellForRow(at: indexPath) as? UserTableViewCell {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let chatVC = storyboard.instantiateViewController(withIdentifier: IDENTIFIER_CHAT) as! ChatViewController
            chatVC.parthnerID = cell.user.uid
            chatVC.partnerUsername = cell.usernameLbl.text
            chatVC.imagePartner = cell.avatar.image
            chatVC.partnerUser = cell.user
            self.navigationController?.pushViewController(chatVC, animated: true)
        }
    }
    
}

extension PeopleTableViewController: UpdateTableProtocol {
    func reloadData() {
        self.tableView.reloadData()
    }
}
