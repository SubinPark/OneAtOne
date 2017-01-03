//
//  TwitterFeedViewController.swift
//  OneAtOne
//
//  Created by Finlay, Kate on 12/30/16.
//  Copyright © 2016 1@1. All rights reserved.
//

import UIKit
import TwitterKit

class TwitterFeedViewController: UIViewController {
    
    @IBOutlet weak var containerView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Create an API client and data source to fetch Tweets for the timeline
        let client = TWTRAPIClient()
        //TODO: Replace with your collection id or a different data source
        let dataSource = TWTRSearchTimelineDataSource(searchQuery: "#1at1action", apiClient: client)
        // Create the timeline view controller
        let timelineViewControlller = TWTRTimelineViewController(dataSource: dataSource)
        self.addChildViewController(timelineViewControlller)
        
        containerView.frame = CGRect(x: 0.0, y: 0.0, width: containerView.frame.width, height: containerView.frame.height)
        timelineViewControlller.view.frame = containerView.frame
        containerView.addSubview(timelineViewControlller.view)
        timelineViewControlller.didMove(toParentViewController: self)
        
    }
    
    func dismissTimeline() {
        dismiss(animated: true, completion: nil)
    }
}
