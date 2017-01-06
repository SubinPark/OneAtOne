//
//  ViewController.swift
//  OneAtOne
//
//  Created by Park, Subin on 12/22/16.
//  Copyright © 2016 1@1. All rights reserved.
//

import UIKit
import youtube_ios_player_helper
import TTTAttributedLabel

class ViewController: UIViewController, TTTAttributedLabelDelegate {
    
    @IBOutlet weak var playerView: YTPlayerView!
    @IBOutlet weak var viewCountLabel: UILabel!
    @IBOutlet weak var viewCountLoadingIndicator: UIActivityIndicatorView!
    @IBOutlet weak var titleLabel: UILabel!
	@IBOutlet weak var shareButton: UIButton!
    @IBOutlet weak var feedbackLabel: TTTAttributedLabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        shareButton.leadTitle(withFontAwesomeIconNamed: "fa-share")
        
        let str : NSString = "Feedback or questions? Email info@1at1.org."
        feedbackLabel.delegate = self
        feedbackLabel.text = str as String
        let range : NSRange = str.range(of: "Email info@1at1.org.")
        let email = "info@1at1.org"
        let url = NSURL(string: "mailto:\(email)")
        if let url = url as? URL {
            feedbackLabel.addLink(to: url, with: range)
        }
    }

	override func viewWillAppear(_ animated: Bool) {
		// Kick off a spinner while we fetch view count
		viewCountLabel.isHidden = true
		viewCountLoadingIndicator.startAnimating()
		
		RCValues.sharedInstance.fetchCloudValues { (videoUrl) in
			YoutubeUtils.getViewCount(for: videoUrl) { (error : Error?, viewCount : Int?) in
				DispatchQueue.main.async {
					self.viewCountLoadingIndicator.stopAnimating()
					self.viewCountLoadingIndicator.isHidden = true
					
					if let error = error {
						print("Error getting view count: \(error)")
					}
					
					if let viewCount = viewCount {
						
						// Format the view count
						let numberFormatter = NumberFormatter()
						numberFormatter.numberStyle = NumberFormatter.Style.decimal
						
						if let formattedViewCount = numberFormatter.string(from: NSNumber(value: viewCount)) {
							self.viewCountLabel.text = "\(formattedViewCount) views"
							self.viewCountLabel.isHidden = false
						}
					}
				}
			}
			
			YoutubeUtils.getTitle(for: videoUrl) { (error : Error?, title : String?) in
				DispatchQueue.main.async {
					if let error = error {
						print("Error getting title: \(error)")
					}
					if let title = title {
						self.titleLabel.text = title
					}
				}
			}
			
			self.playerView.load(withVideoId: videoUrl)
		}
	}
	
	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}
	
    public func attributedLabel(_ label: TTTAttributedLabel!, didSelectLinkWith url: URL!) {
        UIApplication.shared.openURL(url)
    }
    
	@IBAction func shareButtonDidTapped(_ sender: Any) {
		let activityItems = ["https://www.youtube.com/watch?v=\(RCValues.sharedInstance.defaultVideoUrl)"]
		let activityViewController: UIActivityViewController = UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
		
		self.present(activityViewController, animated: true, completion: nil)
	}
}
