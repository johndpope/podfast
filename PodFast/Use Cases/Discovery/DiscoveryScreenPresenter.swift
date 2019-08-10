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

    private var enqueuedEpisodes = [PodcastCategory: URL]()
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

    func categoriesVisibilityChanged(added: Set<Int>, removed: Set<Int>) {
        let visibleCategoriesAdded = added.map { categories[$0] }
        let visibleCategoriesRemoved = removed.map { categories[$0] }

        for category in visibleCategoriesAdded {
            discoveryInteractor.getEpisodeOfPodcast(inCategory: category).then { episode in
                self.enqueuedEpisodes[category] = URL(string: episode.url!)!
                self.audioPlayer.enqueueItem(url: URL(string: episode.url!)!)
            }
        }

        for category in visibleCategoriesRemoved {
            self.audioPlayer.dequeueItem(url: self.enqueuedEpisodes.removeValue(forKey: category)!)
        }
    }

    func didSelectCategory(atRow row: Int) {
        let category = categories[row]

        if let enqueuedEpisode = self.enqueuedEpisodes[category]{
            self.audioPlayer.play(fromURL: enqueuedEpisode)
        }
    }
}

extension DiscoveryScreenPresenter: AudioPlayerDelegate {
    func playBackStarted() {
        discoveryViewDelegate?.playBackStarted()
    }
}
