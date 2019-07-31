//
//  AudioPlayer.swift
//  PodFast
//
//  Created by Orestis on 31/07/2019.
//  Copyright © 2019 Orestis Papadopoulos. All rights reserved.
//

import AVFoundation

protocol AudioPlayerDelegate {
    func playBackStarted()
}

class AudioPlayer: NSObject, AudioPlayerInterface  {
    var audioPlayer: AVPlayer?
    var audioPlayerItem: AVPlayerItem?
    var delegate: AudioPlayerDelegate?

    override init() {

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
                audioPlayer?.play()
                delegate?.playBackStarted()
            case .failed:
                print("FAILED!")
            case .unknown:
                print("unknown :(!")
            }
        }
    }

    func play(fromURL url: URL) {
        audioPlayerItem = AVPlayerItem(url: url)
        audioPlayer = AVPlayer(playerItem: audioPlayerItem)
        audioPlayerItem?.addObserver(self,
                                    forKeyPath: #keyPath(AVPlayerItem.status),
                                    options: [.old, .new],
                                    context: nil)

        audioPlayer?.automaticallyWaitsToMinimizeStalling = false
    }
    func stop() {

    }
}
