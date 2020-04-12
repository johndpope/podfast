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
    func advancePlayCount(ofCategory category: PodcastCategory)
    func getPodcastCategories() -> Promise<[PodcastCategory]>
    func getEpisodeOfPodcast(inCategory: PodcastCategory) -> Promise<Episode>
    func markAsPlayed(episode: Episode)
    func removePodcast(podcast: Podcast)
}

class Discovery: DiscoveryInteractor {
    let podcastCategoryRepository: PodcastCategoryRepository
    let podcastRepository: AnyRepository<Podcast>
    // TODO: The episode repository should be embedded in podcast repository
    // as a private method and be called when getAll is called
    let episodeRepository: EpisodeRepositoryInterface

    var podcasts = [Podcast]()

    init(withPodcastCategoryRepository repository: PodcastCategoryRepository = PodcastCategoryRepositoryImplementation(),
         withPodcastRepository podcastRepository: AnyRepository<Podcast>
        = AnyRepository<Podcast>(base: PodcastRepository()),
         withEpisodeRepository episodeRepository: EpisodeRepositoryInterface = EpisodeRepository()) {
        podcastCategoryRepository = repository
        self.podcastRepository = podcastRepository
        self.episodeRepository = episodeRepository

        getPodcasts().then {podcasts in self.podcasts = podcasts}
    }

    func getPodcastCategories() -> Promise<[PodcastCategory]> {
        return self.podcastCategoryRepository.getAll(sortedBy: \.plays)
    }

    func getEpisodeOfPodcast(inCategory category: PodcastCategory) -> Promise<Episode> {
        let podcastsInCategory = podcasts.filter { $0.categories.filter { $0 == category }.count > 0 }

        if let randomPodcast = podcastsInCategory.randomElement() {
            return Promise<Episode> { fulfill, reject in
                randomPodcast.episodes.then { episodes in
                    if episodes.count == 0 {
                        reject(DiscoveryError.NoEpisodesInPodcast(podcast: randomPodcast))
                    }
                    let unplayedEpisodes = episodes.filter { $0.hasBeenPlayed == false }
                    if unplayedEpisodes.count > 0 {
                        let randomEpisode = unplayedEpisodes.randomElement()!
                        if let episodeURLString = randomEpisode.url,
                            let _ = URL(string: episodeURLString) {
                            fulfill(randomEpisode)
                        } else {
                            reject(DiscoveryError.InvalidEpisodeURL)
                        }

                    } else {
                        reject(DiscoveryError.NoUnplayedEpisode)
                    }
                }
            }
        }
        return Promise<Episode>{fulfill, reject in reject(DiscoveryError.NoPodcastsInCategory)}
    }

    private func getPodcasts() -> Promise<[Podcast]> {
        return self.podcastRepository.getAll().then { podcasts in
            podcasts.map { podcast in
                podcast.episodes = self.episodeRepository.getEpisodes(forPodcast: podcast, numberOfEpisodes: 10)
                return podcast
            }
        }
    }

    func advancePlayCount(ofCategory category: PodcastCategory) {
        do {
            let realm = DBHelper.shared.getRealm()
            realm.beginWrite()
            category.plays = category.plays + 1
            try realm.commitWrite()
        } catch let error {
            print(error.localizedDescription)
        }
    }

    func removePodcast(podcast: Podcast) {
        do {
            let realm = DBHelper.shared.getRealm()
            realm.beginWrite()
            if let podcast = realm.object(ofType: Podcast.self, forPrimaryKey: podcast.title) {
                realm.delete(podcast)
            }
            try realm.commitWrite()
        } catch let error {
            print(error.localizedDescription)
        }
    }

    func markAsPlayed(episode: Episode) {
        do {
            let realm = DBHelper.shared.getRealm()
            realm.beginWrite()
            episode.hasBeenPlayed = true
            try realm.commitWrite()
        } catch let error {
            print(error.localizedDescription)
        }
    }
}
