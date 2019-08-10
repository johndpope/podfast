//
//  PodcastCategoryRealmDataSource.swift
//  PodFast
//
//  Created by Orestis on 28/07/2019.
//  Copyright © 2019 Orestis Papadopoulos. All rights reserved.
//

import Promises
import RealmSwift

struct PodcastCategoryRealmDataSource: DataSource {

    private let realm: Realm

    public init(realm: Realm? = nil) {
        self.realm = realm ?? DBHelper.shared.getRealm()
    }

    func fetchAll() -> Promise<[PodcastCategory]> {
        // potential realm fuck here
        return Promise<[PodcastCategory]> { fulfill, reject in
            fulfill(self.realm.objects(PodcastCategory.self).map { object in
                return object
            })
        }
    }

    func lastUpdated() -> Promise<Date> {
        return Promise<Date> { () -> Date in
            if let stats = self.realm.objects(DataSetUpdated.self).filter("dataSource == %@ ", self.description).first,
                let lastUpdate = stats.date {
                return lastUpdate
            } else {
                return Date(timeIntervalSince1970: 0)
            }
        }
    }

    var description: String = "podcastCategoryRealmDatasource"

}
