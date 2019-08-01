//
//  PodcastRepository.swift
//  PodFast
//
//  Created by Orestis on 25/07/2019.
//  Copyright © 2019 Orestis Papadopoulos. All rights reserved.
//

import Promises

class PodcastRepository: Repository {

    private let localDataSource:  AnyLocalDataSource<Podcast>
    private let remoteDataSource: AnyDataSource<Podcast>
    private let configDataSource: AnyDataSource<Podcast>
    private let episodeDataSource: EpisodeRemoteDataSource

    public init(localDataSource: AnyLocalDataSource<Podcast> = AnyLocalDataSource<Podcast>(base: PodcastRealmDataSource()),
               remoteDataSource: AnyDataSource<Podcast> = AnyDataSource<Podcast>(base: PodcastRemoteDataSource()),
               configDataSource: AnyDataSource<Podcast> = AnyDataSource<Podcast>(base: PodcastConfigurationDataSource()),
               episodeDataSource: EpisodeRemoteDataSource = EpisodeRemoteDataSource()) {
        self.remoteDataSource = remoteDataSource
        self.localDataSource = localDataSource
        self.configDataSource = configDataSource
        self.episodeDataSource = episodeDataSource
    }

    public func getAll() -> Promise<[Podcast]> {
        return localDataSource.fetchAll()
    }

    public func update(withPolicy policy: RepositoryUpdatePolicy) -> Promise<Bool> {
        var dataSource: AnyDataSource<Podcast>
        // TODO: Good candidate for factory
        switch policy {
        case .remote:
            dataSource = self.remoteDataSource
        case .config:
            dataSource = self.configDataSource
        }

        return Promise<Bool> { fulfill, reject in
            self.localDataSource.update(fromSource: dataSource).then { updateStatus in
                fulfill(updateStatus)
            }
        }
    }
    
}
