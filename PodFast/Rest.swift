//
//  Rest.swift
//  PodFast
//
//  Created by Orestis on 10/07/2019.
//  Copyright © 2019 Orestis Papadopoulos. All rights reserved.
//

import Foundation
import AlamofireObjectMapper
import Alamofire
import FeedKit
import RealmSwift

class Rest {
    static func requestTopPodcasts(count: Int)
    {
        let URL = "https://gpodder.net/toplist/\(count).json"
        Alamofire.request(URL).responseArray { (response: DataResponse<[TopPodcastsResponse]>) in

            let topPodcastsArray = response.result.value

            if let topPodcastsArray = topPodcastsArray {
                for podcast in topPodcastsArray {
                    if let feedURL = podcast.url {
                        requestLatestPodcastEpisode(fromPodcastFeed: feedURL)
                    }
                }
            }
        }
    }

    static func requestLatestPodcastEpisode(fromPodcastFeed podcastFeed: URL){
            let parser = FeedParser(URL: podcastFeed)

            parser.parseAsync(queue: DispatchQueue.global(qos: .userInitiated)) { (result) in
                // Do your thing, then back to the Main thread
                switch result {
                case .atom(_):
                    print("ATOM FEED")   // Atom Syndication Format Feed Model
                case let .rss(feed):    // THE DEFAULT FOR Podcasts
                    print("RSS FEED")
                    guard result.isSuccess else {
                        print("Couldn't parse the RSS Feed")
                        return
                    }
                    if let latestRssPostEnclosure = feed.items?.first?.enclosure?.attributes {
                        autoreleasepool {
                            let realm = try! Realm()
                            let podcast = Podcast()
                            podcast.url = latestRssPostEnclosure.url
                            realm.beginWrite()
                            realm.add(podcast)
                            try! realm.commitWrite()
                        }
//                        print(latestRssPostEnclosure.url ?? "")
//                        print(latestRssPostEnclosure.length ?? UInt64(0))
//                        print(latestRssPostEnclosure.type ?? "")
                    }
                case .json(_):
                    print("JSON FEED") // JSON Feed Model
                case .failure(_):
                    print("FAILURE")
                }
//                DispatchQueue.main.async {
//                    // ..and update the UI
//                }
            }
    }
}
