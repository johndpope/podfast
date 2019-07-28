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

    var podcastRepository: PodcastRepository = PodcastDataRepository()

    override func setUp() {
        podcastRepository = PodcastDataRepository(localDataSource: MockPodcastLocalDataSource(),
                                                remoteDataSource: MockPodcastRemoteDataSource(),
                                                configDataSource: MockPodcastConfigDataSource())
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
            self.podcastRepository.get().then { podcasts in
                XCTAssertEqual(podcasts.count, 1)
                self.podcastRepository.update(withPolicy: .config).then { _ in
                    self.podcastRepository.get().then { podcasts in
                        XCTAssertEqual(podcasts.count, 2)
                        expectation.fulfill()
                    }
                }
            }
        }

        waitForExpectations(timeout: 10)
    }

}

fileprivate class MockPodcastRemoteDataSource: PodcastDataSource {
    func fetchPodcasts() -> Promise<[Podcast]> {
        return Promise([Podcast(value: ["title" : "remotePodcast"])])
    }

    var lastUpdated: Promise<Date> {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy"
        return Promise<Date> (dateFormatter.date(from: "2018")!)
    }

    var description: String = "remoteDataSource"
}

fileprivate class MockPodcastConfigDataSource: PodcastDataSource {
    func fetchPodcasts() -> Promise<[Podcast]> {
        return Promise([Podcast(value: ["title" : "configPodcast"])])
    }

    var lastUpdated: Promise<Date> {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy"
        return Promise<Date> (dateFormatter.date(from: "2017")!)
    }

    var description: String = "configDataSource"
}

fileprivate class MockPodcastLocalDataSource: PodcastLocalDataSource {
    private var updateTimestamps = [String: Date]()
    private var podcasts = Set<Podcast>()

    func update(fromSource dataSource: PodcastDataSource) -> Promise<Bool> {
        return Promise { fulfill, reject in
            dataSource.fetchPodcasts().then { newPodcasts in
                newPodcasts.forEach { self.podcasts.insert($0) }
                dataSource.lastUpdated.then { datasourceLastUpdated in
                    self.updateTimestamps[dataSource.description] = datasourceLastUpdated
                }
                fulfill(true)
            }
        }
    }

    func get(lastUpdatedDatasourceDate dataSource: PodcastDataSource) -> Date {
        return updateTimestamps[dataSource.description] ?? Date(timeIntervalSince1970: 0)
    }

    func fetchPodcasts() -> Promise<[Podcast]> {
        return Promise(Array(podcasts))
    }

    var lastUpdated: Promise<Date> {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy"
        return Promise<Date> (dateFormatter.date(from: "2017")!)
    }

    var description: String = "localDataSource"
}

