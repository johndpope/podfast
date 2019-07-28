//
//  PodcastLocalDataSource.swift
//  PodFast
//
//  Created by Orestis on 28/07/2019.
//  Copyright © 2019 Orestis Papadopoulos. All rights reserved.
//

import Foundation
import Promises

public protocol PodcastLocalDataSource: PodcastDataSource {
    func update(fromSource dataSource: PodcastDataSource) -> Promise<Bool>
    func get(lastUpdatedDatasourceDate dataSource: PodcastDataSource) -> Date
}
