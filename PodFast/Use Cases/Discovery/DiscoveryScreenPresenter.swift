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
    private let audioPlayer: AudioPlayerInterface
    weak private var discoveryViewDelegate : DiscoveryViewDelegate?

    private var podcasts = [Podcast]()

    init(withInteractor interactor: DiscoveryInteractor = Discovery(),
        withAudioPlayerInterface audioPlayer: AudioPlayerInterface = AudioPlayer()){
        discoveryInteractor = interactor
        self.audioPlayer = audioPlayer
    }

    func viewDidLoad() {
        discoveryInteractor.getPodcasts().then {podcasts in
            self.podcasts = podcasts
            self.discoveryViewDelegate?.reloadData()
        }
    }

    func getPodcastCount() -> Int {
        return podcasts.count
    }

    func getPodcast(forRow row: Int) -> Podcast{
        return podcasts[row]
    }

    func setViewDelegate(discoveryViewDelegate: DiscoveryViewDelegate?){
        self.discoveryViewDelegate = discoveryViewDelegate
    }

    func selectedPodcast(atRow row: Int) {
        print("\(String(describing: podcasts[row].title)) was selected!")
        // TODO: This must become, get episode and the selection logic should go to the discover ;)
        discoveryInteractor.getEpisodes(forPodcast: podcasts[row]).then { episodes in
            if let episode = episodes.first, let episodeURL = URL(string: episode.url ?? "") {
                self.audioPlayer.play(fromURL: episodeURL)
            }
        }
    }
}
