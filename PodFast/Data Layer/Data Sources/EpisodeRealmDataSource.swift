//
//  EpisodeRealmDataSource.swift
//  PodFast
//
//  Created by Orestis on 31/07/2019.
//  Copyright © 2019 Orestis Papadopoulos. All rights reserved.
//

import Foundation
import RealmSwift
import Promises

protocol EpisodeLocalDataSource {
    func getEpisodes(forPodcast podcast: Podcast) -> Promise<[Episode]>
    func updatePodcastEpisodes(forPodcast podcast: Podcast, episodes: [Episode])
}

public struct EpisodeRealmDataSource: EpisodeLocalDataSource {

    private let realm: Realm

    public init(realm: Realm? = nil) {
        self.realm = realm ?? DBHelper.shared.getRealm()
    }

    func getEpisodes(forPodcast podcast: Podcast) -> Promise<[Episode]> {
        // potential realm fuck here
        return Promise<[Episode]> { fulfill, reject in
            if let episodes = self.realm.objects(Podcast.self).first(where: {$0.title == podcast.title})?._episodes {
                fulfill(episodes.map { object in
                    return object
                })
            }
        }
    }

    func updatePodcastEpisodes(forPodcast podcast: Podcast, episodes: [Episode]) {
        do {
            self.realm.beginWrite()
            podcast._episodes.removeAll()
            podcast._episodes.append(objectsIn: episodes)
            self.realm.add(podcast, update: Realm.UpdatePolicy.all)
            try self.realm.commitWrite()
        } catch let error as NSError {
            print(error)
        }
    }

}
