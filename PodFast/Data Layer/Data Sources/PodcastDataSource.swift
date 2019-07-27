//
//  PodcastDataSource.swift
//  
//
//  Created by Orestis on 27/07/2019.
//
import Promises

public protocol PodcastDataSource {
    func update(fromPodcasts podcasts: [Podcast]) -> Promise<Bool>
    func fetchPodcasts() -> Promise<[Podcast]>
    var  lastUpdated: Promise<Date> { get }
}
