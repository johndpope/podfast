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

class DataSetUpdated: Object {
    @objc dynamic var dataSource: String?
    @objc dynamic var date: Date?

    override static func primaryKey() -> String? {
        return "dataSource"
    }
}
