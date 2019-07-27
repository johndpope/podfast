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

class AppleTopPodcastsResponse: Mappable {
    var updated: Date?
    var podcasts: [AppleTopPodcastID]?

    let stringToIso8601Date = TransformOf<Date, String>(fromJSON: { (value: String?) -> Date? in
        guard let updated = value else { return nil }

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZZZZZ"
        let formattedDate = dateFormatter.date(from: updated)

        return formattedDate
    }, toJSON: { (value: Date?) -> String? in
        // This is broken, not needed for now
        return nil
    })

    required init?(map: Map){

    }

    func mapping(map: Map) {
        updated <- (map["feed.updated"], stringToIso8601Date)
        podcasts <- map["feed.results"]
    }
}

class ApplePodcastLookUpResponse: Mappable {
    var resultCount: Int?
    var podcasts: [AppleTopPodcast]?

    required init?(map: Map){

    }

    func mapping(map: Map) {
        resultCount <- map["resultCount"]
        podcasts <- map["results"]
    }
}

class ConfigFileData: Mappable {
    var updated: Date?
    var podcasts: [ConfigPodcast]?

    let stringToConfigDateFormat = TransformOf<Date, String>(fromJSON: { (value: String?) -> Date? in
        guard let updated = value else { return nil }

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "ddMMyyyy"
        let formattedDate = dateFormatter.date(from: updated)

        return formattedDate
    }, toJSON: { (value: Date?) -> String? in
        // This is broken, not needed for now
        return nil
    })
    
    required init?(map: Map){

    }

    func mapping(map: Map) {
        updated <- (map["updated"], stringToConfigDateFormat)
        podcasts <- map["podcasts"]
    }
}

class BasePodcastResponse: Mappable {
    var url: String?
    var title: String?
    var description: String?

    required init?(map: Map){

    }

    func mapping(map: Map) {

    }

    func toPodcastObject() -> Podcast {
        let dbPodcast = Podcast()
        dbPodcast.feedUrl = url
        dbPodcast.title = title
        dbPodcast.podcastDescription = description
        dbPodcast.hasBeenDiscovered = false //TODO: you don't know this :)
        return dbPodcast
    }
}

class ConfigPodcast: BasePodcastResponse {
    override func mapping(map: Map) {
        url <- map["url"]
        title <- map["title"]
        description <- map["description"]
    }
}

// We get only the podcast ID from the top 100 and do an itunes lookup to get the podcast
class AppleTopPodcastID: BasePodcastResponse {
    var id: String?
    override func mapping(map: Map) {
        id <- map["id"]
    }
}

class AppleTopPodcast: BasePodcastResponse {
    override func mapping(map: Map) {
        url <- map["feedUrl"]
        title <- map["collectionName"]
        description <- map["description"]
    }
}