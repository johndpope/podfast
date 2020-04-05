//
//  AudioPlayerInterface.swift
//  PodFast
//
//  Created by Orestis on 31/07/2019.
//  Copyright © 2019 Orestis Papadopoulos. All rights reserved.
//

import Foundation

protocol AudioPlayerInterface {
    func play(fromURL url: URL)
    func stop()
    func playStatic()
    func stopStatic()
    var  delegate: AudioPlayerDelegate? {get set}
    func enqueueItem(url: URL)
    func dequeueItem(url: URL)
}
