//
//  Podcast.swift
//  PodFast
//
//  Created by Orestis on 13/07/2019.
//  Copyright © 2019 Orestis Papadopoulos. All rights reserved.
//

import Foundation
import RealmSwift
import AlamofireObjectMapper
import ObjectMapper
import enum Result.NoError

public class Podcast: Object {
    @objc dynamic var feedUrl: String?
    @objc dynamic var title: String?
    @objc dynamic var podcastDescription: String?
    @objc dynamic var hasBeenDiscovered: Bool = false
    public let _episodes = List<Episode>()
    public let categories = List<PodcastCategory>()

    public override static func primaryKey() -> String? {
        return "title"
    }
}
