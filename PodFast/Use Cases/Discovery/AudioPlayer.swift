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
    func updateTimeElapsed(_ timeElapsed: String)
}

class AudioPlayer: NSObject, AudioPlayerInterface  {

    var delegate: AudioPlayerDelegate?
    var enqueuedAudioPlayers = [URL: AVPlayer]()
    var currentlyPlayingAudioPlayer: AVPlayer? {
        willSet {
            removePeriodicTimeObserver()
        }
    }
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
                    circularSeek(audioPlayer: audioPlayer, toTimeInterval: Date().timeIntervalSince(appLaunchTime!))
                    if audioPlayer == currentlyPlayingAudioPlayer {
                        startPlayback(ofPlayer: audioPlayer)
                    } else {
                        audioPlayer.preroll(atRate: 0.5) { _ in
                            audioPlayer.play()
                        }
                    }
                }
            case .failed:
                // TODO: signal failed in order to enqueue another episode
                playStatic()
            case .unknown:
                playStatic()
            }
        }

        if keyPath == #keyPath(AVPlayerItem.isPlaybackBufferEmpty),
            let item = object as? AVPlayerItem {

            if let oldBool = change?[.oldKey] as? Bool,
                oldBool == false,
                let newBool = change?[.newKey] as? Bool,
                newBool == true,
                let urlItem = item.asset as? AVURLAsset,
                let audioPlayer = enqueuedAudioPlayers[urlItem.url] {
                // Resume Playback from stall
                stopStatic()
                audioPlayer.play()
            } else if let newBool = change?[.newKey] as? Bool,
                newBool == true,
                let urlItem = item.asset as? AVURLAsset,
                let audioPlayer = enqueuedAudioPlayers[urlItem.url],
                audioPlayer == currentlyPlayingAudioPlayer {
                // Play static when buffers are empty
                playStatic()
            }
        }
    }

    private func circularSeek(audioPlayer player: AVPlayer, toTimeInterval interval: TimeInterval) {
        if let duration = player.currentItem?.duration {
            let durationInSeconds = cmTimeToSeconds(duration) ?? 0
            let seekTo = interval.truncatingRemainder(dividingBy: durationInSeconds)

            let seekTime = CMTime(seconds: seekTo, preferredTimescale: 1000000)
            player.seek(to: seekTime)
        }
    }

    private func startPlayback(ofPlayer audioPlayer: AVPlayer) {
        stopStatic()
        audioPlayer.volume = 1.0
        audioPlayer.playImmediately(atRate: 1.0)

        if let urlItem = audioPlayer.currentItem?.asset as? AVURLAsset {
            delegate?.playBackStarted(forURL: urlItem.url)
            addPeriodicTimeObserver()
        }
    }

    // MARK: Time Observers
    var timeObserverToken: Any?
    private func addPeriodicTimeObserver() {
        // Notify every half second
        let timeScale = CMTimeScale(NSEC_PER_SEC)
        let time = CMTime(seconds: 0.5, preferredTimescale: timeScale)

        guard let player = currentlyPlayingAudioPlayer else {
            return
        }

        timeObserverToken = player.addPeriodicTimeObserver(forInterval: time, queue: .main) { [weak self] time in
            let seconds = self?.cmTimeToSeconds(time) ?? TimeInterval(0.0)
            let timeElapsedString = self?.string(fromInterval: seconds)
            self?.delegate?.updateTimeElapsed(timeElapsedString ?? "00:00:00")
        }
    }

    private func removePeriodicTimeObserver() {
        guard let player = currentlyPlayingAudioPlayer else {
            return
        }

        if let timeObserverToken = timeObserverToken {
            player.removeTimeObserver(timeObserverToken)
            self.timeObserverToken = nil
        }
    }

    private func cmTimeToSeconds(_ time: CMTime) -> TimeInterval? {
        let seconds = CMTimeGetSeconds(time)
        if seconds.isNaN {
            return nil
        }
        return TimeInterval(seconds)
    }

    func string(fromInterval interval: TimeInterval) -> String {

        let time = NSInteger(interval)

        let seconds = time % 60
        let minutes = (time / 60) % 60
        let hours = (time / 3600)

        return String(format: "%0.2d:%0.2d:%0.2d",hours,minutes,seconds)
    }

    func play(fromURL url: URL) {
        for (_, audioPlayer) in enqueuedAudioPlayers {
            audioPlayer.volume = 0.0
        }

        if let audioPlayer = enqueuedAudioPlayers[url] {
            currentlyPlayingAudioPlayer = audioPlayer
            // if the audio player is immediately ready to play
            // otherwise it will be called when it's ready to play in the observe value callback
            if audioPlayer.status == .readyToPlay {
                startPlayback(ofPlayer: audioPlayer)
            } else {
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

        audioPlayerItem.addObserver(self,
                                    forKeyPath: #keyPath(AVPlayerItem.isPlaybackBufferEmpty),
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
