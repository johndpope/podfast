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

class ViewController: UIViewController {
    var podcastEpisode: Episode?

    @IBOutlet weak var podcastTitleLabel: UILabel!
    @IBOutlet weak var episodeTitleLabel: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()

        self.episodeTitleLabel.isHidden = true
        podcastTitleLabel.isHidden = true
        // Do any additional setup after loading the view, typically from a nib.
        if let podcast = Discovery.fetchUndiscoveredPodcast() {
            Discovery.fetchUnplayedEpisode(ofPodcast: podcast, completionBlock: { [weak self] episode in
                self?.podcastTitleLabel.isHidden = false
                self?.podcastTitleLabel.text = podcast.title ?? ""
                self?.episodeTitleLabel.setTitle(episode.title ?? "", for: UIControlState.normal)
                self?.episodeTitleLabel.isHidden = false
                self?.podcastEpisode = episode
            })
        }
    }

    @IBAction func playPodcast(_ sender: UIButton) {
        var player: AVPlayer!

        if let episodeUrlString = podcastEpisode?.url, let episodeUrl = URL(string: episodeUrlString) {
            let playerItem = AVPlayerItem(url: episodeUrl)
            player = AVPlayer(playerItem: playerItem)

            let playerLayer = AVPlayerLayer(player: player!)

            playerLayer.frame = CGRect(x: 0, y: 0, width: 10, height: 50)
            self.view.layer.addSublayer(playerLayer)
            player.play()

            let realm = DBHelper.shared.getRealm()
            realm.beginWrite()
            podcastEpisode?.hasBeenPlayed = true
            try! realm.commitWrite()
        }

    }

}

