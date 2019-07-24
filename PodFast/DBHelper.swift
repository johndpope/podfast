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
        let stats = realm.objects(DataSetStats.self)
        return stats.first?.configVersion ?? 0
    }

    func getLastAppleTopPodcastsUpdateDate() -> Date {
        let realm = getRealm()
        if let stats = realm.objects(DataSetStats.self).first,
            let lastUpdate = stats.appleTopPodcastsLastUpdate{
            return lastUpdate
        } else {
            return Date(timeIntervalSince1970: 0)
        }
    }

    func updateLastAppleTopPodcastsUpdateDate(toDate pendingUpdateDate: Date) {
        do {
            let updatedStats = DataSetStats()
            updatedStats.appleTopPodcastsLastUpdate = pendingUpdateDate
            let realm = DBHelper.shared.getRealm()
            realm.beginWrite()
            realm.add(updatedStats, update: .modified)
            try realm.commitWrite()
        } catch {
            print(error)
        }
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
                podcasts.append(dbPodcast)
            }
        }

        // start Write transaction // Handle exceptions here
        let realm = getRealm()
        try! realm.write {
            // delete all podcasts in db ? :) NOOO :)
            let oldPodcasts = realm.objects(Podcast.self)
            for oldPodcast in oldPodcasts {
                // keep old episodes
                if let podcast = podcasts.first(where: { $0.title == oldPodcast.title }) {
                    podcast._episodes.append(objectsIn: oldPodcast._episodes)
                }
            }
            realm.delete(oldPodcasts)

            realm.add(podcasts)

//            let stats = realm.objects(DataSetStats.self)
//            realm.delete(oldConfig)
//
//            let updatedConfig = Config()
//            updatedConfig.configVersion = newVersion
//            realm.add(updatedConfig)

            try! realm.commitWrite()
        }
    }

    func updatePodcasts(fromItunesPodcastLookup response: ItunesPodcastLookUpResponse) {
        print("Updating Apple Top Podcasts List")
        var podcasts = [Podcast]()

        if let appleTopPodcasts = response.podcasts {
            podcasts = appleTopPodcasts.map { $0.toPodcastObject() }
        }
        do {
            let realm = getRealm()
            realm.beginWrite()
            realm.add(podcasts, update: .all)
            try realm.commitWrite()
        } catch {
            print("Error info: \(error)")
        }
    }
    
    func getRealm() -> Realm {
        return realm
    }
}
