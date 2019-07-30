//
//  Repository.swift
//  PodFast
//
//  Created by Orestis on 25/07/2019.
//  Copyright © 2019 Orestis Papadopoulos. All rights reserved.
//

// Leave this here for now
import Promises

enum RepositoryUpdatePolicy {
    case config
    case remote
}

protocol Repository {
    
    associatedtype T
    
    func getAll() -> Promise<[T]>
    func update(withPolicy policy: RepositoryUpdatePolicy) -> Promise<Bool>
//    func get( identifier:Int ) -> T?
//    func create( a:T ) -> Bool
//    func delete( a:T ) -> Bool
    
}

// Type Erased Struct to Represent Any Data Source
struct AnyRepository<U>: Repository {

    typealias T = U

    private var _getAll: () -> Promise<[U]>
    private var _update: (RepositoryUpdatePolicy) -> Promise<Bool>

    init<Base: Repository>(base : Base) where Base.T == U {
        _getAll = base.getAll
        _update = base.update
    }

    func getAll() -> Promise<[U]> {
        return _getAll()
    }

    func update(withPolicy policy: RepositoryUpdatePolicy) -> Promise<Bool> {
        return _update(policy)
    }
}
