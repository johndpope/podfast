//
//  ViewController.swift
//  PodFast
//
//  Created by Orestis on 09/07/2019.
//  Copyright © 2019 Orestis Papadopoulos. All rights reserved.
//

import UIKit
import AVFoundation
import AVKit
import RealmSwift
import ReactiveSwift
import ReactiveCocoa

class ViewController: UIViewController {
    var podcastEpisode: Episode?
    var podcast: Podcast?

    var audioPlayer: AVPlayer?
    var audioPlayerItem: CachingPlayerItem?

    @IBOutlet weak var podcastTitleLabel: UILabel!
    @IBOutlet weak var episodeTitleLabel: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()

        self.episodeTitleLabel.isHidden = true
        podcastTitleLabel.isHidden = true

        let discovery = Discovery()
        discovery.undiscoveredPodcasts
                 .skipNil()
                 .observe(on: UIScheduler())
                 .on(value: { podcast in
                    podcast.episodeStream
                           .filter { !$0.hasBeenPlayed }
                           .take(first: 1)
                           .observe(on: UIScheduler())
                           .on (value: { episode in
//                                self.audioPlayerItem = AVPlayerItem(url: URL(string: episode.url!)!)
                                self.audioPlayerItem = CachingPlayerItem(url: URL(string: episode.url!)!)
                                // Register as an observer of the player item's status property
                                self.audioPlayerItem?.addObserver(self,
                                                       forKeyPath: #keyPath(AVPlayerItem.status),
                                                       options: [.old, .new],
                                                       context: nil)
                                if self.audioPlayerItem != nil {
                                    self.audioPlayer = AVPlayer(playerItem: self.audioPlayerItem)
                                    self.audioPlayer?.automaticallyWaitsToMinimizeStalling = false
                                }
                                self.podcast = podcast
                                self.podcastEpisode = episode
                           })
                           .start()
        })
        .start()
    }

    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == #keyPath(AVPlayerItem.status) {
                let status: AVPlayerItemStatus

                // Get the status change from the change dictionary
                if let statusNumber = change?[.newKey] as? NSNumber {
                    status = AVPlayerItemStatus(rawValue: statusNumber.intValue)!
                } else {
                    status = .unknown
                }

                // Switch over the status
                switch status {
                case .readyToPlay:
                    self.podcastTitleLabel.isHidden = false
                    self.podcastTitleLabel.text = podcast?.title ?? ""
                    self.episodeTitleLabel.isHidden = false
                    self.episodeTitleLabel.setTitle(podcastEpisode?.title ?? "", for: UIControlState.normal)
                case .failed:
                    print("FAILED!")
                case .unknown:
                    print("unknown :(!")
                }
        }
    }

    @IBAction func playPodcast(_ sender: UIButton) {
        if let audioPlayer = self.audioPlayer {
            let realm = DBHelper.shared.getRealm()
            realm.beginWrite()
            podcastEpisode?.hasBeenPlayed = true
            try! realm.commitWrite()

            audioPlayer.play()
        }

    }

}

