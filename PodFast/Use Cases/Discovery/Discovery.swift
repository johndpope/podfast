//
//  Discovery.swift
//  PodFast
//
//  Created by Orestis on 13/07/2019.
//  Copyright © 2019 Orestis Papadopoulos. All rights reserved.
//

import Foundation
import Promises
import RealmSwift

protocol DiscoveryInteractor {
    func getPodcastCategories() -> Promise<[PodcastCategory]>
    func getPodcasts() -> Promise<[Podcast]>
}

class Discovery: DiscoveryInteractor {
    let podcastCategoryRepository: AnyRepository<PodcastCategory>
    let podcastRepository: AnyRepository<Podcast>
    let episodeRepository: EpisodeRepositoryInterface

    init(withPodcastCategoryRepository repository: AnyRepository<PodcastCategory>
        = AnyRepository<PodcastCategory>(base: PodcastCategoryRepository()),
         withPodcastRepository podcastRepository: AnyRepository<Podcast>
        = AnyRepository<Podcast>(base: PodcastRepository()),
         withEpisodeRepository episodeRepository: EpisodeRepositoryInterface = EpisodeRepository()) {
        podcastCategoryRepository = repository
        self.podcastRepository = podcastRepository
        self.episodeRepository = episodeRepository
    }

    func getPodcastCategories() -> Promise<[PodcastCategory]> {
        return self.podcastCategoryRepository.getAll()
    }

    func getPodcasts() -> Promise<[Podcast]> {
        return self.podcastRepository.getAll().then { podcasts in
            podcasts.map { podcast in
                podcast.episodes = self.episodeRepository.getEpisodes(forPodcast: podcast, numberOfEpisodes: 10)
                return podcast
            }
        }
    }
}
