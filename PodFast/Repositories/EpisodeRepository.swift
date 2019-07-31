//
//  EpisodeRepository.swift
//  PodFast
//
//  Created by Orestis on 31/07/2019.
//  Copyright © 2019 Orestis Papadopoulos. All rights reserved.
//

import Foundation
import Promises

protocol EpisodeRepositoryInterface {
    func getEpisodes(forPodcast podcast: Podcast, numberOfEpisodes: Int) -> Promise<[Episode]>
}

class EpisodeRepository: EpisodeRepositoryInterface {

    private let localDataSource: EpisodeLocalDataSource
    private let remoteDataSource: EpisodeDataSource

    public init(localDataSource: EpisodeLocalDataSource = EpisodeRealmDataSource(),
        remoteDataSource: EpisodeRemoteDataSource = EpisodeRemoteDataSource()) {
        self.localDataSource = localDataSource
        self.remoteDataSource = remoteDataSource
    }

    func getEpisodes(forPodcast podcast: Podcast, numberOfEpisodes: Int) -> Promise<[Episode]> {
        return Promise<[Episode]> { fulfill, reject in
            self.localDataSource.getEpisodes(forPodcast: podcast).then { episodes in
                if episodes.count > 0 {
                    fulfill(episodes)
                } else {
                    self.remoteDataSource.fetchEpisodes(forPodcast: podcast, numberOfEpisodesToFetch: numberOfEpisodes).then { episodes in
                        self.localDataSource.updatePodcastEpisodes(forPodcast: podcast, episodes: episodes)
                        fulfill(episodes)
                    }
                }
            }
        }
    }
}
