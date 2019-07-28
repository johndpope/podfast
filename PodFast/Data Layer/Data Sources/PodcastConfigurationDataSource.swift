//
//  PodcastConfigurationDataSource.swift
//  PodFast
//
//  Created by Orestis on 27/07/2019.
//  Copyright © 2019 Orestis Papadopoulos. All rights reserved.
//

import Foundation
import Promises

public struct PodcastConfigurationDataSource: PodcastDataSource {

    public var description = "config"

    public func fetchPodcasts() -> Promise<[Podcast]> {
        if let configData = try! ConfigurationDataRequest().execute(),
           let podcasts = configData.podcasts {
            return Promise<[Podcast]>(podcasts.map{$0.toPodcastObject()})
        } else {
            // TODO Handle Error Type Here
            return Promise<[Podcast]>(APIRequestError.noValueInResponse)
        }
    }

    public var lastUpdated: Promise<Date> {
        get {
            if let configData = try! ConfigurationDataRequest().execute() {
                return Promise<Date>(configData.updated ?? Date(timeIntervalSince1970: 0))
            } else {
                return Promise<Date>(APIRequestError.noValueInResponse)
            }
        }
    }
}
