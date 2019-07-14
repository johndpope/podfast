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

class TopPodcastsResponse: Mappable {
    var url: URL?
    var title: String?
    var description: String?

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
        description <- map["description"]
    }
}

class ConfigFileData: Mappable {
    var version: Int?
    var podcasts: [[String: Any]] = [[:]]
    
    required init?(map: Map){

    }

    func mapping(map: Map) {
        version <- map["version"]
        podcasts <- map["podcasts"]
    }
}

class ConfigPodcast: Mappable {
    var url: String?
    var title: String?
    var description: String?

    required init?(map: Map){

    }

    func mapping(map: Map) {
        url <- map["url"]
        title <- map["title"]
        description <- map["description"]
    }
}
