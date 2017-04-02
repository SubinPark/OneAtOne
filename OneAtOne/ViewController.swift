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
    
    override func viewDidLoad() {
        super.viewDidLoad()
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
