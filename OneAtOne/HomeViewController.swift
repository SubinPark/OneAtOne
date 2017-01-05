//
//  HomeViewController.swift
//  OneAtOne
//
//  Created by Finlay, Kate on 1/2/17.
//  Copyright © 2017 1@1. All rights reserved.
//

import Foundation
import UIKit

class HomeViewController: UIViewController, NotificationsViewControllerDelegate {
    
    @IBOutlet weak var scrollView: UIScrollView!
	@IBOutlet weak var shareButton: UIButton!
	
	var notificationsViewController : NotificationsViewController?
	
    override func viewDidLoad() {
        super.viewDidLoad()
		
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
        scrollView.contentSize = CGSize(width: self.view.frame.width, height: 1000)
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
		let activityItems = ["App link to share"]
		let activityViewController: UIActivityViewController = UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
		
		self.present(activityViewController, animated: true, completion: nil)
	}
}
