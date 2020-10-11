//
//  MessageTableViewCell.swift
//  PeTzoNe
//
//  Created by Radhi Mighri on 14/08/2020.
//  Copyright © 2020 Radhi Mighri. All rights reserved.
//

import UIKit
import AVFoundation

class MessageTableViewCell: UITableViewCell {
    
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var bubbleView: UIView!
    @IBOutlet weak var textMessageLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var photoMessage: UIImageView!
    @IBOutlet weak var playButton: UIButton!
    
    //create IBOutlets for the constraints of the bubble view so that we can calculate the size and position of the bubble via its constraints
    @IBOutlet weak var widthConstraint: NSLayoutConstraint!
    @IBOutlet weak var bubbleLeftConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var bubbleRightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var activityIndicatorView: UIActivityIndicatorView!
    
    @IBOutlet weak var headerTimeLabel: UILabel!
    
    
    var playerLayer: AVPlayerLayer?
    var player: AVPlayer?
    var message: Message!
    
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        bubbleView.layer.cornerRadius = 15
        bubbleView.clipsToBounds = true
        bubbleView.layer.borderWidth = 0.4
        textMessageLabel.numberOfLines = 0
        photoMessage.layer.cornerRadius = 15
        photoMessage.clipsToBounds = true
        profileImage.layer.cornerRadius = 16
        profileImage.clipsToBounds = true
        
        photoMessage.isHidden = true
        profileImage.isHidden = true
        textMessageLabel.isHidden = true
        
        activityIndicatorView.isHidden = true
        activityIndicatorView.stopAnimating()
        activityIndicatorView.style = .whiteLarge
        
    }
    
    
    @IBAction func playBtnDidTapped(_ sender: UIButton) {
        handlePlay()
    }
    
    //to handle the state of the Player ; we use the observation technique
    var observation: Any? = nil
    
    func  handlePlay() {
        
        activityIndicatorView.isHidden = false
        activityIndicatorView.startAnimating()
        
        let videoUrl = message.videoUrl
        if videoUrl.isEmpty {
            return
        }
        if let url = URL(string: videoUrl) {
            player = AVPlayer(url: url)
            playerLayer = AVPlayerLayer(player: player)
            playerLayer?.videoGravity = AVLayerVideoGravity.resizeAspectFill
            playerLayer?.frame = photoMessage.frame
            observation = player?.addObserver(self, forKeyPath: "status", options: NSKeyValueObservingOptions.new, context: nil)
            bubbleView.layer.addSublayer(playerLayer!)
            player?.play()
            playButton.isHidden = true
        }
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "status" {
            let status: AVPlayer.Status = player!.status
            switch (status) {
            case AVPlayer.Status.readyToPlay:
                activityIndicatorView.isHidden = true
                activityIndicatorView.stopAnimating()
                break
            case AVPlayer.Status.unknown, AVPlayer.Status.failed:
                break
            }
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        photoMessage.isHidden = true
        profileImage.isHidden = true
        textMessageLabel.isHidden = true
        
        if observation != nil {
            stopObservers()
        }
        playerLayer?.removeFromSuperlayer()
        player?.pause()
        playButton.isHidden = false
        activityIndicatorView.isHidden = true
        activityIndicatorView.stopAnimating()
    }
    
    func stopObservers() {
        player?.removeObserver(self, forKeyPath: "status")
        observation = nil
    }
    
    func configureCell(uid: String, message: Message, image: UIImage) {
        self.message = message
        let text = message.text
        if !text.isEmpty {
            textMessageLabel.isHidden = false
            textMessageLabel.text = message.text
            
            let widthValue = text.estimateFrameForText(text).width + 40
            
            if widthValue < 75 {
                widthConstraint.constant = 75
            } else {
                widthConstraint.constant = widthValue
            }
            dateLabel.textColor = .lightGray
            
        } else { // there is no text but a photo
            photoMessage.isHidden = false
            photoMessage.loadImage(message.imageUrl)
            bubbleView.layer.borderColor = UIColor.clear.cgColor
            widthConstraint.constant = 250
            dateLabel.textColor = .white
        }
        
        if uid == message.from { // message.from (message sent from the current user : me)
            bubbleView.backgroundColor = UIColor.groupTableViewBackground
            bubbleView.layer.borderColor = UIColor.clear.cgColor
            bubbleRightConstraint.constant = 8
            bubbleLeftConstraint.constant = UIScreen.main.bounds.width - widthConstraint.constant - bubbleRightConstraint.constant
        }else { // message.to (message sent by the partner)
            profileImage.isHidden = false
            bubbleView.backgroundColor = UIColor.white
            profileImage.image = image
            bubbleView.layer.borderColor = UIColor.lightGray.cgColor
            
            bubbleLeftConstraint.constant = 8
            bubbleRightConstraint.constant = UIScreen.main.bounds.width - widthConstraint.constant - bubbleLeftConstraint.constant
        }
        
        
        let date = Date(timeIntervalSince1970: message.date)
        let dateString = timeAgoSinceDate(date, currentDate: Date(), numericDates: true)
        
        dateLabel.text = dateString
        
        self.formatHeaderTimeLabel(time: date) { (text) in
            self.headerTimeLabel.text = text
        }

        
    }
    
    func formatHeaderTimeLabel(time: Date, completion: @escaping (String) -> ()) {
           var text = ""
           let currentDate = Date()
           let currentDateString = currentDate.toString(dateFormat: "yyyyMMdd")
           let pastDateString = time.toString(dateFormat: "yyyyMMdd")
           print(currentDateString)
           print(pastDateString)
           if pastDateString.elementsEqual(currentDateString) == true {
               text = time.toString(dateFormat: "HH:mm a") + ", Today"
           } else {
               text = time.toString(dateFormat: "dd/MM/yyyy")
           }
           
           completion(text)
       }

    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}




