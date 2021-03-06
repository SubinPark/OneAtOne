//
//  YoutubeUtils.swift
//  OneAtOne
//
//  Created by Finlay, Kate on 12/25/16.
//  Copyright © 2016 1@1. All rights reserved.
//

import Foundation
import UIKit

struct PlaylistItem {
    // populated by fetchPlaylistData
    var id : String?
    var title : String?
    var thumbnailUrl : String?
    
    // populated by downloadImage
    var thumbnail : UIImage?
    
    // populated by getVideoInformation
    var viewCount : Int?
    var description : String?
	
	var completed : Bool?
}

class YoutubeUtils : NSObject {
    /// Youtube v3 API key, registered to kate.n.finlay@gmail.com
    fileprivate static let apiKey = "AIzaSyBp-pLhGyL2IWAe9o1MTKvP50nt-itRlYs"
    
    fileprivate static let baseUrl = "https://www.googleapis.com/youtube/v3/"
    
    fileprivate static let playlistID = "PLMfNR7VDgPxWO8UaF6JQXZFVajYCeufoW"
    /**
     * Asynchronously gets the view count for a given youtube video ID.
     *
     * param videoID the video ID you want to get view count for
     * param callback gives any errors from the process, also the view count as an Int
     */
    static func getVideoInformation(for videoID: String, callback: @escaping (_ error : Error?, (viewCount : Int?, title : String?, description : String?)?) -> Void) {
        let youtubeApi = "\(baseUrl)videos?part=contentDetails%2C+snippet%2C+statistics&id=\(videoID)&key=\(YoutubeUtils.apiKey)"
        let url = NSURL(string: youtubeApi)
        
        if let url = url as? URL {
        let task = URLSession.shared.dataTask(with: url, completionHandler: { (data, response, error) -> Void in
            do {
                var viewCount : Int? = nil
                var title : String? = nil
                var description : String? = nil
                
                if let data = data,
                    let jsonResult = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.allowFragments) as? [String : AnyObject] {
                    
                    print("Response from YouTube: \(jsonResult)")
                    
                    // Extract the View Count from the JSON
                    if let items = jsonResult["items"] as? [AnyObject]? {
                        if let stats = items?[0]["statistics"] as? [String: AnyObject]?,
                            let viewsString = stats?["viewCount"] as? String,
                            let views = Int(viewsString) {
                            viewCount = views
                        }
                        if let snippet = items?[0]["snippet"] as? [String: AnyObject]? {
                            if let titleStr = snippet?["title"] as? String {
                                title = titleStr
                            }
                            if let descriptionStr = snippet?["description"] as? String {
                                description = descriptionStr
                            }
                        }
                    }
                }
                callback(error, (viewCount : viewCount, title : title, description : description))
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
    
    static func downloadImage(_ urlString : String, completionHandler: @escaping (UIImage?) -> ()) {
        if let url = URL(string: urlString) {
            let downloadPicTask = URLSession.shared.dataTask(with: url) { (data, response, error) in
                guard error == nil else {
                    print("Error downloading picture: \(error)")
                    return
                }
                
                if let data = data {
                    let image = UIImage(data: data)
                    completionHandler(image)
                } else {
                    print("Couldn't get image: Image is nil")
                    completionHandler(nil)
                }
            }
            
            downloadPicTask.resume()
        } else {
            completionHandler(nil)
        }
    }
    
    static func fetchPlaylistData(_ completionHandler : @escaping ([PlaylistItem]?) -> Swift.Void) {
        PlaylistFetcher.sharedInstance.fetchPlaylistData(playlistID) { (playlist) in
            if var playlist = playlist {
                let dispatchGroup = DispatchGroup()
                for i in 0..<playlist.count {
                    var item = playlist[i]
                    dispatchGroup.enter()
                    if let url = item.thumbnailUrl {
                        YoutubeUtils.downloadImage(url, completionHandler: { (image) in
                            item.thumbnail = image
                            playlist[i] = item
                            dispatchGroup.leave()
                        })
                    } else {
                        dispatchGroup.leave()
                    }
                }
                dispatchGroup.notify(queue: DispatchQueue.main) {
                    
                    completionHandler(playlist)
                }
            } else {
                completionHandler(playlist)
            }
        }
    }
    
}

fileprivate class PlaylistFetcher {
    
    static let sharedInstance = PlaylistFetcher()
    
    var token : String?
    
    var playlist = [PlaylistItem]()
    
    func fetchPage(ofPlaylist playlistID: String, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Swift.Void) {
        var tokenInfo = ""
        if let token = token { tokenInfo = "pageToken=\(token)" }
        let apistr = "\(YoutubeUtils.baseUrl)playlistItems?part=snippet&fields=nextPageToken,pageInfo,items(id,snippet(title,thumbnails(medium),resourceId(videoId)))&maxResults=50&playlistId=\(YoutubeUtils.playlistID)&key=\(YoutubeUtils.apiKey)" + tokenInfo
        let url = NSURL(string: apistr)
        if let url_url = url as? URL {
            let task = URLSession.shared.dataTask(with: url_url, completionHandler: { (data, response, error) -> Void in
                completionHandler(data, response, error)
            })
            task.resume()
        }
    }
    
    func fetchPlaylistData(_ playlistID : String, completionHandler : @escaping ([PlaylistItem]?) -> Swift.Void) {
        
        // Implicitly unwrap this because we're about to set it on the next line.
        var recursiveCompletion : ((Data?, URLResponse?, Error?) -> Swift.Void)!
        
        recursiveCompletion = { (data, response, error) -> Void in
            do {
                guard error == nil, let data = data else {
                    print("Error fetching data: \(error)")
                    return
                }
                if let jsonResult = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.allowFragments) as? [String : AnyObject] {
                    
                    self.token = jsonResult["nextPageToken"] as? String
                    
                    if let items = jsonResult["items"] as? [[String : Any]] {
                        for item in items {
                            var playlistItem = PlaylistItem()
                            
                            if let snippet = item["snippet"] as? [String : Any]{
                                if let title = snippet["title"] as? String {
                                    playlistItem.title = title
                                }
                                if let thumbnails = snippet["thumbnails"] as? [String : Any],
                                    let defaultInfo = thumbnails["medium"] as? [String : Any],
                                    let url = defaultInfo["url"] as? String {
                                    playlistItem.thumbnailUrl = url
                                }
                                if let resource = snippet["resourceId"] as? [String : Any] {
                                    if let videoId = resource["videoId"] as? String {
                                        playlistItem.id = videoId
										playlistItem.completed = UserDefaults.standard.bool(forKey: videoId)
                                    }
                                }
                            }
                            self.playlist.append(playlistItem)
                        }
                    }
                    
                    if self.token != nil {
                        // Still more pages to grab, keep going.
                        self.fetchPage(ofPlaylist: playlistID, completionHandler: recursiveCompletion)
                    } else {
                        // Done fetching the entire playlist contents, call the final completion handler
                        completionHandler(self.playlist)
                    }
                }
            }
            catch {
                print("Error serializing json: \(error)")
            }
        }
        
        // Kick off the first request
        fetchPage(ofPlaylist: playlistID, completionHandler: recursiveCompletion)
    }
}
