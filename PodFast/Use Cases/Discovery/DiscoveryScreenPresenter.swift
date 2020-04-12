//
//  DiscoveryScreenViewController.swift
//  PodFast
//
//  Created by Orestis on 30/07/2019.
//  Copyright © 2019 Orestis Papadopoulos. All rights reserved.
//

import Foundation

enum DiscoveryError: Error {
    case NoUnplayedEpisode
    case NoPodcastsInCategory
    case NoEpisodesInPodcast(podcast: Podcast)
    case InvalidEpisodeURL
}

class DiscoveryScreenPresenter {
    private let podcastDiscoveryTimeInterval: TimeInterval = 30.0
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

        NotificationCenter.default.addObserver(self, selector: #selector(didReceiveAppWillResignActive), name: .appWillResignActive, object: nil)

        NotificationCenter.default.addObserver(self, selector: #selector(didReceiveAppWillBecomeActive), name: .appDidBecomeActive, object: nil)
    }

    @objc private func didReceiveAppWillResignActive() {
        audioPlayer.stopPreroll()
    }

    @objc private func didReceiveAppWillBecomeActive() {
        audioPlayer.resumePreroll()
        audioPlayer.resume()
    }

    func viewDidLoad() {
        discoveryInteractor.getPodcastCategories().then {categories in
            self.categories = categories
            self.discoveryViewDelegate?.reloadData()
        }
    }

    func viewDidAppear() {
        audioPlayer.playStatic()
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
            // TODO: this logic should be simplified in the presenter
            discoveryInteractor.getEpisodeOfPodcast(inCategory: category).then { episode in
                if let episodeURLString = episode.url,
                    let episodeURL = URL(string: episodeURLString) {
                    self.enqueuedEpisodes[category] = episode
                    self.audioPlayer.enqueueItem(url: episodeURL)
                }
            }.catch { error in
                if let discoveryError = error as? DiscoveryError {
                    switch discoveryError {
                    case .InvalidEpisodeURL, .NoUnplayedEpisode:
                        // try another podcast -- if this fails again, it can't be caught
                        self.enqueuePodcast(ofCategory: category)
                    case .NoPodcastsInCategory:
                        if let index = self.categories.index(of: category) {
                            self.categories.remove(at: index)
                            self.discoveryViewDelegate?.reloadData()
                        }
                    case .NoEpisodesInPodcast(let podcast):
                        self.discoveryInteractor.removePodcast(podcast: podcast)
                        // try another podcast
                        self.enqueuePodcast(ofCategory: category)
                    }
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

    // Similar to categoriesVisibilityChanged but without catch
    private func enqueuePodcast(ofCategory category: PodcastCategory) {
        self.discoveryInteractor.getEpisodeOfPodcast(inCategory: category).then { episode in
            if let episodeURLString = episode.url,
                let episodeURL = URL(string: episodeURLString) {
                self.enqueuedEpisodes[category] = episode
                self.audioPlayer.enqueueItem(url: episodeURL)
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
                    self.discoveryViewDelegate?.displayDetails(forPodcast: podcast, episode)
                    self.discoveryInteractor.advancePlayCount(ofCategory: category)
                    self.discoveryInteractor.markAsPlayed(episode: episode)
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
        podcastHasBeenListenedTimer = Timer.scheduledTimer(timeInterval: podcastDiscoveryTimeInterval, target: self, selector: #selector(podcastHasBeenListenedCallback(timer:)), userInfo: ["url": url], repeats: false)
    }

    func updateTimeElapsed(_ timeElapsed: String) {
        discoveryViewDelegate?.setTimeElapsed(timeElapsed)
    }

    func playerDidFinishPlaying(_ url: URL) {
        for (category, episode) in enqueuedEpisodes {
            if episode.url == url.absoluteString{
                discoveryInteractor.getEpisodeOfPodcast(inCategory: category).then { episode in
                    self.enqueuedEpisodes[category] = episode
                    if let episodeURLString = episode.url,
                        let episodeURL = URL(string: episodeURLString) {
                        self.audioPlayer.enqueueItem(url: episodeURL, replacingURL: url)
                    }
                }
            }
        }
    }
}
