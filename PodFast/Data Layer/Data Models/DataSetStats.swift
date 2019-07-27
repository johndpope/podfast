//
//  Updates.swift
//  PodFast
//
//  Created by Orestis on 24/07/2019.
//  Copyright © 2019 Orestis Papadopoulos. All rights reserved.
//

import Foundation
import RealmSwift
import AlamofireObjectMapper
import ObjectMapper

class DataSetStats: Object {
    @objc dynamic var uniqueKey: Int = 0
    @objc dynamic var configVersion: Int = 0
    @objc dynamic var appleTopPodcastsLastUpdate: Date?

    override static func primaryKey() -> String? {
        return "uniqueKey"
    }
}
