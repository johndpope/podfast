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
    weak private var discoveryViewDelegate : DiscoveryViewDelegate?

    private var podcasts = [Podcast]()

    init(withInteractor interactor: DiscoveryInteractor = Discovery()){
        discoveryInteractor = interactor
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
    }
}
