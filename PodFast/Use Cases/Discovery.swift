//
//  Discovery.swift
//  PodFast
//
//  Created by Orestis on 13/07/2019.
//  Copyright © 2019 Orestis Papadopoulos. All rights reserved.
//

import Foundation
import Promises

protocol DiscoveryInteractor {
    func getPodcasts() -> Promise<[Podcast]>
}
class Discovery: DiscoveryInteractor {
    let podcastRepository: AnyRepository<Podcast>
    var podcastsByCategory = [PodcastCategory: [Podcast]]()

    init(withRepository repository: AnyRepository<Podcast>
        = AnyRepository<Podcast>(base: PodcastRepository())) {
        podcastRepository = repository
    }

    func getPodcasts() -> Promise<[Podcast]> {
        return podcastRepository.getAll()
    }
}
