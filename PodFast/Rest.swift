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

    static func checkConfiguration() {
        if let path = Bundle.main.path(forResource: "data", ofType: "json") {
            do {
                let data = try Data(contentsOf: URL(fileURLWithPath: path), options: .mappedIfSafe)
                if let jsonData = try JSONSerialization.jsonObject(with: data, options: .mutableLeaves) as? [String:Any] {
                    if let configData = ConfigFileData(JSON: jsonData), let configVersion = configData.version {
                        if configVersion > DBHelper.shared.getCurrentConfigVersion() {
                            DBHelper.shared.updatePodcasts(fromConfigData: configData)
                        }
                    }
                }
            } catch {
                // handle error
            }
        }
    }

    static func topPodCastsRequest(count: Int, completionBlock: @escaping (DataResponse<[TopPodcastsResponse]>) -> Void)
    {
        let URL = "https://gpodder.net/toplist/\(count).json"
        Alamofire.request(URL).responseArray { (response: DataResponse<[TopPodcastsResponse]>) in
            completionBlock(response)
//            let topPodcastsArray = response.result.value
//
//            if let topPodcastsArray = topPodcastsArray {
//                for podcast in topPodcastsArray {
//                    if let feedURL = podcast.url {
//                        requestLatestPodcastEpisode(fromPodcastFeed: feedURL)
//                    }
//                }
//            }
        }
    }

    static func getEpisodes(forPodcast podcast: Podcast, count: Int, completionBlock: @escaping ([Episode]) -> Void) {
        guard let feedUrlString = podcast.feedUrl,
            let feedUrl = URL(string: feedUrlString) else {
            print("GetEpisodes -- Invalid Url")
            return
        }

        let parser = FeedParser(URL: feedUrl)
        print("Trying to fetch \(feedUrl)")
        parser.parseAsync(queue: DispatchQueue.global(qos: .userInitiated)) { (result) in
            switch result {
            case let .rss(feed):
                guard result.isSuccess else {
                    print("GetEpisodes -- Could not parse feed URL from String")
                    return
                }

                guard let feedItems = feed.items else {
                    print("GetEpisodes -- Feed contains no items")
                    return
                }

                guard count < feedItems.count else {
                    print("GetEpisodes -- You asked for more than what exists")
                    return
                }

                var episodes = [Episode]()
                for feedItem in feedItems.prefix(count) {
                    let episode = Episode()
                    episode.title = feedItem.title
                    episode.episodeDescription = feedItem.description
                    if let enclosure = feedItem.enclosure?.attributes {
                        episode.url = enclosure.url
                        episodes.append(episode)
                    }
                }
                DispatchQueue.main.async {
                    completionBlock(episodes)
                }
            default:
                break

            }
        }
    }

//    static func requestLatestPodcastEpisode(fromPodcastFeed podcastFeed: URL){
//            let parser = FeedParser(URL: podcastFeed)
//
//            parser.parseAsync(queue: DispatchQueue.global(qos: .userInitiated)) { (result) in
//                // Do your thing, then back to the Main thread
//                switch result {
//                case .atom(_):
//                    print("ATOM FEED")   // Atom Syndication Format Feed Model
//                case let .rss(feed):    // THE DEFAULT FOR Podcasts
//                    print("RSS FEED")
//                    guard result.isSuccess else {
//                        print("Couldn't parse the RSS Feed")
//                        return
//                    }
//                    if let latestRssPostEnclosure = feed.items?.first?.enclosure?.attributes {
//                        autoreleasepool {
//                            let realm = try! Realm()
//                            let podcast = Podcast()
////                            podcast.url = latestRssPostEnclosure.url
//                            realm.beginWrite()
//                            realm.add(podcast)
//                            try! realm.commitWrite()
//                        }
////                        print(latestRssPostEnclosure.url ?? "")
////                        print(latestRssPostEnclosure.length ?? UInt64(0))
////                        print(latestRssPostEnclosure.type ?? "")
//                    }
//                case .json(_):
//                    print("JSON FEED") // JSON Feed Model
//                case .failure(_):
//                    print("FAILURE")
//                }
////                DispatchQueue.main.async {
////                    // ..and update the UI
////                }
//            }
//    }
}

