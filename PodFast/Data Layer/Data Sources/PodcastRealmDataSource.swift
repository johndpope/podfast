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

public struct PodcastRealmDataSource: PodcastLocalDataSource {

    private let realm: Realm

    public var description = "realm_db_podcast"

    public init() {
        self.realm = DBHelper.shared.getRealm()
    }

    public func update(fromSource dataSource: PodcastDataSource) -> Promise<Bool> {
        return Promise<Bool> { fulfill, reject in
            dataSource.fetchPodcasts().then { podcasts in
                do {
                    self.realm.beginWrite()
                    self.realm.add(podcasts, update: .modified)
                    try self.realm.commitWrite()
                    try self.update(lastUpdatedDatasource: dataSource, to: Date())
                    fulfill(true)
                } catch let error as NSError {
                    reject(error)
                }
            }
        }
    }

    public func fetchPodcasts() -> Promise<[Podcast]>{
        // potential realm fuck here
        return Promise<[Podcast]> { fulfill, reject in
            fulfill(self.realm.objects(Podcast.self).map { object in
                return object
            })
        }
    }

    // that's for self!
    public var lastUpdated: Promise<Date> {
        get{
            return Promise<Date> (self.get(lastUpdatedDatasourceDate: self))
        }
    }

    public func get(lastUpdatedDatasourceDate dataSource: PodcastDataSource) -> Date {
        if let stats = self.realm.objects(DataSetUpdated.self).filter("dataSource == %@ ", dataSource.description).first,
           let lastUpdate = stats.date {
            return lastUpdate
        } else {
            return Date(timeIntervalSince1970: 0)
        }
    }

    private func update(lastUpdatedDatasource dataSource: PodcastDataSource, to date: Date) throws {
        let updatedStats = DataSetUpdated()
        updatedStats.dataSource = dataSource.description
        updatedStats.date = date
        realm.beginWrite()
        realm.add(updatedStats, update: .modified)
        try realm.commitWrite()
    }

}
