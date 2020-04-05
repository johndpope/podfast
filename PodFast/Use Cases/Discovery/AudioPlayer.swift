//
//  AudioPlayer.swift
//  PodFast
//
//  Created by Orestis on 31/07/2019.
//  Copyright © 2019 Orestis Papadopoulos. All rights reserved.
//

import AVFoundation

protocol AudioPlayerDelegate {
    func playBackStarted(forURL: URL)
}

class AudioPlayer: NSObject, AudioPlayerInterface  {

    var delegate: AudioPlayerDelegate?
    var enqueuedAudioPlayers = [URL: AVPlayer]()
    var currentlyPlayingAudioPlayer: AVPlayer?
    lazy var staticPlayer: AVAudioPlayer = {
        let staticSound = Bundle.main.path(forResource: "static_1", ofType: "wav")
        do {
            let audioPlayer = try AVAudioPlayer(contentsOf: URL(fileURLWithPath: staticSound!))
            audioPlayer.numberOfLoops = -1
            return audioPlayer
        } catch {
            print(error)
            return AVAudioPlayer()
        }
    }()

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
                let audioPlayer = enqueuedAudioPlayers[urlItem.url] {
                    if audioPlayer == currentlyPlayingAudioPlayer {
                        stopStatic()
                        audioPlayer.volume = 1.0
                        audioPlayer.play()
                        delegate?.playBackStarted(forURL: urlItem.url)
                    } else {
                        audioPlayer.preroll(atRate: 1.0) { _ in
                            print("Preroll completed?")
                        }
                    }
                }
            case .failed:
                // TODO: signal failed in order to enqueue another episode
                print("FAILED!")
                playStatic()
            case .unknown:
                playStatic()
                print("unknown :(!")
            }
        }
    }

    func play(fromURL url: URL) {
        for (_, audioPlayer) in enqueuedAudioPlayers {
            audioPlayer.volume = 0.0
        }

        if let audioPlayer = enqueuedAudioPlayers[url] {
            currentlyPlayingAudioPlayer = audioPlayer
            if audioPlayer.status == .readyToPlay {
                stopStatic()
                audioPlayer.volume = 1.0
                audioPlayer.playImmediately(atRate: 1.0)
                delegate?.playBackStarted(forURL: url)
            }
        }

        if currentlyPlayingAudioPlayer == nil {
            playStatic()
        } else if let currentlyPlayingAudioPlayer = self.currentlyPlayingAudioPlayer{
            if currentlyPlayingAudioPlayer.status != .readyToPlay {
                playStatic()
            }
        }
    }

    func playStatic() {
        staticPlayer.volume = 0.0
        staticPlayer.play()
        staticPlayer.setVolume(0.3, fadeDuration: 0.2)
    }

    func stopStatic() {
        staticPlayer.setVolume(0.0, fadeDuration: 1.0)
    }

    func stop() {

    }

    func enqueueItem(url: URL) {
        let audioPlayerItem = AVPlayerItem(url: url)
        audioPlayerItem.addObserver(self,
                                     forKeyPath: #keyPath(AVPlayerItem.status),
                                     options: [.old, .new],
                                     context: nil)
        let audioPlayer = AVPlayer(playerItem: audioPlayerItem)
        audioPlayer.automaticallyWaitsToMinimizeStalling = false
        audioPlayer.volume = 0.0
        enqueuedAudioPlayers[url] = audioPlayer
    }

    func dequeueItem(url: URL){
        if let audioPlayer = enqueuedAudioPlayers.removeValue(forKey: url){
            audioPlayer.pause()
            audioPlayer.cancelPendingPrerolls()
        }
    }
}
