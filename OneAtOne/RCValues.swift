//
//  RCValues.swift
//  OneAtOne
//
//  Created by Park, Subin on 1/2/17.
//  Copyright © 2017 1@1. All rights reserved.
//
import Foundation
import Firebase

enum ValueKey: String {
	case liveVideoUrl
}

class RCValues {
 
	static let sharedInstance = RCValues()
	static let defaultVideoUrl = "ly_GlXOTA-A"
 
	private init() {
		loadDefaultValues()
		fetchCloudValues()
	}
 
	func loadDefaultValues() {
		let appDefaults: [String: NSObject] = [
			ValueKey.liveVideoUrl.rawValue : RCValues.defaultVideoUrl as NSObject
		]
		FIRRemoteConfig.remoteConfig().setDefaults(appDefaults)
	}
	
	func fetchCloudValues() {
		// 1
		// WARNING: Don't actually do this in production!
		let fetchDuration: TimeInterval = 10 // Change to 43200 (12hr) for production
		activateDebugMode()
		FIRRemoteConfig.remoteConfig().fetch(withExpirationDuration: fetchDuration) { (status, error) in
			guard error == nil else {
				print ("Uh-oh. Got an error fetching remote values \(error)")
				return
			}
			// 2
			FIRRemoteConfig.remoteConfig().activateFetched()
			print("Retrieved values from the cloud!")
		}
	}
	
	func activateDebugMode() { // Remove this before releasing to production
		let debugSettings = FIRRemoteConfigSettings(developerModeEnabled: true)
		FIRRemoteConfig.remoteConfig().configSettings = debugSettings!
	}
	
	func videoUrl(forKey key: ValueKey) -> String {
		return FIRRemoteConfig.remoteConfig().configValue(forKey: key.rawValue).stringValue ?? RCValues.defaultVideoUrl
	}
}
