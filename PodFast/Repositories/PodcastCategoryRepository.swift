//
//  PodcastCategoryRepository.swift
//  PodFast
//
//  Created by Orestis on 28/07/2019.
//  Copyright © 2019 Orestis Papadopoulos. All rights reserved.
//

import Promises


class PodcastCategoryRepository: Repository {

    private let dataSource: AnyDataSource<PodcastCategory>

    public init(dataSource: AnyDataSource<PodcastCategory> = AnyDataSource<PodcastCategory>(base: PodcastCategoryRealmDataSource())) {
        self.dataSource = dataSource
    }

    public func getAll() -> Promise<[PodcastCategory]> {
        return dataSource.fetchAll()
    }

    public func update(withPolicy policy: RepositoryUpdatePolicy) -> Promise<Bool> {
        return Promise { true } // Does not do anything at the moment
    }

}

