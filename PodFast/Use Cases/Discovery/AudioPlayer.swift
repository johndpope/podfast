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

    var delegate: AudioPlayerDelegate?
    var audioPlayers = [URL: AVPlayer]()
    var currentlyPlayingAudioPlayer: AVPlayer?

    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == #keyPath(AVPlayerItem.status),
        let item = object as? AVPlayerItem {
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
                // find the audio player
                if let urlItem = item.asset as? AVURLAsset,
                let audioPlayer = audioPlayers[urlItem.url] {
                    if audioPlayer == currentlyPlayingAudioPlayer {
                        audioPlayer.volume = 1.0
                        audioPlayer.play()
                        print("An Episode will play url: \(urlItem.url)")
                    } else {
                        audioPlayer.preroll(atRate: 1.0) { _ in
                            print("Preroll completed?")
                        }
                    }
                }
            case .failed:
                // TODO: signal failed in order to enqueue another episode
                print("FAILED!")
            case .unknown:
                print("unknown :(!")
            }
        }
    }

    func play(fromURL url: URL) {
        for (_, audioPlayer) in audioPlayers {
            audioPlayer.volume = 0.0
        }

        if let audioPlayer = audioPlayers[url] {
            currentlyPlayingAudioPlayer = audioPlayer
            if audioPlayer.status == .readyToPlay {
                audioPlayer.volume = 1.0
                audioPlayer.playImmediately(atRate: 1.0)
            }
        }
    }

    func stop() {

    }

    func enqueueItem(url: URL){
        let audioPlayerItem = AVPlayerItem(url: url)
        audioPlayerItem.addObserver(self,
                                     forKeyPath: #keyPath(AVPlayerItem.status),
                                     options: [.old, .new],
                                     context: nil)
        let audioPlayer = AVPlayer(playerItem: audioPlayerItem)
        audioPlayer.automaticallyWaitsToMinimizeStalling = false
        audioPlayer.volume = 0.0
        audioPlayers[url] = audioPlayer
    }

    func dequeueItem(url: URL){
        if let audioPlayer = audioPlayers.removeValue(forKey: url){
            audioPlayer.pause()
            // does it deinit?
        }
    }
}
