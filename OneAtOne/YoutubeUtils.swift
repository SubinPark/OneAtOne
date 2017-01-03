//
//  YoutubeUtils.swift
//  OneAtOne
//
//  Created by Finlay, Kate on 12/25/16.
//  Copyright © 2016 1@1. All rights reserved.
//

import Foundation

class YoutubeUtils : NSObject {
    /// Hard coded for now. TODO: find a way to populate this dynamically as we get new videos
    static let videoID : String =  RCValues.sharedInstance.videoUrl(forKey: .liveVideoUrl)
    
    /// Youtube v3 API key, registered to kate.n.finlay@gmail.com
    fileprivate static let apiKey = "AIzaSyBp-pLhGyL2IWAe9o1MTKvP50nt-itRlYs"
    
    /**
     * Asynchronously gets the view count for a given youtube video ID.
     *
     * param videoID the video ID you want to get view count for
     * param callback gives any errors from the process, also the view count as an Int
     */
    static func getViewCount(for videoID: String, callback: @escaping (_ error : Error?, _ viewCount : Int?) -> Void) {
        let youtubeApi = "https://www.googleapis.com/youtube/v3/videos?part=contentDetails%2C+snippet%2C+statistics&id=\(videoID)&key=\(YoutubeUtils.apiKey)"
        let url = NSURL(string: youtubeApi)
        
        let task = URLSession.shared.dataTask(with: url! as URL, completionHandler: { (data, response, error) -> Void in
            do {
                var viewCount : Int? = nil
                if let jsonResult = try JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.allowFragments) as? [String : AnyObject] {
                    
                    print("Response from YouTube: \(jsonResult)")
                    
                    // Extract the View Count from the JSON
                    if let items = jsonResult["items"] as? [AnyObject]?,
                        let stats = items?[0]["statistics"] as? [String: AnyObject]?,
                        let viewsString = stats?["viewCount"] as? String,
                        let views = Int(viewsString) {
                        viewCount = views
                    }
                }
                callback(error, viewCount)
            }
            catch {
                print("json error: \(error)")
                callback(error, nil)
            }
            
        })
        
        // Start the request
        task.resume()
    }
    
}
