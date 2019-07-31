//
//  Episode.swift
//  PodFast
//
//  Created by Orestis on 13/07/2019.
//  Copyright © 2019 Orestis Papadopoulos. All rights reserved.
//

import Foundation
import RealmSwift
import AlamofireObjectMapper
import ObjectMapper

public class Episode: Object {
    @objc dynamic var url: String?
    @objc dynamic var episodeDescription: String?
    @objc dynamic var title: String?
    @objc dynamic var hasBeenPlayed: Bool = false
    @objc dynamic var cachedData: Data?

    let podcast = LinkingObjects(fromType: Podcast.self, property: "_episodes")
}
