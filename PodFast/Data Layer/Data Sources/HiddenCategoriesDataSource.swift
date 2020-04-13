//
//  HiddenCategoriesDataSource.swift
//  PodFast
//
//  Created by Orestis on 8/4/20.
//  Copyright © 2020 Orestis Papadopoulos. All rights reserved.
//

import Foundation
import Promises
import Lobster

public struct HiddenCategoriesDataSource: DataSource {

    public var description = "config"

    public func fetchAll() -> Promise<[String]> {
        return Promise {
            return Lobster.shared[.hiddenCategories]
        }
    }

    public func lastUpdated() -> Promise<Date> {
        return Promise<Date> { fulfil, reject in
            let timeSince1970 = Double(Lobster.shared[config:.podcastsLastUpdated]) ?? 0
            fulfil(Date(timeIntervalSince1970: timeSince1970))
        }
    }
}
