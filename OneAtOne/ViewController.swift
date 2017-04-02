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
        
        shareButton.leadTitle(withFontAwesomeIconNamed: "fa-check")
        // Start description text view at top of text ins
        descriptionTextView.scrollRangeToVisible(NSMakeRange(0, 0))
    }

	override func viewWillAppear(_ animated: Bool) {
		// Kick off a spinner while we fetch view count
		viewCountLabel.isHidden = true
		viewCountLoadingIndicator.startAnimating()
		
		RCValues.sharedInstance.fetchCloudValues { (videoUrl) in
            YoutubeUtils.getVideoInformation(for: videoUrl, callback: { (error, info : (viewCount: Int?, title: String?, description: String?)?) in
                DispatchQueue.main.async {
                    self.viewCountLoadingIndicator.stopAnimating()
                    self.viewCountLoadingIndicator.isHidden = true
                    
                    if let error = error {
                        print("Error getting view count: \(error)")
                    }
                    if let info = info {
                        if let viewCount = info.viewCount {
                            
                            // Format the view count
                            let numberFormatter = NumberFormatter()
                            numberFormatter.numberStyle = NumberFormatter.Style.decimal
                            
                            if let formattedViewCount = numberFormatter.string(from: NSNumber(value: viewCount)) {
                                self.viewCountLabel.text = "\(formattedViewCount) views"
                                self.viewCountLabel.isHidden = false
                            }
                        }
                        if let title = info.title {
                            self.titleLabel.text = title
                        }
                        if let description = info.description {
                            self.descriptionTextView.text = description
                            self.descriptionTextView.flashScrollIndicators()
                        }
                    }

                }
            })
			
			self.playerView.load(withVideoId: videoUrl)
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
    
	@IBAction func shareButtonDidTapped(_ sender: Any) {
		if let button = sender as? UIButton {
			button.backgroundColor = UIColor.OneAtOneGreen
			button.leadTitle(withFontAwesomeIconNamed: "fa-check", titleText: "Thanks for making an impact!")
		}
	}
}


extension ViewController : UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return tableView.dequeueReusableCell(withIdentifier: "SectionHeader")
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let playlistItem = playlist[indexPath.row]
        print("Selected row \(indexPath.row). Title: \(playlistItem.title) \n Description: \(playlistItem.description)")
        // Kick off a spinner while we fetch view count
        viewCountLabel.isHidden = true
        viewCountLoadingIndicator.startAnimating()
        if let id = playlistItem.id {
            if let viewCount = playlistItem.viewCount,
                let description = playlistItem.description,
                let title = playlistItem.title {
                self.titleLabel.text = title
                self.descriptionTextView.text = description
                self.descriptionTextView.flashScrollIndicators()
                let formatted = NumberFormatter().string(from: NSNumber(value: viewCount))
                self.viewCountLabel.text = "\(formatted) views"
            } else {
                YoutubeUtils.getVideoInformation(for: id) { (error, info : (viewCount: Int?, title: String?, description: String?)?) in
                    DispatchQueue.main.async {
                        self.viewCountLoadingIndicator.stopAnimating()
                        self.viewCountLoadingIndicator.isHidden = true
                        
                        if let error = error {
                            print("Error getting view count: \(error)")
                        }
                        if let info = info {
                            if let viewCount = info.viewCount {
                                
                                // Format the view count
                                let numberFormatter = NumberFormatter()
                                numberFormatter.numberStyle = NumberFormatter.Style.decimal
                                
                                if let formattedViewCount = numberFormatter.string(from: NSNumber(value: viewCount)) {
                                    self.viewCountLabel.text = "\(formattedViewCount) views"
                                    self.viewCountLabel.isHidden = false
                                }
                            }
                            if let title = info.title {
                                self.titleLabel.text = title
                            }
                            if let description = info.description {
                                self.descriptionTextView.text = description
                                self.descriptionTextView.flashScrollIndicators()
                            }
                        }
                        self.playerView.load(withVideoId: id)
                    }
                    
                }
            }
            } else {
                self.viewCountLoadingIndicator.stopAnimating()
                self.viewCountLoadingIndicator.isHidden = true
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
            cell.thumbnail.clipsToBounds = true
            
            if let image = playlistItem.thumbnail {
                cell.thumbnail.image = image
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
}
