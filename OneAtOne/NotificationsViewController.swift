//
//  NotificationsViewController.swift
//  OneAtOne
//
//  Created by Finlay, Kate on 1/3/17.
//  Copyright © 2017 1@1. All rights reserved.
//

import UIKit

protocol NotificationsViewControllerDelegate {
    func dismissNotificationsController()
}

class NotificationsViewController: UIViewController {
    
    @IBOutlet weak var confirmButton: UIButton!
    
    var delegate : NotificationsViewControllerDelegate?
    
    /**
     * When either button on this screen is pressed, dismiss this viewcontroller
     * If they say "I'm in", prompt them to register for push notifications
     */
    @IBAction func onPress(_ sender: UIButton) {
        if sender.tag == 2 {
            // Prompt the user for push notifications
            let notificationTypes: UIUserNotificationType = [UIUserNotificationType.alert, UIUserNotificationType.badge, UIUserNotificationType.sound]
            let notificationSettings = UIUserNotificationSettings(types: notificationTypes, categories: nil)
            UIApplication.shared.registerForRemoteNotifications()
            UIApplication.shared.registerUserNotificationSettings(notificationSettings)
        }
        delegate?.dismissNotificationsController()
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Round corners
        confirmButton.layer.cornerRadius = confirmButton.frame.height/2.0
       confirmButton.leadTitle(withFontAwesomeIconNamed: "fa-thumbs-up")
    }
}
