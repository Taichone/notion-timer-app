//
//  JSONEncoder+SnakeCase.swift
//  NotionTimerPackage
//
//  Created by Taichi on 2024/11/15.
//

import Foundation

extension JSONEncoder {
    static let snakeCase: JSONEncoder = {
        let encoder = JSONEncoder()
        encoder.keyEncodingStrategy = .convertToSnakeCase
        return encoder
    }()
}
