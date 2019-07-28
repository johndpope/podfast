//
//  Radio.swift
//  PodFast
//
//  Created by Orestis on 16/07/2019.
//  Copyright © 2019 Orestis Papadopoulos. All rights reserved.
//

import Foundation
import AVFoundation

@objc(Station)
class Station: NSObject {
    var audioPlayer: AVPlayer
    var audioPlayerItem: AVPlayerItem
    var podcast: Podcast
    var episode: Episode
    var frequency: Int

    init(_ podcast: Podcast, _ episode: Episode, _ frequency: Int) {
        self.podcast = podcast
        self.episode = episode
        self.frequency = frequency

//        audioPlayerItem = CachingPlayerItem(url: URL(string: episode.url!)!)
        audioPlayerItem = AVPlayerItem(url: URL(string: episode.url!)!)
        audioPlayer = AVPlayer(playerItem: audioPlayerItem)
        super.init()
        audioPlayerItem.addObserver(self,
                                    forKeyPath: #keyPath(AVPlayerItem.status),
                                    options: [.old, .new],
                                    context: nil)

        audioPlayer.automaticallyWaitsToMinimizeStalling = false
        audioPlayer.volume = 0

//        audioPlayerItem.delegate = self
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
                audioPlayer.play()
                print("\(self.podcast.title!) is now playing!")
            case .failed:
                print("FAILED!")
            case .unknown:
                print("unknown :(!")
            }
        }
    }
}
//
//extension Station: CachingPlayerItemDelegate {
////    /// Is called after initial prebuffering is finished, means
////    /// we are ready to play.
////    @objc func playerItemReadyToPlay(_ playerItem: CachingPlayerItem) {
////        audioPlayer.play()
////    }
//}

class Radio {

    var stations = [Station]()
    var frequencies = [Int:Station] ()
    let frequencyRange = 1...100
    let frequencySpacing = 25

    init() {
        loadStations()
    }

    func loadStations() {
        let podcasts = DBHelper.shared.getRealm().objects(Podcast.self).filter(" hasBeenDiscovered == false ").shuffled()
        let startFrequency = Int.random(in: frequencyRange)
        var stationFrequency = startFrequency
        for podcast in podcasts.prefix(4) {
            if let episode = podcast._episodes.shuffled().first(where: { !$0.hasBeenPlayed }) {
                self.stations.append(Station(podcast, episode, stationFrequency))
                print("RADIO: Added station \(podcast.title!) to frequency \(stationFrequency)")
            }
            stationFrequency = (stationFrequency + frequencySpacing) % frequencyRange.upperBound
        }
    }

    func tune(toFrequency f: Int){
        for station in stations {
            let distance: Float = Float(abs(f - station.frequency))
            if distance > 10 {
                station.audioPlayer.volume = 0
            } else {
                station.audioPlayer.volume = 1.0 - distance * 10.0/Float(frequencyRange.upperBound)
            }
        }
    }
}
