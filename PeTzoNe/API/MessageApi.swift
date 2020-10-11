//
//  MessageApi.swift
//  PeTzoNe
//
//  Created by Radhi Mighri on 14/08/2020.
//  Copyright © 2020 Radhi Mighri. All rights reserved.
//

import Foundation
import FirebaseDatabase

class MessageApi {
    
    func sendMessage(from: String, to: String, value: Dictionary<String, Any>){
        //hash func allows as to identify the chatroom so we only need a single child node for each chat room under the "feedMessages" 
        let channelId = Message.hash(forMembers: [from, to])

        let ref = Database.database().reference().child("feedMessages").child(channelId)
        
        //once we get the main node of the path we want to store each message to the child of messages under this ref via "childByAutoId()" method , then we store JSON data via "updateChildValues()"
        ref.childByAutoId().updateChildValues(value)
        
        //remove the unncessary information of the message before update it
        // because in the inbox scene maybe we need to see the latest text message in the inbox cell but the photos and videos we need to display it only in the People Chat scene
        var dict = value
        if let text = dict["text"] as? String, text.isEmpty { //(make sure that the msg contain a aphoto or a video)
            dict["imageUrl"] = nil
            dict["height"] = nil
            dict["width"] = nil
        }
        
//
//        //update the dictionary to the new data ("dict" instead of "value")

let refFromInbox = Database.database().reference().child(REF_INBOX).child(from).child(channelId)
refFromInbox.updateChildValues(dict)
let refToInbox = Database.database().reference().child(REF_INBOX).child(to).child(channelId)
refToInbox.updateChildValues(dict)
    }
    
    
    func receiveMessage(from: String, to: String, onSuccess: @escaping(Message) -> Void) { // to make this func rendring an output we have put callback func 'onSuccess:@escaping()->Void' (called also a block)
        let channelId = Message.hash(forMembers: [from, to])

        let ref = Database.database().reference().child("feedMessages").child(channelId)
        
        ref.queryOrderedByKey().queryLimited(toLast: 5).observe(.childAdded) { (snapshot) in
            if let dict = snapshot.value as? Dictionary<String, Any> {
                //print(dict)
                if let message = Message.transformMessage(dict: dict, keyId: snapshot.key) {
                    onSuccess(message)
                }
                
            }
        }
    }
    
    
    func loadMore(lastMessageKey: String?, from: String, to: String, onSuccess: @escaping([Message], String) -> Void) {
        if lastMessageKey != nil {
            let channelId = Message.hash(forMembers: [from, to])
            let ref = Database.database().reference().child("feedMessages").child(channelId)
            //every time w scroll downl , we load 4 old messages
            ref.queryOrderedByKey().queryEnding(atValue: lastMessageKey).queryLimited(toLast: 4).observeSingleEvent(of: .value) { (snapshot) in
                guard let first = snapshot.children.allObjects.first as? DataSnapshot else {
                    return
                }
                
                guard let allObjects = snapshot.children.allObjects as? [DataSnapshot] else {
                    return
                }
                var messages = [Message]()
                allObjects.forEach({ (object) in
                    if let dict = object.value as? Dictionary<String, Any> {
                        if let message = Message.transformMessage(dict: dict, keyId: snapshot.key) {
                            if object.key != lastMessageKey {
                                messages.append(message)
                            }
                        }
                    }
                })
                onSuccess(messages, first.key)
                
            }
        }
    }

}
