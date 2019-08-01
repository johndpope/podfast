//
//  DiscoveryScreenViewController.swift
//  PodFast
//
//  Created by Orestis on 30/07/2019.
//  Copyright © 2019 Orestis Papadopoulos. All rights reserved.
//

import Foundation

class DiscoveryScreenPresenter {

    private let discoveryInteractor: DiscoveryInteractor
    private var audioPlayer: AudioPlayerInterface
    weak private var discoveryViewDelegate : DiscoveryViewDelegate?

    private var podcasts = [Podcast]()
    private var categories = [PodcastCategory]()

    init(withInteractor interactor: DiscoveryInteractor = Discovery(),
        withAudioPlayerInterface audioPlayer: AudioPlayerInterface = AudioPlayer()){
        discoveryInteractor = interactor
        self.audioPlayer = audioPlayer
        self.audioPlayer.delegate = self
    }

    func viewDidLoad() {
        discoveryInteractor.getPodcastCategories().then {categories in
            self.categories = categories
            self.discoveryViewDelegate?.reloadData()
        }
    }

    func getCategoriesCount() -> Int {
        return categories.count
    }

    func getCategoryName(forRow row: Int) -> String? {
        return categories[row].name
    }

    func setViewDelegate(discoveryViewDelegate: DiscoveryViewDelegate?){
        self.discoveryViewDelegate = discoveryViewDelegate
    }

    func didSelectCategory(atRow row: Int) {
        print("\(String(describing: categories[row].name)) was selected!")
        discoveryInteractor.getEpisodeOfPodcast(inCategory: categories[row]).then { episode in
            self.audioPlayer.play(fromURL: URL(string: episode.url!)!)
            print("Playing \(String(describing: episode.title)) of Podcast: \(episode.podcast.first!.title!)")
        }
//        // TODO: This must become, get episode and the selection logic should go to the discover ;)
//        discoveryInteractor.getEpisodes(forPodcast: podcasts[row]).then { episodes in
//            if let episode = episodes.first, let episodeURL = URL(string: episode.url ?? "") {
//                self.audioPlayer.play(fromURL: episodeURL)
//            }
//        }

    }
}

extension DiscoveryScreenPresenter: AudioPlayerDelegate {
    func playBackStarted() {
        discoveryViewDelegate?.playBackStarted()
    }
}
