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
    
	override func viewDidLoad() {
		super.viewDidLoad()
		
        // Kick off a spinner while we fetch view count
        viewCountLabel.isHidden = true
        viewCountLoadingIndicator.startAnimating()
        
        YoutubeUtils.getViewCount(for: YoutubeUtils.videoID) { (error : Error?, viewCount : Int?) in
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
        
        YoutubeUtils.getTitle(for: YoutubeUtils.videoID) { (error : Error?, title : String?) in
            DispatchQueue.main.async {
                if let error = error {
                    print("Error getting title: \(error)")
                }
                if let title = title {
                    self.titleLabel.text = title
                }
            }
        }
        
        self.playerView.load(withVideoId: YoutubeUtils.videoID)
	}

	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}


}

