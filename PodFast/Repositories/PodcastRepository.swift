//
//  PodcastRepository.swift
//  PodFast
//
//  Created by Orestis on 27/07/2019.
//  Copyright © 2019 Orestis Papadopoulos. All rights reserved.
//
import Promises

protocol PodcastRepository {
    func update() -> Promise<Bool>
}
