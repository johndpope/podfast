//
//  Launch.swift
//  PodFast
//
//  Created by Orestis on 30/07/2019.
//  Copyright © 2019 Orestis Papadopoulos. All rights reserved.
//

import Promises

protocol LaunchInteractor {
    func updatePodcasts() -> Promise<Bool>
}

class Launch: LaunchInteractor {
    let podcastRepository: AnyRepository<Podcast>

    init(withRepository repository: AnyRepository<Podcast>
                                  = AnyRepository<Podcast>(base: PodcastRepository())) {
        podcastRepository = repository
    }

    func updatePodcasts() -> Promise<Bool> {
        return Promise<Bool> {fulfill, reject in
            self.podcastRepository.update(withPolicy: .config).then { _ in
                self.podcastRepository.update(withPolicy: .remote).then { didUpdate in
                    fulfill(didUpdate)
                }
            }
        }
    }
}
