//
//  UserTableViewCell.swift
//  PeTzoNe
//
//  Created by Radhi Mighri on 13/08/2020.
//  Copyright © 2020 Radhi Mighri. All rights reserved.
//

import UIKit
import FirebaseDatabase

protocol UpdateTableProtocol {
    func reloadData()
}

class UserTableViewCell: UITableViewCell {

    @IBOutlet weak var avatar: UIImageView!
    @IBOutlet weak var usernameLbl: UILabel!
    @IBOutlet weak var statusLbl: UILabel!
    @IBOutlet weak var onlineView: UIView!
    
    //create an instance of User to store the value of the user in the "cell" , we download the user's data from the DB then tansfert it to the "cell" via "loadData()" method
    var user: User!
    var inboxChangedOnlineHandle : DatabaseHandle!
    var inboxChangedProfileHandle : DatabaseHandle!
    var delegate: UpdateTableProtocol!

    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        avatar.layer.cornerRadius = 30
        avatar.clipsToBounds = true
        
        onlineView.backgroundColor = UIColor.red
        onlineView.layer.borderWidth = 2
        onlineView.layer.borderColor = UIColor.white.cgColor
        onlineView.layer.cornerRadius = 15/2
        onlineView.clipsToBounds = true
    }



    func loadData(_ user: User) {
        
        self.user = user
        
        self.usernameLbl.text = user.username
        self.statusLbl.text = user.status
//        self.avatar.image = UIImage(named: "R@DiOS")
        self.avatar.loadImage(user.profileImageUrl)
        
    
    let refOnline = Ref().dataBaseIsOnline(uid: user.uid)
           refOnline.observeSingleEvent(of: .value) { (snapshot) in
               if let snap = snapshot.value as? Dictionary<String, Any> {
                   if let active = snap["online"] as? Bool {
                       self.onlineView.backgroundColor = active == true ? .green : .red
                   }
               }
           }
           
           if inboxChangedOnlineHandle != nil {
               refOnline.removeObserver(withHandle: inboxChangedOnlineHandle)
           }
           
           inboxChangedOnlineHandle = refOnline.observe(.childChanged) { (snapshot) in
               if let snap = snapshot.value {
                   if snapshot.key == "online" {
                       self.onlineView.backgroundColor = (snap as! Bool) == true ? .green : .red
                   }
                  
               }
           }
        
        let refUser = Ref().databaseSpecificUser(uid: user.uid)
        if inboxChangedProfileHandle != nil {
                 refUser.removeObserver(withHandle: inboxChangedProfileHandle)
             }
        
        inboxChangedProfileHandle = refUser.observe(.childChanged, with: { (snapshot) in
            if let snap = snapshot.value as? String {
                self.user.updateData(key: snapshot.key, value: snap)
                self.delegate.reloadData()
            }
        })
    
    }
    
    
    override func prepareForReuse() {
        super.prepareForReuse()
        let refOnline = Ref().dataBaseIsOnline(uid: self.user.uid)
        if inboxChangedOnlineHandle != nil {
                 refOnline.removeObserver(withHandle: inboxChangedOnlineHandle)
             }
        let refUser = Ref().databaseSpecificUser(uid: self.user.uid)
        if inboxChangedProfileHandle != nil {
                 refUser.removeObserver(withHandle: inboxChangedProfileHandle)
             }
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    
}
