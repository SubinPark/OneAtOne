//
//  HomeViewController.swift
//  OneAtOne
//
//  Created by Finlay, Kate on 1/2/17.
//  Copyright © 2017 1@1. All rights reserved.
//

import Foundation
import UIKit
import TTTAttributedLabel

class HomeViewController: UIViewController, NotificationsViewControllerDelegate, TTTAttributedLabelDelegate {
    
    @IBOutlet weak var shareView: UIView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var shareButton: UIButton!
    @IBOutlet weak var websiteLabel: TTTAttributedLabel!
    @IBOutlet weak var feedbackLabel: TTTAttributedLabel!
    @IBOutlet weak var twitterButton: UIButton!
    @IBOutlet weak var instagramButton: UIButton!
    @IBOutlet weak var facebookButton: UIButton!
    @IBOutlet weak var websiteLinkOverlayView: UIView!
    
    var notificationsViewController : NotificationsViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        shareButton.leadTitle(withFontAwesomeIconNamed: "fa-share")
        twitterButton.leadTitle(withFontAwesomeIconNamed: "fa-twitter")
        instagramButton.leadTitle(withFontAwesomeIconNamed: "fa-instagram")
        facebookButton.leadTitle(withFontAwesomeIconNamed: "fa-facebook-square")
        
        shareView.isUserInteractionEnabled = true
        
        let feedbackStr : NSString = "Feedback or questions? Email info@1at1.org."
        feedbackLabel.delegate = self
        feedbackLabel.text = feedbackStr as String
        let emailRange : NSRange = feedbackStr.range(of: "info@1at1.org")
        let feedbackUrl = NSURL(string: "mailto:info@1at1.org")
        if let feedbackUrl = feedbackUrl as? URL {
            feedbackLabel.addLink(to: feedbackUrl, with: emailRange)
        }
        
        let websiteStr : NSString = "Check out 1at1.org for more information."
        let websiteRange : NSRange = websiteStr.range(of: "1at1.org")
        let websiteUrl = NSURL(string: "https://www.1at1.org")
        if let websiteUrl = websiteUrl as? URL {
            websiteLabel.addLink(to: websiteUrl, with: websiteRange)
        }
        
        let singleTap = UITapGestureRecognizer(target: self, action: #selector(self.websiteOverlayTapped(_:)))
        self.websiteLinkOverlayView.addGestureRecognizer(singleTap)
        singleTap.cancelsTouchesInView = false
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // if not seen before
        let hasSeenKey = "hasSeenNotifications"
        if UserDefaults.standard.object(forKey: hasSeenKey) == nil {
            if let storyboardName = Bundle.main.object(forInfoDictionaryKey: "UIMainStoryboardFile") as? String {
                let storyboard = UIStoryboard(name: storyboardName, bundle: nil)
                let viewController = storyboard.instantiateViewController(withIdentifier: "NotificationsViewController")
                if let notificationsViewController = viewController as? NotificationsViewController {
                    notificationsViewController.delegate = self
                    self.notificationsViewController = notificationsViewController
                    self.present(notificationsViewController, animated: true, completion: nil)
                    UserDefaults.standard.set(true, forKey: hasSeenKey)
                }
            }
        }
        
        
    }
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        scrollView.contentSize = CGSize(width: self.view.frame.width, height: 393)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func dismissNotificationsController() {
        if let notificationsViewController = notificationsViewController {
            notificationsViewController.dismiss(animated: true, completion: nil)
        }
    }
	
	@IBAction func shareButtonDidTapped(_ sender: Any) {
		let activityItems = ["http://itunes.apple.com/app/id1192159190"]
		let activityViewController: UIActivityViewController = UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
		
		self.present(activityViewController, animated: true, completion: nil)
	}
    
    @IBAction func websiteOverlayTapped(_ sender: UIButton) {
        let websiteUrl = NSURL(string: "https://www.1at1.org")
        if let websiteUrl = websiteUrl as? URL {
            UIApplication.shared.openURL(websiteUrl)
        }
        
    }

    @IBAction func socialButtonTapped(_ sender: UIButton) {
        var nativeURL : NSURL?
        var webURL : NSURL?
        switch sender.tag {
            
        // Facebook
        case 1:
            nativeURL = NSURL(string:"fb://profile/1867705966792928")
            webURL = NSURL(string: "https://www.facebook.com/1867705966792928")
            break
            
        // Instagram
        case 2:
            nativeURL = NSURL(string: "instagram://user?username=1at1action")
            webURL = NSURL(string: "https://www.instagram.com/1at1action/")

            break
            
        // Twitter
        case 3:
            webURL = NSURL(string: "https://twitter.com/1at1Action")
            nativeURL = NSURL(string: "twitter://user?screen_name=1at1Action)")
            break
            
        default:
            // unrecognized button
            break
            
        }
        
        if let url = nativeURL as? URL,
            UIApplication.shared.canOpenURL(url)
        {
            UIApplication.shared.openURL(url)
            
        } else if let url = webURL as? URL {
            UIApplication.shared.openURL(url)
        }
    }
    
    public func attributedLabel(_ label: TTTAttributedLabel!, didSelectLinkWith url: URL!) {
        UIApplication.shared.openURL(url)
    }
}
