//
//  ChatViewController.swift
//  PeTzoNe
//
//  Created by Radhi Mighri on 13/08/2020.
//  Copyright © 2020 Radhi Mighri. All rights reserved.
//

import UIKit
import MobileCoreServices
import AVFoundation

class ChatViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var mediaButton: UIButton!
    
    @IBOutlet weak var audioButton: UIButton!
    
    @IBOutlet weak var inputTextView: UITextView!
    
    @IBOutlet weak var sendBtn: UIButton!
    
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    
    
    var avatarImageView: UIImageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 36, height: 36))
    var imagePartner: UIImage!
    var topLabel: UILabel = UILabel(frame: CGRect(x: 0, y: 0, width: 200, height: 200))
    var partnerUsername: String!
    var parthnerID: String!
    var partnerUser: User!
    var placeholderLbl = UILabel()
    var picker = UIImagePickerController()
    var messages = [Message]()
    var isActive = false
    var lastTimeOnline = ""
    var isTyping = false
    var timer = Timer()
    var refreshControl = UIRefreshControl() // pagination : to load more messages
    var lastMessageKey: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupPicker()
        
        setupInputContainer()
        
        setupNavigationBar()
        
        setupTableView()
        
        
        
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tabBarController?.tabBar.isHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.tabBarController?.tabBar.isHidden = false
        
    }
    
    @IBAction func sendBtnDidTapped(_ sender: UIButton) {
        if let text = inputTextView.text, text != "" {
            inputTextView.text = ""
            self.textViewDidChange(inputTextView)
            sendToFireBase(dict: ["text": text as Any])
        }
    }
    
    @IBAction func mediaBtnDidTapped(_ sender: UIButton) {
        
        let alert = UIAlertController(title: "PeTzoNe", message: "Select source", preferredStyle: UIAlertController.Style.actionSheet)
        
        let camera = UIAlertAction(title: "Take a picture", style: UIAlertAction.Style.default) { (_) in
            if UIImagePickerController.isSourceTypeAvailable(UIImagePickerController.SourceType.camera) {
                self.picker.sourceType = .camera
                self.present(self.picker, animated: true, completion: nil)
            } else {
                print("Unavailable cam in the simulator")
            }
            
        }
        
        let library = UIAlertAction(title: "Choose an Image or a video", style: UIAlertAction.Style.default) { (_) in
            if UIImagePickerController.isSourceTypeAvailable(UIImagePickerController.SourceType.photoLibrary) {
                self.picker.sourceType = .photoLibrary
                self.picker.mediaTypes = [String(kUTTypeImage),String(kUTTypeMovie)]
                self.present(self.picker, animated: true, completion: nil)
            } else {
                print("Unavailable")
            }
        }
        
        let videoCamera = UIAlertAction(title: "Take a video", style: UIAlertAction.Style.default) { (_) in
            if UIImagePickerController.isSourceTypeAvailable(UIImagePickerController.SourceType.camera) {
                self.picker.sourceType = .camera
                self.picker.mediaTypes = [String(kUTTypeMovie)]
                self.picker.videoExportPreset = AVAssetExportPresetPassthrough
                self.picker.videoMaximumDuration = 30
                self.present(self.picker, animated: true, completion: nil)
            } else {
                print("Unavailable")
            }
        }
        
        
        let cancel = UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel, handler: nil)
        
        alert.addAction(camera)
        alert.addAction(library)
        alert.addAction(cancel)
        alert.addAction(videoCamera)
        
        present(alert, animated: true, completion: nil)
    }
    
    
    

}

