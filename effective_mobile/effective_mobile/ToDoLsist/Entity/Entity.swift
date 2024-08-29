//
//  Entity.swift
//  effective_mobile
//
//  Created by Vermut xxx on 28.08.2024.
//

import Foundation


// MARK: - Response model

public struct TodoResponse: Decodable {
    let todos: [Todo]
    let total: Int
    let skip: Int
    let limit: Int
}

public struct Todo: Decodable {
    let id: Int
    let todo: String
    let completed: Bool
    let userId: Int
}
