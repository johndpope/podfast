//
//  HiddenCategoriesDataSource.swift
//  PodFast
//
//  Created by Orestis on 8/4/20.
//  Copyright © 2020 Orestis Papadopoulos. All rights reserved.
//

import Foundation
import Promises

public struct HiddenCategoriesDataSource: DataSource {

    public var description = "config"

    public func fetchAll() -> Promise<[String]> {
        if let configData = try! ConfigurationDataRequest().execute() {
            return Promise<[String]>(
                configData.hiddenCategories ?? [String]()
            )
        } else {
            // TODO Handle Error Type Here
            return Promise<[String]>([String]())
        }
    }

    public func lastUpdated() -> Promise<Date> {
        if let configData = try! ConfigurationDataRequest().execute() {
            return Promise<Date>(configData.updated ?? Date(timeIntervalSince1970: 0))
        } else {
            return Promise<Date>(APIRequestError.noValueInResponse)
        }
    }
}
