//
//  TaskCategory.swift
//  NotionTimer
//
//  Created by Taichi on 2024/08/14.
//

import Foundation

public struct TaskCategory: Identifiable, Codable {
    public let id: String
    public var name: String
    
    public init(name: String) {
        self.name = name
        self.id = UUID().uuidString
    }
}
