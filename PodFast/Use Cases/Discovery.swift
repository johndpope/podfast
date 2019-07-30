//
//  Discovery.swift
//  PodFast
//
//  Created by Orestis on 13/07/2019.
//  Copyright © 2019 Orestis Papadopoulos. All rights reserved.
//

import Foundation
import Promises
import RealmSwift

protocol DiscoveryInteractor {
    func getPodcasts() -> Promise<[Podcast]>
}
class Discovery: DiscoveryInteractor {
    let podcastCategoryRepository: AnyRepository<PodcastCategory>

    init(withRepository repository: AnyRepository<PodcastCategory>
        = AnyRepository<PodcastCategory>(base: PodcastCategoryRepository())) {
        podcastCategoryRepository = repository
    }

    func getPodcasts() -> Promise<[Podcast]> {
        return Promise<[Podcast]> { fulfill, reject in
            self.podcastCategoryRepository.getAll().then { podcastCategories in

                var podcasts = [Podcast]()
                for podcastCategory in podcastCategories {

                    var categoryList = List<PodcastCategory>()
                    categoryList.append(podcastCategory)
                    if let podcast = podcastCategory.podcasts.randomElement(){
                        podcasts.append(Podcast(value: ["title" : podcast.title, "categories" : categoryList]))
                    }
                }

                fulfill(podcasts.shuffled())
            }
        }
    }
}
