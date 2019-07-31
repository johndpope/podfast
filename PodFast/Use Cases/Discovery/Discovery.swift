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
    func getPodcasts() -> Promise<[Podcast]>
    func getEpisodes(forPodcast podcast: Podcast) -> Promise<[Episode]>
}
class Discovery: DiscoveryInteractor {
    let podcastCategoryRepository: AnyRepository<PodcastCategory>
    let episodeRepository: EpisodeRepositoryInterface

    init(withPodcastCategoryRepository repository: AnyRepository<PodcastCategory>
        = AnyRepository<PodcastCategory>(base: PodcastCategoryRepository()),
         andEpisodeRepository episodeRepository: EpisodeRepositoryInterface = EpisodeRepository()) {
        podcastCategoryRepository = repository
        self.episodeRepository = episodeRepository
    }

    func getPodcasts() -> Promise<[Podcast]> {
        return Promise<[Podcast]> { fulfill, reject in
            self.podcastCategoryRepository.getAll().then { podcastCategories in

                var podcasts = [Podcast]()
                for podcastCategory in podcastCategories {

                    let categoryList = List<PodcastCategory>()
                    categoryList.append(podcastCategory)
                    if let podcast = podcastCategory.podcasts.randomElement(){
                        podcasts.append(Podcast(value: ["title" : podcast.title ?? ""
                                                      , "podcastDescription" : podcast.podcastDescription ?? ""
                                                      , "feedUrl" : podcast.feedUrl ?? ""
                                                      , "_episodes" : podcast._episodes
                                                      , "categories" : categoryList]))
                    }
                }

                fulfill(podcasts.shuffled())
            }
        }
    }

    func getEpisodes(forPodcast podcast: Podcast) -> Promise<[Episode]> {
        return episodeRepository.getEpisodes(forPodcast: podcast, numberOfEpisodes: 10)
    }
}
