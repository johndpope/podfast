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

    typealias CategoryName = String
    private let hiddenCategoriesDataSource: AnyDataSource<CategoryName>

    public init(dataSource: AnyDataSource<PodcastCategory> = AnyDataSource<PodcastCategory>(base: PodcastCategoryRealmDataSource()),
                hiddenCategoriesDataSource: AnyDataSource<CategoryName> =
        AnyDataSource<CategoryName>(base: HiddenCategoriesDataSource())) {
        self.dataSource = dataSource
        self.hiddenCategoriesDataSource = hiddenCategoriesDataSource
    }

    public func getAll() -> Promise<[PodcastCategory]> {
        return dataSource.fetchAll().then{self.filterOut(hiddenCategories: $0)}
    }

    private func filterOut(hiddenCategories categories: [PodcastCategory]) -> Promise<[PodcastCategory]> {
        return self.hiddenCategoriesDataSource.fetchAll().then { hiddenCategoryNames in
            if hiddenCategoryNames.count > 0 {
                return Promise(categories.filter { category in
                    if let categoryName = category.name {
                        return !hiddenCategoryNames.contains(categoryName.lowercased())
                    }
                    return false
                })
            } else {
                return Promise(categories)
            }
        }
    }

    public func update(withPolicy policy: RepositoryUpdatePolicy) -> Promise<Bool> {
        return Promise { true } // Does not do anything at the moment
    }

    func getAll<T>(sortedBy keyPath: KeyPath<PodcastCategory, T>) -> Promise<[PodcastCategory]> where T : Comparable {
        return getAll().then { $0.sorted(by: keyPath) }
    }
}

extension Sequence {
    func sorted<T: Comparable>(by keyPath: KeyPath<Element, T>) -> [Element] {
        return sorted { a, b in
            return a[keyPath: keyPath] > b[keyPath: keyPath]
        }
    }
}

