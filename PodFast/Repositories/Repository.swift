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
