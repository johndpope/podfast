//
//  PodcastModel.swift
//  PodFast
//
//  Created by Orestis on 10/07/2019.
//  Copyright © 2019 Orestis Papadopoulos. All rights reserved.
//

import Foundation
import RealmSwift
import AlamofireObjectMapper
import ObjectMapper

// This will be an object
// Respresents a single podcast episode ripped from the podcast enclosure, always the latest one we can get

class Podcast: Object {
    @objc dynamic var url: String?
    @objc dynamic var data: Data?
    @objc dynamic var played: Bool = false
}

class TopPodcastsResponse: Mappable {
    var url: URL?
    var title: String?

    let stringToUrl = TransformOf<URL, String>(fromJSON: { (value: String?) -> URL? in
        // transform value from String? to Int?
        return try! value?.asURL()
    }, toJSON: { (value: URL?) -> String? in
        // transform value from Int? to String?
        if let value = value {
            return value.absoluteString
        }
        return nil
    })

    required init?(map: Map){

    }

    func mapping(map: Map) {
        url <- (map["url"], stringToUrl)
        title <- map["title"]
    }
}
