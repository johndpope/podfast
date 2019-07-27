//
//  PodcastRepository.swift
//  PodFast
//
//  Created by Orestis on 25/07/2019.
//  Copyright © 2019 Orestis Papadopoulos. All rights reserved.
//
import Promises

class PodcastDataRepository: PodcastRepository {

    private let localDataSource: PodcastDataSource
    private let remoteDataSource: PodcastDataSource

    public init(remoteDataSource: PodcastDataSource = PodcastRemoteDataSource(),
               localDataSource: PodcastDataSource = PodcastLocalDataSource()) {
        self.remoteDataSource = remoteDataSource
        self.localDataSource = localDataSource
    }

    public func update() -> Promise<Bool> {
        return Promise<Bool> { fulfill, reject in
            self.isUpToDate().then { isUpToDate in
                if !isUpToDate {
                    // Update Logic
                    self.remoteDataSource.fetchPodcasts().then {
                        podcasts in
                        self.localDataSource.update(fromPodcasts: podcasts).then { updateStatus in
                            fulfill(updateStatus)
                        }
                    }
                }
            }
        }
    }

    public func isUpToDate() -> Promise<Bool> {
        return Promise<Bool> { fulfill, reject in
            self.localDataSource.lastUpdated.then { localUpdated in
                self.remoteDataSource.lastUpdated.then { remoteUpdated in
                    fulfill(localUpdated >= remoteUpdated)
                }
            }
        }
    }
}
