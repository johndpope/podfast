//
//  PodcastRepository.swift
//  PodFast
//
//  Created by Orestis on 27/07/2019.
//  Copyright © 2019 Orestis Papadopoulos. All rights reserved.
//
import Promises

enum UpdatePolicy {
    case config
    case remote
}

protocol PodcastRepository {
    func update(withPolicy policy: UpdatePolicy) -> Promise<Bool>
}
