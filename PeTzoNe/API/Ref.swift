//
//  Ref.swift
//  FirebaseAuth
//
//  Created by Radhi Mighri on 11/08/2020.
//

import Foundation
import FirebaseDatabase
import FirebaseStorage

let REF_USER = "users"
let REF_MESSAGE = "messages"
let REF_INBOX = "inbox"
let REF_GEO = "Geolocs"
let REF_ACTION = "action"
let URL_STORAGE_ROOT = "gs://petzone-b9ea8.appspot.com"
let STORAGE_PROFILE = "profile"
let STORAGE_MSG_PHOTO = "photo"
let STORAGE_MSG_Video = "video"
let PROFILE_IMAGE_URL = "profile_ImageUrl"
let UID = "uid"
let EMAIL = "email"
let USERNAME = "username"
let STATUS = "status"
let IS_ONLINE = "isOnline"
let LAT = "current_latitude"
let LONG = "current_longitude"

let ERROR_EMPTY_PHOTO = "Please choose your profile image"
let ERROR_EMPTY_EMAIL = "Please enter an email address"
let ERROR_EMPTY_USERNAME = "Please enter a username"
let ERROR_EMPTY_PASSWORD = "Please enter a password"
let ERROR_EMPTY_EMAIL_RESET = "Please enter an email address for password reset"
let SUCCESS_EMAIL_RESET = "We have just sent you a password reset email. Please check your inbox and follow the instructions to reset your password"
let IDENTIFIER_TABBAR = "TabBarVC"
let IDENTIFIER_WELCOME = "MainVC"
let IDENTIFIER_CHAT = "ChatVC"
let IDENTIFIER_USER_AROUND = "UsersAroundViewController"
let IDENTIFIER_MAP = "MapViewController"
let IDENTIFIER_DETAIL = "DetailViewController"
let IDENTIFIER_RADAR = "RadarViewController"
let IDENTIFIER_NEW_MATCH = "NewMatchTableViewController"

let IDENTIFIER_CELL_USERS = "UserTableViewCell"


class Ref {
    // construct the DB structure
    
    let dataBaseRoot: DatabaseReference = Database.database().reference()
    
    var databaseUsers: DatabaseReference {
        return dataBaseRoot.child(REF_USER)
    }
    
    func databaseSpecificUser(uid: String) -> DatabaseReference {
        return databaseUsers.child(uid)
    }
    
    func dataBaseIsOnline(uid: String) -> DatabaseReference {
        return databaseUsers.child(uid).child(IS_ONLINE)
    }
    
    
    var databaseInbox: DatabaseReference {
        return dataBaseRoot.child(REF_INBOX)
    }
    
    func databaseInboxInfor(from: String, to: String) -> DatabaseReference {
        return databaseInbox.child(from).child(to)
    }
    
    
    func databaseInboxForUser(uid: String) -> DatabaseReference {
        return databaseInbox.child(uid)
    }
    
    var databaseMessage: DatabaseReference {
        return dataBaseRoot.child(REF_MESSAGE)
    }
    func databaseMessageSendTo(from: String, to: String) -> DatabaseReference {
        return databaseMessage.child(from).child(to)
        //the first node under the "message" path will be the current user ID and the second will be the partner IDin the 'ChatViewController"
    }
    
    var databaseGeo: DatabaseReference {
        return dataBaseRoot.child(REF_GEO)
    }
    
    var databaseAction: DatabaseReference {
        return dataBaseRoot.child(REF_ACTION)
    }
    
    func databaseActionForUser(uid: String) -> DatabaseReference {
           return databaseAction.child(uid)
       }
       
    
    //Storage Ref
    
    let storageRoot = Storage.storage().reference(forURL: URL_STORAGE_ROOT)
    
    var storageProfile: StorageReference {
        return storageRoot.child(STORAGE_PROFILE)
    }
    
    // to get access to a user profile reference will input the user ID as the parameter of a func
    
    func storageSpecificProfile(uid: String) -> StorageReference {
        return storageProfile.child(uid)
    }
    
    var storageMessage: StorageReference {
        return storageRoot.child(REF_MESSAGE)
    }
    func storageSpecificImageMessage(id: String) -> StorageReference {
        return storageMessage.child(STORAGE_MSG_PHOTO).child(id)
    }
    
    func storageSpecificVideoMessage(id: String) -> StorageReference {
        return storageMessage.child(STORAGE_MSG_Video).child(id)
    }
    
}

