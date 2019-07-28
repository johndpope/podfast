//
//  PodcastRepositoryTests.swift
//  PodFastTests
//
//  Created by Orestis on 28/07/2019.
//  Copyright © 2019 Orestis Papadopoulos. All rights reserved.
//

import XCTest
import Promises
@testable import PodFast

class PodcastRepositoryTests: XCTestCase {

    var podcastRepository = PodcastRepository()

    override func setUp() {
        podcastRepository = PodcastRepository( localDataSource: AnyLocalDataSource<Podcast>(base: MockPodcastLocalDataSource()),
                                            remoteDataSource: AnyDataSource<Podcast>(base: MockPodcastRemoteDataSource()),
                                            configDataSource: AnyDataSource<Podcast>(base: MockPodcastConfigDataSource()) )
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testUpdates() {
        let expectation = self.expectation(description: #function)

        self.podcastRepository.update(withPolicy: .remote).then { wasUpdated in
            XCTAssertEqual(wasUpdated, true, "Update from fresh remote")
            self.podcastRepository.update(withPolicy: .config).then { wasUpdated in
                XCTAssertEqual(wasUpdated, true, "Update from fresh config")
                self.podcastRepository.update(withPolicy: .remote).then { wasUpdated in
                    XCTAssertEqual(wasUpdated, false, "Do not update from older remote")
                    self.podcastRepository.update(withPolicy: .remote).then { wasUpdated in
                        XCTAssertEqual(wasUpdated, false, "Do not update from older config")
                        expectation.fulfill()
                    }
                }
            }
        }

        waitForExpectations(timeout: 10)
    }

    func testGet() {
        let expectation = self.expectation(description: #function)

        self.podcastRepository.update(withPolicy: .remote).then { _ in
            self.podcastRepository.getAll().then { podcasts in
                XCTAssertEqual(podcasts.count, 1)
                self.podcastRepository.update(withPolicy: .config).then { _ in
                    self.podcastRepository.getAll().then { podcasts in
                        XCTAssertEqual(podcasts.count, 2)
                        expectation.fulfill()
                    }
                }
            }
        }

        waitForExpectations(timeout: 10)
    }

}

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

