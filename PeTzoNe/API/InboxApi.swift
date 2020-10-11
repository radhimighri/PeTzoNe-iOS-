//
//  InboxApi.swift
//  PeTzoNe
//
//  Created by Radhi Mighri on 15/08/2020.
//  Copyright © 2020 Radhi Mighri. All rights reserved.
//

import Foundation
import FirebaseDatabase

typealias InboxCompletion = (Inbox) -> Void

class InboxApi {
    
    func lastMessages (uid: String, onSuccess: @escaping(InboxCompletion)) {
        
        let ref = Database.database().reference().child(REF_INBOX).child(uid)
        //download the inbox data from DB at the ref path
        ref.queryOrdered(byChild: "date").queryLimited(toLast: 8).observe(.childAdded) { (snapshot) in
            if let dict = snapshot.value as? Dictionary<String, Any> {
                
                guard let partnerId = dict["to"] as? String else {
                    return
                }
                let uid = (partnerId == Api.User.currentUserId) ? (dict["from"] as! String) : partnerId
                
                let channelId = Message.hash(forMembers: [uid, partnerId])

                Api.User.getUserInfor(uid: uid, onSuccess: { (user) in
                    // create an instance of "Inbox"
                    if let inbox = Inbox.transformInbox(dict: dict,channel: channelId,user: user) {
                        onSuccess(inbox)
                    }
                })
            }
        }

    }
    
    func loadMore(start timestamp: Double?, controller: MessagesTableViewController, from: String, onSuccess: @escaping(InboxCompletion)) {
           guard let timestamp = timestamp else {
               return
           }
           let ref = Database.database().reference().child(REF_INBOX).child(from).queryOrdered(byChild: "date").queryEnding(atValue: timestamp - 1).queryLimited(toLast: 3)
           ref.observeSingleEvent(of: .value) { (snapshot) in
               guard let allObjects = snapshot.children.allObjects as? [DataSnapshot] else {
                   return
               }
               if allObjects.isEmpty {
                   controller.tableView.tableFooterView = UIView()
               }
               
               allObjects.forEach({ (object) in
                   if let dict = object.value as? Dictionary<String, Any> {
                       guard let partnerId = dict["to"] as? String else {
                           return
                       }
                       let channelId = Message.hash(forMembers: [from, partnerId])
                       Api.User.getUserInfor(uid: partnerId, onSuccess: { (user) in
                           if let inbox = Inbox.transformInbox(dict: dict,channel: channelId,user: user) {
                               onSuccess(inbox)
                           }
                       })
                   }
               })
           }
       }
       

    
}
