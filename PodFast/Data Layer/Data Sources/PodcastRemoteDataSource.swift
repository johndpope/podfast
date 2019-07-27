//
//  PodcastRemoteDataSource.swift
//  PodFast
//
//  Created by Orestis on 27/07/2019.
//  Copyright © 2019 Orestis Papadopoulos. All rights reserved.
//
import Promises

public struct PodcastRemoteDataSource: PodcastDataSource {

    public var description = "apple_top_podcasts"

    public init() {}

    public func fetchPodcasts() -> Promise<[Podcast]> {
        return Promise<[Podcast]> { fulfill, reject in
            // Get Podcast Top 100
            AppleTopPodcastsRequest().execute().then { topPodcastsResponse in
                guard let podcasts = topPodcastsResponse.podcasts else {
                    reject(APIRequestError.noValueInResponse)
                    return
                }
                let podcastIds = podcasts.compactMap { $0.id }
                // Find Podcasts on Itunes (in order to retrieve feedurl etc.)
                ApplePodcastLookupRequest(podcastIds).execute().then { itunesPodcastsResponse in
                    // Get their episodes
                    guard let podcasts = itunesPodcastsResponse.podcasts else {
                        reject(APIRequestError.noValueInResponse)
                        return
                    }
                    fulfill(podcasts.map { $0.toPodcastObject() })
                }
                }.catch { error in
                    print(error)
            }
        }
    }

    public var lastUpdated: Promise<Date> {
        get{
            return Promise<Date> { fulfill, reject in
                AppleTopPodcastsRequest().execute().then { (topPodcastsResponse: AppleTopPodcastsResponse) in
                    guard let updated = topPodcastsResponse.updated else {
                        reject(APIRequestError.noValueInResponse)
                        return
                    }
                    fulfill(updated)
                }
            }
        }
    }

}
