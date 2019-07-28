//
//  PodcastRealmDataSourceTests.swift
//  PodFastTests
//
//  Created by Orestis on 28/07/2019.
//  Copyright © 2019 Orestis Papadopoulos. All rights reserved.
//

import XCTest
import RealmSwift
import Promises
@testable import PodFast

class PodcastRealmDataSourceTests: XCTestCase {

    var realm: Realm?
    var podcastRealmDataSource: PodcastRealmDataSource?

    override func setUp() {
        var config = Realm.Configuration()

        // Use the default directory, but replace the filename with the username
        config.fileURL = config.fileURL!.deletingLastPathComponent().appendingPathComponent("PodcastRealmDataSourceTestsTest.realm")
        print(config.fileURL!)

        // Open the Realm with the configuration
        realm = try! Realm(configuration: config)
        podcastRealmDataSource = PodcastRealmDataSource(realm: realm)
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        realm?.beginWrite()
        realm?.deleteAll()
        try! realm?.commitWrite()
    }

    func testUpdates() {
        let expectation = self.expectation(description: #function)

        self.podcastRealmDataSource?.update(fromSource: MockPodcastRemoteDataSource()).then { wasUpdated in
            XCTAssertEqual(wasUpdated, true, "Update from fresh remote")
            self.podcastRealmDataSource?.update(fromSource: MockPodcastConfigDataSource()).then { wasUpdated in
                XCTAssertEqual(wasUpdated, true, "Update from fresh config")
                self.podcastRealmDataSource?.update(fromSource: MockPodcastRemoteDataSource()).then { wasUpdated in
                    XCTAssertEqual(wasUpdated, false, "Do not update from older remote")
                    self.podcastRealmDataSource?.update(fromSource: MockPodcastConfigDataSource()).then { wasUpdated in
                        XCTAssertEqual(wasUpdated, false, "Do not update from older config")
                        expectation.fulfill()
                    }
                }
            }
        }

        waitForExpectations(timeout: 10)
    }

    func testFetchAll() {
        let expectation = self.expectation(description: #function)

        self.podcastRealmDataSource?.update(fromSource: MockPodcastRemoteDataSource()).then { wasUpdated in
            XCTAssertEqual(wasUpdated, true, "Update from fresh remote")
            self.podcastRealmDataSource?.update(fromSource: MockPodcastConfigDataSource()).then { wasUpdated in
                XCTAssertEqual(wasUpdated, true, "Update from fresh config")
                self.podcastRealmDataSource?.fetchAll().then { podcasts in
                    XCTAssertEqual(podcasts.count, 2)
                    XCTAssertEqual(podcasts.filter { $0.title == "configPodcast" }.count, 1)
                    XCTAssertEqual(podcasts.filter { $0.title == "remotePodcast" }.count, 1)
                    expectation.fulfill()
                }
            }
        }

        waitForExpectations(timeout: 10)
    }

}
