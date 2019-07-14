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

class Podcast: Object {
    @objc dynamic var id = 0
    @objc dynamic var feedUrl: String?
    @objc dynamic var title: String?
    @objc dynamic var podcastDescription: String?
    @objc dynamic var hasBeenDiscovered: Bool = false
    let episodes = List<Episode>()

    override static func primaryKey() -> String? {
        return "id"
    }

    func deleteAllEpisodes() {
        let realm = DBHelper.shared.getRealm()
        realm.beginWrite()
        self.episodes.removeAll()
        try! realm.commitWrite()
    }

    func getEpisodes(count: Int, completionBlock: @escaping ([Episode]) -> Void) {
        Rest.getEpisodes(forPodcast: self, count: 5 , completionBlock: { newEpisodes in
            let realm = DBHelper.shared.getRealm()
            realm.beginWrite()
            self.episodes.removeAll()
            self.episodes.append(objectsIn: newEpisodes)
            try! realm.commitWrite()
            completionBlock(newEpisodes)
        })
    }
}
