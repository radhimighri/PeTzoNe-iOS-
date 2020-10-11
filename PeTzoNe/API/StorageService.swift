//
//  StorageService.swift
//  PeTzoNe
//
//  Created by Radhi Mighri on 11/08/2020.
//  Copyright © 2020 Radhi Mighri. All rights reserved.
//

import Foundation
import FirebaseStorage
import FirebaseDatabase
import FirebaseAuth
import ProgressHUD
import AVFoundation

class StorageService {
    
    static func saveVideoMessage(url: URL, id: String, onSuccess: @escaping(_ value: Any) -> Void, onError: @escaping(_ errorMessage: String) -> Void) {
          let ref = Ref().storageSpecificVideoMessage(id: id)
          ref.putFile(from: url, metadata: nil) { (metadata, error) in
              if error != nil {
                  onError(error!.localizedDescription)
              }
              ref.downloadURL(completion: { (videoUrl, error) in
                  if let thumbnailImage = self.thumbnailImageForFileUrl(url) {
                      StorageService.savePhotoMessage(image: thumbnailImage, id: id, onSuccess: { (value) in
                          if let dict = value as? Dictionary<String, Any> {
                              var dictValue = dict
                              if let videoUrlString = videoUrl?.absoluteString {
                                  dictValue["videoUrl"] = videoUrlString
                              }
                              onSuccess(dictValue)
                          }
                      }, onError: { (errorMessage) in
                          onError(errorMessage)
                      })
                  }
              })
          }
      }
      
      static func thumbnailImageForFileUrl(_ url: URL) -> UIImage? {
          let asset = AVAsset(url: url)
          let imageGenerator = AVAssetImageGenerator(asset: asset)
          imageGenerator.appliesPreferredTrackTransform = true
          var time = asset.duration
          time.value = min(time.value, 2)
          do {
              let imageRef = try imageGenerator.copyCGImage(at: time, actualTime: nil)
              return UIImage(cgImage: imageRef)
          } catch let error as NSError {
              print(error.localizedDescription)
              return nil
          }
      }

    
    static func savePhotoMessage(image: UIImage?, id: String, onSuccess: @escaping(_ value: Any) -> Void, onError: @escaping(_ errorMessage: String) -> Void) {
        if let imagePhoto = image {
            let ref = Ref().storageSpecificImageMessage(id: id)
            if let data = imagePhoto.jpegData(compressionQuality: 0.5) {
                
                ref.putData(data, metadata: nil) { (metadata, error) in
                    if error != nil {
                        onError(error!.localizedDescription)
                    }
                    //once the uploading process succeeds we need to find some sort of URL associated with the photo
                    //so we need to download the URL of the photo we've uploaded from the storage
                    //then push this URL to the messages path and the firebase DB
                    ref.downloadURL(completion: { (url, error) in
                        if let metaImageUrl = url?.absoluteString { //DB dosen't support URL so we will use it as String
                            let dict: Dictionary<String, Any> = [
                                "imageUrl": metaImageUrl as Any,
                                "height": imagePhoto.size.height as Any,
                                "width": imagePhoto.size.width as Any,
                                "text": "" as Any
                            ]
                            onSuccess(dict)
                        }
                    })
                }
            }
        }
    }
    
    
    static func savePhotoProfile(image: UIImage, uid: String, onSuccess: @escaping() -> Void, onError: @escaping(_ errorMessage: String) -> Void)  {
        guard let imageData = image.jpegData(compressionQuality: 0.4) else {
            return
        }
        
        let storageProfileRef = Ref().storageSpecificProfile(uid: uid)
        
        let metadata = StorageMetadata()
        metadata.contentType = "image/jpg"
        
        storageProfileRef.putData(imageData, metadata: metadata, completion: { (storageMetaData, error) in
            if error != nil {
                onError(error!.localizedDescription)
                return
            }
            
            storageProfileRef.downloadURL(completion: { (url, error) in
                if let metaImageUrl = url?.absoluteString {
                    
                    if let changeRequest = Auth.auth().currentUser?.createProfileChangeRequest() {
                        changeRequest.photoURL = url
                        changeRequest.commitChanges(completion: { (error) in
                            if let error = error {
                                ProgressHUD.showError(error.localizedDescription)
                            } else {
                                NotificationCenter.default.post(name: NSNotification.Name("updateProfileImage"), object: nil)
                            }
                        })
                    }
                    
                    Ref().databaseSpecificUser(uid: uid).updateChildValues([PROFILE_IMAGE_URL: metaImageUrl], withCompletionBlock: { (error, ref) in
                        if error == nil {
                            
                            onSuccess()
                        } else {
                            onError(error!.localizedDescription)
                        }
                    })
                }
            })
            
        })
        
        
    }
    
    
    static func savePhoto(username: String, uid: String, imageData: Data, metadata: StorageMetadata, storageProfileRef: StorageReference, dict: Dictionary<String, Any>, onSuccess: @escaping() -> Void, onError: @escaping(_ errorMessage: String) -> Void) {
        
        storageProfileRef.putData(imageData, metadata: metadata, completion: {
            (StorageMetadata, error) in
            if error != nil {
                //                                print(error?.localizedDescription)
                onError(error!.localizedDescription)
                return
            }
            
            storageProfileRef.downloadURL { (url, error) in
                if let metaImageUrl = url?.absoluteString {
                    
                    if let changeRequest = Auth.auth().currentUser?.createProfileChangeRequest() {
                        changeRequest.photoURL = url
                        changeRequest.displayName = username
                        changeRequest.commitChanges { (error) in
                            if let error = error {
                                ProgressHUD.showError(error.localizedDescription)
                            }
                        }
                    }
                    
                    var dictTemp = dict
                    
                    dictTemp[PROFILE_IMAGE_URL] = metaImageUrl
                    
                    
                    // save the created users into the database
                    //represent all users as a big node and make sure make each user a child node
                    Ref().databaseSpecificUser(uid: uid).updateChildValues(dictTemp, withCompletionBlock:  {
                            (error, ref) in
                            if error == nil {
                                //print("Done")
                                onSuccess()
                            } else {
                                onError(error!.localizedDescription)
                            }
                        })
                }
            }
            
        })
        
        
    }
}
