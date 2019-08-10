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
import Promises

enum APIRequestError: Error {
    case noValueInResponse
    case tooLong
    case invalidCharacterFound(Character)
}

enum PodcastFeedError: Error {
    case invalidURL
    case notRSS
    case parserFailure
    case noItemsInFeed
}

struct AppleTopPodcastsRequest {
    let URL = "https://rss.itunes.apple.com/api/v1/us/podcasts/top-podcasts/all/100/explicit.json"

    func execute() -> Promise<AppleTopPodcastsResponse> {
        return Promise<AppleTopPodcastsResponse> { fulfill, reject in
            Alamofire.request(self.URL).responseObject { (response: DataResponse<AppleTopPodcastsResponse>) in
                switch response.result {
                case .success:
                    guard let topPodcasts = response.value else {
                        reject(APIRequestError.noValueInResponse)
                        return
                    }
                    fulfill(topPodcasts)
                case .failure(let error):
                    reject(error)
                }
            }
        }
    }
}

struct ApplePodcastLookupRequest {

    let baseURL = "https://itunes.apple.com/lookup?id="

    let podcastIDs: [String]

    init(_ podcastIDs: [String]) {
        self.podcastIDs = podcastIDs
    }

    private func prepareIDsForRequest(_ ids: [String]) -> String{
        var ids2 = ids.reduce("") { (ids:String, id:String) -> String in
            return ids.appending("\(id),")
        }
        ids2.removeLast()
        return ids2
    }

    func execute() -> Promise<ApplePodcastLookUpResponse> {
        let URL = baseURL.appending(prepareIDsForRequest(podcastIDs))
        return Promise<ApplePodcastLookUpResponse> { fulfill, reject in
            // Request the podcast data from itunes
            Alamofire.request(URL).responseObject { (response: DataResponse<ApplePodcastLookUpResponse>) in
                switch response.result {
                case .success:
                    // TODO: Duplication here :)
                    guard let topPodcasts = response.value else {
                        reject(APIRequestError.noValueInResponse)
                        return
                    }
                    fulfill(topPodcasts)
                case .failure(let error):
                    reject(error)
                }
            }
        }
    }
}

import FeedKit
struct PodcastFeedEpisodesRequest {
    let podcast: Podcast
    let numberOfEpisodesToRequest: Int

    init(_ podcast: Podcast, for numberOfEpisodesToParse: Int) {
        self.podcast = podcast
        self.numberOfEpisodesToRequest = numberOfEpisodesToParse
    }

    private func parsePodcastEpisodes(fromRssFeed feedItems: [RSSFeedItem]) -> [Episode] {
        var episodes = [Episode]()
        for feedItem in feedItems.prefix(self.numberOfEpisodesToRequest - 1) {
            let episode = Episode()
            episode.title = feedItem.title
            episode.episodeDescription = feedItem.description
            if let enclosure = feedItem.enclosure?.attributes {
                episode.url = enclosure.url
                episodes.append(episode)
            }
        }
        return episodes
    }

    func execute() -> Promise<[Episode]> {
        return Promise<[Episode]> { fulfill, reject in
            guard let feedUrlString = self.podcast.feedUrl,
                let feedUrl = URL(string: feedUrlString) else {
                    reject(PodcastFeedError.invalidURL)
                    return
            }
            let parser = FeedParser(URL: feedUrl)
            parser.parseAsync(queue: DispatchQueue.global(qos: .userInitiated)) { (result) in
                switch result {
                case let .rss(feed):
                    guard result.isSuccess else {
                        reject(PodcastFeedError.parserFailure)
                        return
                    }

                    guard let feedItems = feed.items else {
                        reject(PodcastFeedError.noItemsInFeed)
                        return
                    }
                    // TODO: assumption that there will always be episodes
                    let episodes = self.parsePodcastEpisodes(fromRssFeed: feedItems)
                    fulfill(episodes)
                case .atom(_):
                    reject(PodcastFeedError.notRSS)
                case .json(_):
                    reject(PodcastFeedError.notRSS)
                case .failure(_):
                    reject(PodcastFeedError.parserFailure)
                }
            }
        }
    }
}

struct ConfigurationDataRequest {
    let path = Bundle.main.path(forResource: "data", ofType: "json")!

    func execute() throws -> ConfigFileData? {
        let data = try Data(contentsOf: URL(fileURLWithPath: path), options: .mappedIfSafe)
        if let jsonData = try JSONSerialization.jsonObject(with: data, options: .mutableLeaves) as? [String:Any] {
            return ConfigFileData(JSON: jsonData) ?? nil
        }
        return nil
    }
}
