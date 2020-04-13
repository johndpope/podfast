//
//  PodcastConfigurationDataSource.swift
//  PodFast
//
//  Created by Orestis on 27/07/2019.
//  Copyright © 2019 Orestis Papadopoulos. All rights reserved.
//

import Foundation
import Promises
import Lobster

public struct PodcastConfigurationDataSource: DataSource {

    public typealias DataType = Podcast

    public var description = "config"

    public func fetchAll() -> Promise<[Podcast]> {
        return Promise<[Podcast]> {fulfil, reject in
            fulfil(Lobster.shared[.podcasts].map{$0.toPodcastObject()})
        }
    }
    
    public func lastUpdated() -> Promise<Date> {
        return Promise<Date> { fulfil, reject in
            let timeSince1970 = Double(Lobster.shared[config:.podcastsLastUpdated]) ?? 0
            fulfil(Date(timeIntervalSince1970: timeSince1970))
        }
    }
}
