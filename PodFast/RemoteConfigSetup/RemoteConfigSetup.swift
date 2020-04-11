//
//  RemoteConfigSetup.swift
//  PodFast
//
//  Created by Orestis on 11/4/20.
//  Copyright © 2020 Orestis Papadopoulos. All rights reserved.
//

import Foundation
import FirebaseRemoteConfig
import Lobster

extension ConfigKeys {
    static let podcasts = ConfigKey<[RemoteConfigPodcast]>("podcasts")
    static let podcastsLastUpdated = ConfigKey<String>("podcastsLastUpdated")
    static let hiddenCategories = ConfigKey<[String]>("hiddenCategories")
}

struct RemoteConfigHelper {
    static func setup() {
        // 1. Configure for dev mode if we need it, otherwise a 1 hour expiration duration
        #if DEBUG
            Lobster.shared.debugMode = true
            Lobster.shared.fetchExpirationDuration = 0.0
        #else
            Lobster.shared.debugMode = false
            Lobster.shared.fetchExpirationDuration = 60 * 12
        #endif

        // 2. Set our default values and keys
        loadDefaults()

        // 3. Fetch config
        Lobster.shared.fetch()
    }

    private static func loadDefaults() {
        let path = Bundle.main.path(forResource: "podcasts", ofType: "json")!
        do {
            let data = try Data(contentsOf: URL(fileURLWithPath: path), options: .mappedIfSafe)
            let podcastsConfig = try! JSONDecoder().decode(PodcastsConfig.self, from: data)
            Lobster.shared[default: .podcasts] = podcastsConfig.podcasts
            Lobster.shared[default: .podcastsLastUpdated] = podcastsConfig.lastUpdated
            Lobster.shared[default: .hiddenCategories] = podcastsConfig.hiddenCategories
        } catch {
            print(error)
        }

    }
}
