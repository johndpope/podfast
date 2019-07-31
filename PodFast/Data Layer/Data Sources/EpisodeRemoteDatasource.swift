//
//  EpisodeRemoteDatasource.swift
//  PodFast
//
//  Created by Orestis on 31/07/2019.
//  Copyright © 2019 Orestis Papadopoulos. All rights reserved.
//

import Foundation
import Promises

protocol EpisodeDataSource {
    func fetchEpisodes(forPodcast: Podcast, numberOfEpisodesToFetch: Int) -> Promise<[Episode]>
}

class EpisodeRemoteDataSource: EpisodeDataSource {
    func fetchEpisodes(forPodcast podcast: Podcast, numberOfEpisodesToFetch: Int) -> Promise<[Episode]> {
        return PodcastFeedEpisodesRequest.init(podcast, for: numberOfEpisodesToFetch).execute()
    }

    public init() {}

}
