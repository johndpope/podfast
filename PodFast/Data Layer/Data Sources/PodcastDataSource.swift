//
//  PodcastDataSource.swift
//  
//
//  Created by Orestis on 27/07/2019.
//
import Promises

public protocol PodcastDataSource {
    func fetchPodcasts() -> Promise<[Podcast]>
    var lastUpdated: Promise<Date> { get }
    var description: String { get }
}
