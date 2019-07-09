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
    var podcastURL: String?
    var notificationToken: NotificationToken? = nil

    override func viewDidLoad() {
        super.viewDidLoad()
//        podcastURL =
        let realm = try! Realm()
        let results = realm.objects(Podcast.self)
        // Observe Results Notifications
        notificationToken = results.observe { [weak self] (changes: RealmCollectionChange) in
            switch changes {
            case .initial:
                print("initial")
            case .update(_, _, _, _):
                print("update")
                self?.podcastURL = results.first?.url
            case .error(let error):
                // An error occurred while opening the Realm file on the background worker thread
                fatalError("\(error)")
            }
        }
        // Do any additional setup after loading the view, typically from a nib.
    }

    deinit {
        notificationToken?.invalidate()
    }

    @IBAction func playPodcast(_ sender: UIButton) {
        var player: AVPlayer!

        let playerItem: AVPlayerItem = AVPlayerItem(url: URL(string: podcastURL!)!)
        player = AVPlayer(playerItem: playerItem)

        let playerLayer = AVPlayerLayer(player: player!)

        playerLayer.frame = CGRect(x: 0, y: 0, width: 10, height: 50)
        self.view.layer.addSublayer(playerLayer)
        player.play()
    }

}

