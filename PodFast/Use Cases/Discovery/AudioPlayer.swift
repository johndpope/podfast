//
//  AudioPlayer.swift
//  PodFast
//
//  Created by Orestis on 31/07/2019.
//  Copyright © 2019 Orestis Papadopoulos. All rights reserved.
//

import AVFoundation
import MediaPlayer

protocol AudioPlayerDelegate {
    func playBackStarted(forURL: URL)
    func updateTimeElapsed(_ timeElapsed: String)
    func playerDidFinishPlaying(_ url: URL)
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

    override init() {
        super.init()
        setupRemoteTransportControls()
    }

    func setupRemoteTransportControls() {
        MPNowPlayingInfoCenter.default().nowPlayingInfo = [MPMediaItemPropertyTitle: "Podfast"]

        // Get the shared MPRemoteCommandCenter
        let commandCenter = MPRemoteCommandCenter.shared()

        // Add handler for Play Command
        commandCenter.playCommand.addTarget { [unowned self] event in
            guard let player = self.currentlyPlayingAudioPlayer else {
                return .commandFailed
            }

            if player.rate == 0.0 {
                player.play()
                return .success
            }
            return .commandFailed
        }

        // Add handler for Pause Command
        commandCenter.pauseCommand.addTarget { [unowned self] event in
            guard let player = self.currentlyPlayingAudioPlayer else {
                return .commandFailed
            }

            if player.rate == 1.0 {
                player.pause()
                return .success
            }
            return .commandFailed
        }
    }

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
                    circularSeek(audioPlayer: audioPlayer, toTimeInterval: Date().timeIntervalSince(appLaunchTime!), then: { _ in
                        if audioPlayer == self.currentlyPlayingAudioPlayer {
                            self.startPlayback(ofPlayer: audioPlayer)
                        } else {
                            audioPlayer.preroll(atRate: 0.5) { _ in
                                audioPlayer.play()
                            }
                        }
                    })
                }
            case .failed:
                // TODO: signal failed in order to enqueue another episode
                // find the audio player
                if let urlItem = item.asset as? AVURLAsset {
                    delegate?.playerDidFinishPlaying(urlItem.url)
                }
            case .unknown:
                playStatic()
            }
        }

        if keyPath == #keyPath(AVPlayerItem.isPlaybackBufferEmpty),
            let item = object as? AVPlayerItem,
            currentlyPlayingAudioPlayer != nil,
            let isBufferEmpty = change?[.newKey] as? Bool,
            let wasBufferEmpty = change?[.oldKey] as? Bool,
            isBufferEmpty != wasBufferEmpty,
            let urlItem = item.asset as? AVURLAsset,
            let audioPlayer = enqueuedAudioPlayers[urlItem.url] {
            isBufferEmptyDidChange(forAudioPlayer: audioPlayer)
        }

        if keyPath == #keyPath(AVPlayerItem.isPlaybackBufferFull),
            let item = object as? AVPlayerItem,
            currentlyPlayingAudioPlayer != nil,
            let isPlaybackBufferFull = change?[.newKey] as? Bool,
            let wasPlaybackBufferFull = change?[.oldKey] as? Bool,
            isPlaybackBufferFull != wasPlaybackBufferFull,
            let urlItem = item.asset as? AVURLAsset,
            let audioPlayer = enqueuedAudioPlayers[urlItem.url] {
            isBufferFullDidChange(forAudioPlayer: audioPlayer)
        }

        if keyPath == #keyPath(AVPlayerItem.isPlaybackLikelyToKeepUp),
            let item = object as? AVPlayerItem,
            currentlyPlayingAudioPlayer != nil,
            let isPlaybackLikelyToKeepUp = change?[.newKey] as? Bool,
            let wasPlaybackLikelyToKeepUp = change?[.oldKey] as? Bool,
            isPlaybackLikelyToKeepUp != wasPlaybackLikelyToKeepUp,
            let urlItem = item.asset as? AVURLAsset,
            let audioPlayer = enqueuedAudioPlayers[urlItem.url] {
            isPlaybackLikelyToKeepUpDidChange(forAudioPlayer: audioPlayer)
        }
    }

    private func isBufferEmptyDidChange(forAudioPlayer player: AVPlayer) {
        if let item = player.currentItem,
            isCurrentlyPlayingAudioPlayer(player: player) {
            if item.isPlaybackBufferEmpty {
                if !item.isPlaybackLikelyToKeepUp {
                    playStatic()
                }

                let enqueuedBackgroundPlayers = enqueuedAudioPlayers.filter{ !isCurrentlyPlayingAudioPlayer(player: $0.value) }
                enqueuedBackgroundPlayers.forEach {
                    $0.value.pause()
                }
            }
        }
    }

    private func isBufferFullDidChange(forAudioPlayer player: AVPlayer) {
        if let item = player.currentItem,
            isCurrentlyPlayingAudioPlayer(player: player),
            item.isPlaybackBufferFull {
                stopStatic()
                enqueuedAudioPlayers.forEach {
                    $0.value.play()
                }
        }
    }

    private func isPlaybackLikelyToKeepUpDidChange(forAudioPlayer player: AVPlayer) {
        if let item = player.currentItem,
            isCurrentlyPlayingAudioPlayer(player: player),
            item.isPlaybackLikelyToKeepUp {
                stopStatic()
                enqueuedAudioPlayers.forEach {
                    $0.value.play()
                }
        }
    }

    private func circularSeek(audioPlayer player: AVPlayer, toTimeInterval interval: TimeInterval, then: @escaping (Bool) -> Void) {
        if let duration = player.currentItem?.duration {
            let durationInSeconds = cmTimeToSeconds(duration) ?? 0
            let seekTo = interval.truncatingRemainder(dividingBy: durationInSeconds)

            let seekTime = CMTime(seconds: seekTo, preferredTimescale: 1000000)
            player.seek(to: seekTime) { succeeded in
                then(succeeded)
            }
        }
    }

    private func startPlayback(ofPlayer audioPlayer: AVPlayer) {
        audioPlayer.volume = 1.0
        audioPlayer.playImmediately(atRate: 1.0)

        if let urlItem = audioPlayer.currentItem?.asset as? AVURLAsset,
            audioPlayer.isPlaying {
            stopStatic()
            delegate?.playBackStarted(forURL: urlItem.url)
            addPeriodicTimeObserver()
        }
    }

    // MARK: Time Observers
    var timeObserverToken: Any?
    private func addPeriodicTimeObserver() {
        let timeScale = CMTimeScale(NSEC_PER_SEC)
        let time = CMTime(seconds: 1.0, preferredTimescale: timeScale)

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
            if audioPlayer.status == .readyToPlay, let item = audioPlayer.currentItem, item.status == .readyToPlay {
                startPlayback(ofPlayer: audioPlayer)
            } else {
                playStatic()
            }
        }
    }

    func playStatic() {
        staticPlayer.volume = 0.0
        staticPlayer.play()
        staticPlayer.setVolume(0.2, fadeDuration: 0.2)
    }

    func stopStatic() {
        staticPlayer.setVolume(0.0, fadeDuration: 1.0)
    }

    func resume() {
        guard let player = self.currentlyPlayingAudioPlayer else {
            return
        }

        if player.rate == 0.0 {
            player.play()
        }
    }

    func stop() {

    }

    @objc func playerDidFinishPlaying(note: NSNotification) {
        for (url, player) in enqueuedAudioPlayers {
            if !player.isPlaying {
                delegate?.playerDidFinishPlaying(url)
            }
        }
    }

    func enqueueItem(url: URL, replacingURL oldURL: URL? = nil) {
        let audioPlayerItem = AVPlayerItem(url: url)

        audioPlayerItem.addObserver(self,
                                     forKeyPath: #keyPath(AVPlayerItem.status),
                                     options: [.old, .new],
                                     context: nil)

        audioPlayerItem.addObserver(self,
                                    forKeyPath: #keyPath(AVPlayerItem.isPlaybackBufferEmpty),
                                    options: [.old, .new],
                                    context: nil)

        audioPlayerItem.addObserver(self,
                                    forKeyPath: #keyPath(AVPlayerItem.isPlaybackBufferFull),
                                    options: [.old, .new],
                                    context: nil)

        audioPlayerItem.addObserver(self,
                                    forKeyPath: #keyPath(AVPlayerItem.isPlaybackLikelyToKeepUp),
                                    options: [.old, .new],
                                    context: nil)

        NotificationCenter.default.addObserver(self, selector: #selector(playerDidFinishPlaying(note:)),
        name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: audioPlayerItem)


        let audioPlayer = AVPlayer(playerItem: audioPlayerItem)

        audioPlayer.automaticallyWaitsToMinimizeStalling = false
        audioPlayer.volume = 0.0

        if let oldURL = oldURL {
            if let oldAudioPlayer = enqueuedAudioPlayers.removeValue(forKey: oldURL),
                currentlyPlayingAudioPlayer == oldAudioPlayer {
                playStatic()
                currentlyPlayingAudioPlayer = audioPlayer
            }
        }

        enqueuedAudioPlayers[url] = audioPlayer
    }

    func dequeueItem(url: URL){
        if let audioPlayer = enqueuedAudioPlayers.removeValue(forKey: url){
            audioPlayer.currentItem?.removeObserver(self,
                                                    forKeyPath: #keyPath(AVPlayerItem.status))
            audioPlayer.currentItem?.removeObserver(self,
                                                    forKeyPath: #keyPath(AVPlayerItem.isPlaybackBufferEmpty))
            audioPlayer.currentItem?.removeObserver(self,
                                                    forKeyPath: #keyPath(AVPlayerItem.isPlaybackLikelyToKeepUp))
            audioPlayer.currentItem?.removeObserver(self,
                                                    forKeyPath: #keyPath(AVPlayerItem.isPlaybackBufferFull))
            audioPlayer.pause()
            audioPlayer.cancelPendingPrerolls()
        }
    }

    func stopPreroll() {
        for player in enqueuedAudioPlayers.values where player != currentlyPlayingAudioPlayer {
            player.cancelPendingPrerolls()
            player.pause()
        }
    }

    func resumePreroll() {
        for player in enqueuedAudioPlayers.values where player != currentlyPlayingAudioPlayer {
            player.play()
        }
    }

    func isCurrentlyPlayingAudioPlayer(player: AVPlayer) -> Bool {
        guard let currentItem = currentlyPlayingAudioPlayer?.currentItem,
            let currentAsset = currentItem.asset as? AVURLAsset,
            let playerItem = player.currentItem,
            let playerAsset = playerItem.asset as? AVURLAsset else {
            return false
        }

        return player.volume > 0.0 && currentAsset.url.absoluteString == playerAsset.url.absoluteString
    }
}

fileprivate extension AVPlayer {
    var isPlaying: Bool {
        return rate != 0 && error == nil
    }
}
