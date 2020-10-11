//
//  NewMatchTableViewController.swift
//  PeTzoNe
//
//  Created by Radhi Mighri on 18/08/2020.
//  Copyright © 2020 Radhi Mighri. All rights reserved.
//

import UIKit

class NewMatchTableViewController: UITableViewController {

  
        var users: [User] = []
        override func viewDidLoad() {
            super.viewDidLoad()
            setupNavigationBar()
            observeUsers()
            setupTableView()
        }
        
        func setupTableView() {
            tableView.tableFooterView = UIView()
        }
        
        func setupNavigationBar() {
            title = "New Match"
            
            let iconView = UIImageView(image: UIImage(named: "icon_top"))
            iconView.contentMode = .scaleAspectFit
            navigationItem.titleView = iconView
        }
        
        func observeUsers() {
            Api.User.observeNewMatch { (user) in
                self.users.append(user)
                self.tableView.reloadData()
            }
        }
        
        override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            // #warning Incomplete implementation, return the number of rows
            return self.users.count
        }
        
        override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            let cell = tableView.dequeueReusableCell(withIdentifier: IDENTIFIER_CELL_USERS, for: indexPath) as! UserTableViewCell
            
            let user = users[indexPath.row]
            cell.delegate = self
            
            cell.loadData(user)
            
            return cell
        }
        
        override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
            return 94
        }
        
        override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
            if let cell = tableView.cellForRow(at: indexPath) as? UserTableViewCell {
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let chatVC = storyboard.instantiateViewController(withIdentifier: IDENTIFIER_CHAT) as! ChatViewController
                chatVC.imagePartner = cell.avatar.image
                chatVC.partnerUsername = cell.usernameLbl.text
                chatVC.parthnerID = cell.user.uid
                chatVC.partnerUser = cell.user
                self.navigationController?.pushViewController(chatVC, animated: true)
                
            }
        }
        
    }
//
    extension NewMatchTableViewController: UpdateTableProtocol {
        func reloadData() {
            self.tableView.reloadData()
        }
    }
