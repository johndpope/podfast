//
//  DBHelper.swift
//  PodFast
//
//  Created by Orestis on 10/07/2019.
//  Copyright © 2019 Orestis Papadopoulos. All rights reserved.
//

import Foundation
import RealmSwift
import Realm

class DBHelper{
    static let shared = DBHelper()

    private init(){
    }

    private lazy var realm = try! Realm(configuration: defaultConfiguration)

    var defaultConfiguration: Realm.Configuration {
        var config = Realm.Configuration()
        config.deleteRealmIfMigrationNeeded = true
        config.schemaVersion = 1
        return config
    }
    
    func getRealm() -> Realm {
        return realm
    }
}
