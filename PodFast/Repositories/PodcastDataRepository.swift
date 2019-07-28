//
//  PodcastRepository.swift
//  PodFast
//
//  Created by Orestis on 25/07/2019.
//  Copyright © 2019 Orestis Papadopoulos. All rights reserved.
//

import Promises

class PodcastDataRepository: PodcastRepository {

    private let localDataSource: PodcastLocalDataSource
    private let remoteDataSource: PodcastDataSource
    private let configDataSource: PodcastDataSource

    public init(localDataSource: PodcastLocalDataSource = PodcastRealmDataSource(),
               remoteDataSource: PodcastDataSource = PodcastRemoteDataSource(),
               configDataSource: PodcastDataSource = PodcastConfigurationDataSource()) {
        self.remoteDataSource = remoteDataSource
        self.localDataSource = localDataSource
        self.configDataSource = configDataSource
    }

    public func get() -> Promise<[Podcast]> {
        return localDataSource.fetchPodcasts()
    }

    public func update(withPolicy policy: UpdatePolicy) -> Promise<Bool> {
        var dataSource: PodcastDataSource
        switch policy {
        case .remote:
            dataSource = self.remoteDataSource
        case .config:
            dataSource = self.configDataSource
        }

        return Promise<Bool> { fulfill, reject in
            self.isUpToDate(with: dataSource).then { isUpToDate in
                if !isUpToDate {
                    self.localDataSource.update(fromSource: dataSource).then { updateStatus in
                        fulfill(updateStatus)
                    }
                }
                else {
                    fulfill(false)
                }
            }
        }
    }

    private func isUpToDate(with dataSource: PodcastDataSource) -> Promise<Bool> {
        return Promise<Bool> { fulfill, reject in
            let savedDataSourceUpdatedDate = self.localDataSource.get(lastUpdatedDatasourceDate: dataSource)
            dataSource.lastUpdated.then { dataSourceUpdatedDate in
                    fulfill(savedDataSourceUpdatedDate >= dataSourceUpdatedDate)
            }
        }
    }
}
