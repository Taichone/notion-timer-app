//
//  JSONDecoder+SnakeCase.swift
//  NotionTimerPackage
//
//  Created by Taichi on 2024/11/15.
//

import Foundation

extension JSONDecoder {
    static let snakeCase: JSONDecoder = {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return decoder
    }()
}
