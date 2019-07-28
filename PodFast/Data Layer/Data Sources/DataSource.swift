//
//  DataSource.swift
//  PodFast
//
//  Created by Orestis on 28/07/2019.
//  Copyright © 2019 Orestis Papadopoulos. All rights reserved.
//

import Promises

public protocol DataSource {
    associatedtype DataType

    func fetchAll() -> Promise<[DataType]>
    func lastUpdated() -> Promise<Date>
    var description: String { get }
}

// A Local Data Source is a quick access local store which can get updated from a Data Source whenever is needed
public protocol LocalDataSource: DataSource {
    func update<D: DataSource>(fromSource dataSource: D) -> Promise<Bool> where D.DataType == DataType
}

// Type Erased Struct to Represent Any Data Source
struct AnyDataSource<U>: DataSource {
    typealias DataType = U

    private let _lastUpdated: () -> Promise<Date>

    var description: String

    private let _fetchPodcasts: () -> Promise<[U]>

    init<Base: DataSource>(base : Base) where Base.DataType == U {
        _fetchPodcasts = base.fetchAll
        _lastUpdated = base.lastUpdated
        description = base.description
    }

    func fetchAll() -> Promise<[U]> {
        return _fetchPodcasts()
    }

    func lastUpdated() -> Promise<Date> {
        return _lastUpdated()
    }
}

// Type Erased Struct to Represent Any Local Data Source
struct AnyLocalDataSource<U>: LocalDataSource {

    typealias DataType = U

    private let _lastUpdated: () -> Promise<Date>
    private let _fetchPodcasts: () -> Promise<[U]>
    private let _updateFromSource: (AnyDataSource<U>) -> Promise<Bool>

    var description: String

    init<Base: LocalDataSource>(base : Base) where Base.DataType == U{
        _fetchPodcasts = base.fetchAll
        _lastUpdated = base.lastUpdated
        _updateFromSource = base.update
        description = base.description
    }

    func update<D>(fromSource dataSource: D) -> Promise<Bool> where D : DataSource, DataType == D.DataType {
        let actualDataSource = AnyDataSource<U>(base: dataSource)
        return _updateFromSource(actualDataSource)
    }

    func fetchAll() -> Promise<[U]> {
        return _fetchPodcasts()
    }

    func lastUpdated() -> Promise<Date> {
        return _lastUpdated()
    }
}
