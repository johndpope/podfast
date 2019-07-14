//
//  DBHelper.swift
//  PodFast
//
//  Created by Orestis on 10/07/2019.
//  Copyright © 2019 Orestis Papadopoulos. All rights reserved.
//

import Foundation
import RealmSwift
import Realm

class DBHelper{
    static let shared = DBHelper()

    private init(){

    }

    private lazy var realm = try! Realm(configuration: defaultConfiguration)

    var defaultConfiguration: Realm.Configuration {
        var config = Realm.Configuration()
        config.deleteRealmIfMigrationNeeded = true
        config.schemaVersion = 1
        return config
    }

    func getCurrentConfigVersion() -> Int {
        let realm = getRealm()
        let config = realm.objects(Config.self)
        return config.first?.version ?? 0
    }

    func updatePodcasts(fromConfigData configData: ConfigFileData) {
        guard let newVersion = configData.version else {
            return
        }

        var podcasts = [Podcast]()

        for configPodcast in configData.podcasts {
            if let configPodcast = ConfigPodcast(JSON: configPodcast) {
                let dbPodcast = Podcast()
                dbPodcast.feedUrl = configPodcast.url
                dbPodcast.title = configPodcast.title
                dbPodcast.podcastDescription = configPodcast.description
                dbPodcast.hasBeenDiscovered = false //TODO: you don't know this :)
                dbPodcast.id = UUID().hashValue
                podcasts.append(dbPodcast)
            }
        }

        // start Write transaction // Handle exceptions here
        let realm = getRealm()
        try! realm.write {
            // delete all podcasts in db ? :)
            let oldPodcasts = realm.objects(Podcast.self)
            for oldPodcast in oldPodcasts {
                if let podcast = podcasts.first(where: { $0.title == oldPodcast.title }) {
                    podcast.episodes.append(objectsIn: oldPodcast.episodes)
                }
            }
            realm.delete(oldPodcasts)

            realm.add(podcasts)

            let oldConfig = realm.objects(Config.self)
            realm.delete(oldConfig)

            let updatedConfig = Config()
            updatedConfig.version = newVersion
            realm.add(updatedConfig)

            try! realm.commitWrite()
        }
    }
    
    func getRealm() -> Realm {
        return realm
    }
}
