//
//  RCValues.swift
//  OneAtOne
//
//  Created by Park, Subin on 1/2/17.
//  Copyright © 2017 1@1. All rights reserved.
//
import Foundation
import Firebase
import FirebaseRemoteConfig

enum ValueKey: String {
	case LiveVideoUrl
}

class RCValues {
 
	static let sharedInstance = RCValues()
	var defaultVideoUrl = "ly_GlXOTA-A"
 
	private init() {
		loadDefaultValues()
		fetchCloudValues {_ in }
	}
 
	func loadDefaultValues() {
		let appDefaults: [String: NSObject] = [
			ValueKey.LiveVideoUrl.rawValue : defaultVideoUrl as NSObject
		]
		FIRRemoteConfig.remoteConfig().setDefaults(appDefaults)
	}
	
	func fetchCloudValues(completionHandler: @escaping (_ videoURL: String) -> Void) {
		let fetchDuration: TimeInterval = 900
		#if DEBUG
			activateDebugMode()
		#endif
		
		FIRRemoteConfig.remoteConfig().fetch(withExpirationDuration: fetchDuration) { [unowned self] (status, error) in
			guard error == nil else {
				print ("Uh-oh. Got an error fetching remote values \(error)")
				return
			}
			
			//Fetching successful
			FIRRemoteConfig.remoteConfig().activateFetched()
			if let newValue = FIRRemoteConfig.remoteConfig().configValue(forKey: ValueKey.LiveVideoUrl.rawValue).stringValue {
				self.defaultVideoUrl = newValue
				completionHandler(self.defaultVideoUrl)
			}
		}
	}
	
	func activateDebugMode() {
		let debugSettings = FIRRemoteConfigSettings(developerModeEnabled: true)
		FIRRemoteConfig.remoteConfig().configSettings = debugSettings!
	}
}
