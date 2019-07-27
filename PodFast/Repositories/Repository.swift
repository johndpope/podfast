//
//  Repository.swift
//  PodFast
//
//  Created by Orestis on 25/07/2019.
//  Copyright © 2019 Orestis Papadopoulos. All rights reserved.
//

// Leave this here for now

protocol Repository {

    associatedtype T

    func getAll() -> [T]
    func get( identifier:Int ) -> T?
    func create( a:T ) -> Bool
    func update( a:T ) -> Bool
    func delete( a:T ) -> Bool

}
