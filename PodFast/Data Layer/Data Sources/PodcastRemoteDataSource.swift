//
//  PodcastRemoteDataSource.swift
//  PodFast
//
//  Created by Orestis on 27/07/2019.
//  Copyright © 2019 Orestis Papadopoulos. All rights reserved.
//
import Promises

public struct PodcastRemoteDataSource: DataSource {

    public var description = "apple_top_podcasts"

    public init() {}

    public typealias DataType = Podcast
    
    public func fetchAll() -> Promise<[Podcast]> {
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

    public func lastUpdated() -> Promise<Date> {
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
