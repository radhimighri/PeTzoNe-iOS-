//
//  MessagesTableViewController.swift
//  PeTzoNe
//
//  Created by Radhi Mighri on 12/08/2020.
//  Copyright © 2020 Radhi Mighri. All rights reserved.
//

import UIKit
import FirebaseAuth

class MessagesTableViewController: UITableViewController {

    var inboxArray = [Inbox]()
    
    var avatarImageView: UIImageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 36, height: 36))

    var lastInboxDate: Double?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupTableView()
        observeInbox()
        setupNavigationBar()
    }
    
    func setupNavigationBar() {
        navigationItem.title = "Messages"
               navigationController?.navigationBar.prefersLargeTitles = true
               
               
               let iconView = UIImageView(image: UIImage(named: "icon_top"))
               iconView.contentMode = .scaleAspectFit
               navigationItem.titleView = iconView
               
               let containView = UIView(frame: CGRect(x: 0, y: 0, width: 36, height: 36))
               avatarImageView.contentMode = .scaleAspectFill
               avatarImageView.layer.cornerRadius = 18
               avatarImageView.clipsToBounds = true
               containView.addSubview(avatarImageView)
               
               
               let radarItem = UIBarButtonItem(image: UIImage(named: "icon-radar"), style: UIBarButtonItem.Style.plain, target: self, action: #selector(radarItemDidTapped))
               self.navigationItem.rightBarButtonItem = radarItem

               
               let leftBarButton = UIBarButtonItem(customView: containView)
               self.navigationItem.leftBarButtonItem = leftBarButton
               
               if let currentUser = Auth.auth().currentUser, let photoUrl = currentUser.photoURL {
                   avatarImageView.loadImage(photoUrl.absoluteString)
               }
               
               NotificationCenter.default.addObserver(self, selector: #selector(updateProfile), name: NSNotification.Name("updateProfileImage"), object: nil)

        
    }
    
    @objc func radarItemDidTapped() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let radarVC = storyboard.instantiateViewController(withIdentifier: IDENTIFIER_RADAR) as! RadarViewController
        
        self.navigationController?.pushViewController(radarVC, animated: true)
    }
    
    @objc func updateProfile() {
        if let currentUser = Auth.auth().currentUser, let photoUrl = currentUser.photoURL {
                  avatarImageView.loadImage(photoUrl.absoluteString)
              }
    }
    
    // each time an instance of inbox is retrived we can simply append it to an array of inbox objects then update the table view to display the new inbox
    func observeInbox() {
        Api.Inbox.lastMessages(uid: Api.User.currentUserId) { (inbox) in
            if !self.inboxArray.contains(where: {$0.user.uid == inbox.user.uid}) { //we make sure that the inbox array dosen't contain the new inbox by checking his partner ID
                self.inboxArray.append(inbox)
                self.sortedInbox()
            }
        }
    }
    
    func sortedInbox() {
        inboxArray = inboxArray.sorted(by: { $0.date > $1.date }) //descending order = the latest inbox will be at the top of the table
        lastInboxDate = inboxArray.last!.date
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    
    func loadMore() {
        print("LoadMore")
   Api.Inbox.loadMore(start: lastInboxDate, controller: self, from: Api.User.currentUserId) { (inbox) in
                   self.tableView.tableFooterView = UIView()
                   if self.inboxArray.contains(where: {$0.channel == inbox.channel}) {
                       return
                   }
                   self.inboxArray.append(inbox)
                   self.tableView.reloadData()
                   self.lastInboxDate = self.inboxArray.last!.date
               }
           }

    
        func setupTableView() {
    //        tableView.tableFooterView = UIView() // remove the separators between the cells by assigning an empty view
          // or judt :
            tableView.separatorStyle = .none
        }


    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return inboxArray.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "InboxTableViewCell", for: indexPath) as! InboxTableViewCell

        let inbox = self.inboxArray[indexPath.row]
        cell.controller = self
        cell.configureCell(uid: Api.User.currentUserId, inbox: inbox)
        
        
        return cell
    }
    

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 108
    }
    
    //similar to the people scene we passed the data from the cell to the chat scene then use the navigation controller to push to the chatVC
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if let cell = tableView.cellForRow(at: indexPath) as? InboxTableViewCell {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let chatVC = storyboard.instantiateViewController(withIdentifier: IDENTIFIER_CHAT) as! ChatViewController
            chatVC.parthnerID = cell.user.uid
            chatVC.partnerUsername = cell.usernameLbl.text
            chatVC.imagePartner = cell.avatar.image
            chatVC.partnerUser = cell.user
            self.navigationController?.pushViewController(chatVC, animated: true)
        }
    }
    
    // a method to know if we've reached the end of our tableView
    
     
    override func scrollViewWillBeginDecelerating(_ scrollView: UIScrollView) {
        if let lastIndex = self.tableView.indexPathsForVisibleRows?.last {
            if lastIndex.row >= self.inboxArray.count - 2 {
                let spinner = UIActivityIndicatorView(style: UIActivityIndicatorView.Style.gray)
                spinner.startAnimating()
                spinner.frame = CGRect(x: 0, y: 0, width: tableView.bounds.width, height: 44)
                
                self.tableView.tableFooterView = spinner
                self.tableView.tableFooterView?.isHidden = false
                
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.5) {
                    self.loadMore()
                }
            }
        }
    }
}
