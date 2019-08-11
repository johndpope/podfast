//
//  PodcastCategoryRepository.swift
//  PodFast
//
//  Created by Orestis on 28/07/2019.
//  Copyright © 2019 Orestis Papadopoulos. All rights reserved.
//

import Promises


class PodcastCategoryRepositoryImplementation: PodcastCategoryRepository {

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

    func getAll<T>(sortedBy keyPath: KeyPath<PodcastCategory, T>) -> Promise<[PodcastCategory]> where T : Comparable {
        return Promise<[PodcastCategory]> {fulfill, reject in
            self.dataSource.fetchAll().then { podcastCategories in
                fulfill(podcastCategories.sorted(by: keyPath))
            }
        }
    }
}

extension Sequence {
    func sorted<T: Comparable>(by keyPath: KeyPath<Element, T>) -> [Element] {
        return sorted { a, b in
            return a[keyPath: keyPath] > b[keyPath: keyPath]
        }
    }
}

