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
    var radio = Radio()

    @IBOutlet weak var podcastTitleLabel: UILabel!
    @IBOutlet weak var episodeTitleLabel: UIButton!
    @IBOutlet weak var slider: UIAdjustableScrubSlider!

    override func viewDidLoad() {
        super.viewDidLoad()

        self.episodeTitleLabel.isHidden = true
        podcastTitleLabel.isHidden = true

        slider.minimumValue = Float(radio.frequencyRange.first!)
        slider.maximumValue = Float(radio.frequencyRange.last!)

        slider.setSnapPoints(radio.stations.compactMap({ station in
            if(station.audioPlayerItem.status != .failed) {
                 return Float(station.frequency)
            }
            return nil
        }))

        slider.setSmoothing(type: .simple)

        radio.tune(toFrequency: radio.frequencyRange.lowerBound)
    }

    @IBAction func playPodcast(_ sender: UIButton) {
    }

    @IBAction func newRadio(_ sender: UIButton) {
        radio = Radio()
        radio.tune(toFrequency: radio.frequencyRange.lowerBound)
    }

    @IBAction func sliderValueChanged(_ sender: UISlider) {
        radio.tune(toFrequency: Int(sender.value))
    }
}

