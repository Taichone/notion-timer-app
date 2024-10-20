//
//  TaskCategory.swift
//  NotionTimer
//
//  Created by Taichi on 2024/08/14.
//

import Foundation

public struct TaskCategory: Hashable, Identifiable {
    public let id = UUID().uuidString
    public var name: String
}
