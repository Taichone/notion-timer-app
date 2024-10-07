//
//  TaskCategory.swift
//  NotionTimer
//
//  Created by Taichi on 2024/08/14.
//

import Foundation

struct TaskCategory: Hashable, Identifiable {
    let id = UUID()
    let name: String
}

extension TaskCategory {
    static let mockList: [Self] = [
        TaskCategory(name: "Swift"),
        TaskCategory(name: "Kotlin"),
        TaskCategory(name: "Python"),
        TaskCategory(name: "TypeScript")
    ]
}
