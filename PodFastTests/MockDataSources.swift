//
//  MockDataSources.swift
//  PodFastTests
//
//  Created by Orestis on 28/07/2019.
//  Copyright © 2019 Orestis Papadopoulos. All rights reserved.
//
import Promises
@testable import PodFast

class MockPodcastRemoteDataSource: DataSource {
    func fetchAll() -> Promise<[Podcast]> {
        return Promise([Podcast(value: ["title" : "remotePodcast"])])
    }

    func lastUpdated() -> Promise<Date> {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy"
        return Promise<Date> (dateFormatter.date(from: "2018")!)
    }

    var description: String = "remoteDataSource"
}

class MockPodcastConfigDataSource: DataSource {
    func fetchAll() -> Promise<[Podcast]> {
        return Promise([Podcast(value: ["title" : "configPodcast"])])
    }

    func lastUpdated() -> Promise<Date> {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy"
        return Promise<Date> (dateFormatter.date(from: "2017")!)
    }

    var description: String = "configDataSource"
}

class MockPodcastLocalDataSource: LocalDataSource {

    typealias DataType = Podcast

    func update<D>(fromSource dataSource: D) -> Promise<Bool> where D : DataSource, DataType == D.DataType {
        return Promise { fulfill, reject in
            self.isUpToDate(with: AnyDataSource<Podcast>(base: dataSource)).then { localIsUpToDateWithSource in
                if !localIsUpToDateWithSource {
                    dataSource.fetchAll().then { newPodcasts in
                        newPodcasts.forEach { self.podcasts.insert($0) }
                        dataSource.lastUpdated().then { datasourceLastUpdated in
                            self.updateTimestamps[dataSource.description] = datasourceLastUpdated
                        }
                        fulfill(true)
                    }
                } else {
                    fulfill(false)
                }
            }
        }
    }

    func get<D>(lastUpdatedDatasourceDate dataSource: D) -> Date where D : DataSource, D.DataType == DataType {
        return updateTimestamps[dataSource.description] ?? Date(timeIntervalSince1970: 0)
    }

    func lastUpdated() -> Promise<Date> {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy"
        return Promise<Date> (dateFormatter.date(from: "2017")!)
    }

    private var updateTimestamps = [String: Date]()
    private var podcasts = Set<Podcast>()

    func fetchAll() -> Promise<[Podcast]> {
        return Promise(Array(podcasts))
    }

    private func isUpToDate(with dataSource: AnyDataSource<Podcast>) -> Promise<Bool> {
        return Promise<Bool> { fulfill, reject in
            let savedDataSourceUpdatedDate = self.get(lastUpdatedDatasourceDate: dataSource)
            dataSource.lastUpdated().then { dataSourceUpdatedDate in
                fulfill(savedDataSourceUpdatedDate >= dataSourceUpdatedDate)
            }
        }
    }

    var description: String = "localDataSource"
}

class MockPodcastCategoryDataSource: DataSource {

    func fetchAll() -> Promise<[PodcastCategory]> {
        // potential realm fuck here
        return Promise<[PodcastCategory]> ( [PodcastCategory(value: ["id" : 1234, "name" : "Spiritual Ballsacks"]),
                                             PodcastCategory(value: ["id" : 3190, "name" : "Mum Talk"])] )
    }

    func lastUpdated() -> Promise<Date> {
        return Promise<Date>(Date())
    }

    var description: String = "mockPodcastCategoryRealmDatasource"
}
