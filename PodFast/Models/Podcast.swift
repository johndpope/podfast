//
//  Podcast.swift
//  PodFast
//
//  Created by Orestis on 13/07/2019.
//  Copyright © 2019 Orestis Papadopoulos. All rights reserved.
//

import Foundation
import RealmSwift
import AlamofireObjectMapper
import ObjectMapper
import ReactiveSwift
import ReactiveCocoa
import enum Result.NoError

class Podcast: Object {
    @objc dynamic var id = 0
    @objc dynamic var feedUrl: String?
    @objc dynamic var title: String?
    @objc dynamic var podcastDescription: String?
    @objc dynamic var hasBeenDiscovered: Bool = false
    public let _episodes = List<Episode>()

    override static func ignoredProperties() -> [String] {
        return ["episodeStream"]
    }

    override static func primaryKey() -> String? {
        return "id"
    }

    public lazy var episodeStream = SignalProducer<Episode, NoError> { (observer, lifetime) in
            if self._episodes.count > 0 {
                for episode in self._episodes {
                    observer.send(value: episode)
                }
            } else {
                let realm = DBHelper.shared.getRealm()
                try! Rest.getEpisodes(forPodcast: self, count: 5)
                    .observe(on: UIScheduler())
                    .observeValues { episode in
                        realm.beginWrite()
                        self._episodes.append(episode)
                        try! realm.commitWrite()
                        observer.send(value: episode)
                    }
            }
    }

    func deleteAllEpisodes() {
        let realm = DBHelper.shared.getRealm()
        realm.beginWrite()
        self._episodes.removeAll()
        try! realm.commitWrite()
    }

    func getEpisodes(count: Int, completionBlock: @escaping ([Episode]) -> Void) {
//        Rest.getEpisodes(forPodcast: self, count: 5 , completionBlock: { newEpisodes in
//            let realm = DBHelper.shared.getRealm()
//            realm.beginWrite()
//            self._episodes.removeAll()
//            self._episodes.append(objectsIn: newEpisodes)
//            try! realm.commitWrite()
//            completionBlock(newEpisodes)
//        })
    }
}
