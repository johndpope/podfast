//
//  PodcastCategory.swift
//  PodFast
//
//  Created by Orestis on 28/07/2019.
//  Copyright © 2019 Orestis Papadopoulos. All rights reserved.
//
import RealmSwift

public class PodcastCategory: Object {
    @objc dynamic var id: Int = 0
    @objc dynamic var name: String?
    @objc dynamic var plays: Int = 0

    public override static func primaryKey() -> String? {
        return "id"
    }

    let podcasts = LinkingObjects(fromType: Podcast.self, property: "categories")
}
