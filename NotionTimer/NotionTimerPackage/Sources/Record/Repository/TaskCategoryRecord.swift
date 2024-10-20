//
//  File.swift
//  NotionTimerPackage
//
//  Created by Taichi on 2024/10/20.
//

import Foundation
import SwiftData

// Model, TaskCategory は 1:1 対応
@Model
public final class TaskCategoryRecord {
    public var category: TaskCategory
    public var time: Int
    
    public init(category: TaskCategory, time: Int = 0) {
        self.category = category
        self.time = time
    }
}
