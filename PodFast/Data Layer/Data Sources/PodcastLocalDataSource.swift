//
//  PodcastLocalDataSource.swift
//  PodFast
//
//  Created by Orestis on 27/07/2019.
//  Copyright © 2019 Orestis Papadopoulos. All rights reserved.
//
import Realm
import RealmSwift
import Promises

public struct PodcastLocalDataSource: PodcastDataSource {

    private let realm: Realm

    public init() {
        self.realm = DBHelper.shared.getRealm()
    }

    public func update(fromPodcasts podcasts: [Podcast]) -> Promise<Bool> {
        return Promise<Bool> { fulfill, reject in
            // Called asynchronously on the default queue.
            do {
                self.realm.beginWrite()
                self.realm.add(podcasts, update: .modified)
                try self.realm.commitWrite()
                try self.updateStats()
                fulfill(true)
            } catch let error as NSError {
                reject(error)
            }
        }
    }

    public func fetchPodcasts() -> Promise<[Podcast]>{
        return Promise<[Podcast]> { fulfill, reject in
            // Called asynchronously on the default queue.
            fulfill([])
        }
    }

    public var lastUpdated: Promise<Date> {
        get{
            return Promise { () -> Date in
                if let stats = self.realm.objects(DataSetStats.self).first,
                    let lastUpdate = stats.appleTopPodcastsLastUpdate{
                    return lastUpdate
                } else {
                    return Date(timeIntervalSince1970: 0)
                }
            }
        }
    }

    private func updateStats() throws {
        let updatedStats = DataSetStats()
        updatedStats.appleTopPodcastsLastUpdate = Date()
        realm.beginWrite()
        realm.add(updatedStats, update: .modified)
        try realm.commitWrite()
    }

}
