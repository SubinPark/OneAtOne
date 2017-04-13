//
//  ViewController.swift
//  OneAtOne
//
//  Created by Park, Subin on 12/22/16.
//  Copyright © 2016 1@1. All rights reserved.
//

import UIKit
import youtube_ios_player_helper

class ViewController: UIViewController {
    
    @IBOutlet weak var playerView: YTPlayerView!
    @IBOutlet weak var viewCountLabel: UILabel!
    @IBOutlet weak var viewCountLoadingIndicator: UIActivityIndicatorView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var shareButton: UIButton!
    @IBOutlet weak var descriptionTextView: UITextView!
    @IBOutlet weak var tableView: UITableView!
    
    var playlist = [PlaylistItem]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        YoutubeUtils.fetchPlaylistData { (playlistData) in
            DispatchQueue.main.async {
                if let playlistData = playlistData {
                    self.playlist = playlistData
                    self.tableView.reloadData()
                }
            }
        }
        
        actionButtonSetup()
		
        // Start description text view at top of text ins
        descriptionTextView.scrollRangeToVisible(NSMakeRange(0, 0))
    }
	
    override func viewWillAppear(_ animated: Bool) {
        // Kick off a spinner while we fetch view count, this will be hidden by populateMainPlayerView
        viewCountLabel.isHidden = true
        viewCountLoadingIndicator.startAnimating()
        
        RCValues.sharedInstance.fetchCloudValues { (videoUrl) in
            self.changeMainVideoTo(videoUrl, spinnerStarted: true)
        }
    }
	
    /// Reset UITextView to the top of the text instead of the middle.
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        descriptionTextView.setContentOffset(CGPoint.zero, animated: false)
    }
	
	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}
	
	func actionButtonSetup() {
		shareButton.leadTitle(withFontAwesomeIconNamed: "fa-check", titleText: Constants.Video.actionComplete, forState: .normal)
		shareButton.setBackgroundImage(UIImage.from(color: UIColor.OneAtOneDarkNavy), for: .normal)
		
		shareButton.leadTitle(withFontAwesomeIconNamed: "fa-check", titleText: Constants.Video.actionThanks, forState: .selected)
		shareButton.setBackgroundImage(UIImage.from(color: UIColor.OneAtOneGreen), for: .selected)
	}
    
	@IBAction func shareButtonDidTapped(_ sender: Any) {
		shareButton.isSelected = !shareButton.isSelected
	}
}


extension ViewController : UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return tableView.dequeueReusableCell(withIdentifier: "SectionHeader")
    }
	
	func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
		return CGFloat.init(32)
	}
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let playlistItem = playlist[indexPath.row]
        
        if let id = playlistItem.id {
            self.changeMainVideoTo(id, spinnerStarted: false)
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return playlist.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70.0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "PlaylistCell") as? PlaylistCell {
            let playlistItem = playlist[indexPath.row]
            
            cell.title.text = playlistItem.title ?? ""
            cell.thumbnail.contentMode = .scaleAspectFit
            
            if let image = playlistItem.thumbnail {
                cell.thumbnail.image = image
            }
			
			cell.videoID = playlistItem.id
			cell.delegate = self
			
			if let id = playlistItem.id {
				cell.checkButton.isSelected = UserDefaults.standard.bool(forKey: id)
				shareButton.isSelected = cell.checkButton.isSelected
			}
			
            return cell
        } else {
            print("Unknown cell type")
            return UITableViewCell()
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    /**
     Switches the video in the main player view to the specified video id.
     
     @param videoId the video to load
     @parm spinnerStarted whether a spinner is already showing over the viewcount label. Will kick off and hide another spinner if true.
     */
    fileprivate func changeMainVideoTo(_ videoId: String, spinnerStarted: Bool) {
        
        self.playerView.load(withVideoId: videoId)
        
        // Don't fetch the data if we already have it cached
        if let playlistItem = playlist.first(where: { $0.id == videoId }),
            let viewCount = playlistItem.viewCount,
            let description = playlistItem.description,
            let title = playlistItem.title {
            // It's unlikely we'll be in this state, but just in case, never good to have endless spinners.
            if spinnerStarted {
                self.viewCountLoadingIndicator.stopAnimating()
                self.viewCountLoadingIndicator.isHidden = true
            }
            self.populatePlayerViewData(viewCount: viewCount, title: title, description: description)
        } else {
            if !spinnerStarted {
                viewCountLabel.isHidden = true
                viewCountLoadingIndicator.startAnimating()
            }
            YoutubeUtils.getVideoInformation(for: videoId) { (error, info : (viewCount: Int?, title: String?, description: String?)?) in
                DispatchQueue.main.async {
                    self.viewCountLoadingIndicator.stopAnimating()
                    self.viewCountLoadingIndicator.isHidden = true
                    
                    guard error == nil else {
                        print("Error getting video data: \(error)")
                        return
                    }
                    
                    if let info = info {
                        // Cache playlist data
                        if let index = self.playlist.index(where: { $0.id == videoId }) {
                            var playlistItem = self.playlist[index]
                            playlistItem.description = info.description
                            playlistItem.viewCount = info.viewCount
                            playlistItem.title = info.title
                            self.playlist[index] = playlistItem
                        }
                        self.populatePlayerViewData(viewCount: info.viewCount, title: info.title, description: info.description)
                    }
                }
            }
        }
    }
    
    fileprivate func populatePlayerViewData(viewCount: Int?, title: String?, description: String?) {
        if let viewCount = viewCount {
            // Format the view count
            let numberFormatter = NumberFormatter()
            numberFormatter.numberStyle = NumberFormatter.Style.decimal
            
            if let formattedViewCount = numberFormatter.string(from: NSNumber(value: viewCount)) {
                self.viewCountLabel.text = "\(formattedViewCount) views"
                self.viewCountLabel.isHidden = false
            }
        }
        if let title = title {
            self.titleLabel.text = title
        }
        if let description = description {
            self.descriptionTextView.text = description
            self.descriptionTextView.flashScrollIndicators()
        }
        
    }
}
