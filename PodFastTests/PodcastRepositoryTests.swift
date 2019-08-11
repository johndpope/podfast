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
    var podcastCategoryRepository = PodcastCategoryRepositoryImplementation()

    override func setUp() {
        podcastRepository = PodcastRepository( localDataSource: AnyLocalDataSource<Podcast>(base: MockPodcastLocalDataSource()),
                                            remoteDataSource: AnyDataSource<Podcast>(base: MockPodcastRemoteDataSource()),
                                            configDataSource: AnyDataSource<Podcast>(base: MockPodcastConfigDataSource()))
        podcastCategoryRepository = PodcastCategoryRepositoryImplementation(dataSource: AnyDataSource<PodcastCategory>(base: MockPodcastCategoryDataSource()))
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

    func testGetAll() {
        let podcastExpectation = self.expectation(description: "podcastExpecation")
        let podcastCategoriesExpectation = self.expectation(description: "podcastCategoriesExpecation")

        self.podcastRepository.update(withPolicy: .remote).then { _ in
            self.podcastRepository.getAll().then { podcasts in
                XCTAssertEqual(podcasts.count, 1)
                self.podcastRepository.update(withPolicy: .config).then { _ in
                    self.podcastRepository.getAll().then { podcasts in
                        XCTAssertEqual(podcasts.count, 2)
                        podcastExpectation.fulfill()
                    }
                }
            }
        }

        self.podcastCategoryRepository.getAll().then { podcastCategories in
            XCTAssertEqual(podcastCategories.count, 2)
            XCTAssertEqual(podcastCategories.filter { $0.name == "Spiritual Ballsacks" }.count, 1)
            XCTAssertEqual(podcastCategories.filter { $0.name == "Mum Talk" }.count, 1)
            podcastCategoriesExpectation.fulfill()
        }

        waitForExpectations(timeout: 10)
    }
}

