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

    private var enqueuedEpisodes = [PodcastCategory: Episode]()
    private var categories = [PodcastCategory]()

    private var podcastHasBeenListenedTimer: Timer?

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
                self.enqueuedEpisodes[category] = episode
                if let episodeURLString = episode.url,
                    let episodeURL = URL(string: episodeURLString) {
                    self.audioPlayer.enqueueItem(url: episodeURL)
                }
            }
        }

        for category in visibleCategoriesRemoved {
            if let episodeToRemove = self.enqueuedEpisodes.removeValue(forKey: category),
            let episodeToRemoveURLString = episodeToRemove.url,
            let episodeToRemoveURL = URL(string: episodeToRemoveURLString){
                 self.audioPlayer.dequeueItem(url: episodeToRemoveURL)
            }
        }
    }

    func didSelectCategory(atRow row: Int) {
        let category = categories[row]

        if let enqueuedEpisode = self.enqueuedEpisodes[category],
        let enqueuedEpisodeURLString = enqueuedEpisode.url,
        let enqueudEpisodeURL = URL(string: enqueuedEpisodeURLString){
            self.audioPlayer.play(fromURL: enqueudEpisodeURL)
        }
    }

    @objc func podcastHasBeenListenedCallback(timer: Timer)
    {
        if let userInfo = timer.userInfo as? [String: URL],
            let url = userInfo["url"]
        {
            for (category, episode) in enqueuedEpisodes {
                if episode.url == url.absoluteString,
                    let podcast = episode.podcast.first {
                    self.discoveryViewDelegate?.showPodcastInformation(title: podcast.title, episodeTitle: episode.title, linkToPodcast: podcast.feedUrl)
                    self.discoveryInteractor.advancePlayCount(ofCategory: category)
                }
            }
        }
    }
}

extension DiscoveryScreenPresenter: AudioPlayerDelegate {
    func playBackStarted(forURL url: URL) {
        discoveryViewDelegate?.hidePodcastInformation()
        discoveryViewDelegate?.playBackStarted()
        podcastHasBeenListenedTimer?.invalidate()
        podcastHasBeenListenedTimer = Timer.scheduledTimer(timeInterval: 60.0, target: self, selector: #selector(podcastHasBeenListenedCallback(timer:)), userInfo: ["url": url], repeats: false)
    }
}
