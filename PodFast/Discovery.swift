//
//  Discovery.swift
//  PodFast
//
//  Created by Orestis on 13/07/2019.
//  Copyright © 2019 Orestis Papadopoulos. All rights reserved.
//

import Foundation
import ReactiveSwift
import ReactiveCocoa
import enum Result.NoError

//class Discovery {
////    static func fetchUndiscoveredPodcast() -> Podcast? {
////        let podcasts = DBHelper.shared.getRealm().objects(Podcast.self).filter(" hasBeenDiscovered == false ")
////        // what happens if all are discovered?
////        return podcasts.randomElement()
////    }
//    // doesn't really need to be a signal
//    let undiscoveredPodcasts = SignalProducer<Podcast?, NoError> { () -> Podcast? in
//        let podcasts = DBHelper.shared.getRealm().objects(Podcast.self).filter(" hasBeenDiscovered == false ")
//        // what happens if all are discovered?
//        return podcasts.randomElement()
//    }
//
//    static func fetchUnplayedEpisode(ofPodcast podcast: Podcast, completionBlock: @escaping (Episode) -> Void){
////        if podcast.episodes.count > 0 {
////            if let episode = podcast.episodes.first(where: { !$0.hasBeenPlayed }) {
////                completionBlock(episode)
////            } else {
////                podcast.deleteAllEpisodes() // this logic needs improvement, need to search deeper
////                // should be made async :/
////                podcast.getEpisodes(count: 5, completionBlock: { episodes in
////                    if let randomEpisode = podcast.episodes.randomElement() {
////                        completionBlock(randomEpisode)
////                    }
////                })
////            }
////        } else {
////            podcast.getEpisodes(count: 5, completionBlock: { episodes in
////                if let randomEpisode = podcast.episodes.randomElement() {
////                    completionBlock(randomEpisode)
////                }
////            })
////        }
//    }
//}
