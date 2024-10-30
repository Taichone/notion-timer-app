//
//  File.swift
//  NotionTimerPackage
//
//  Created by Taichi on 2024/10/20.
//

import Foundation
import SwiftData

// Model, Label は 1:1 対応
@Model
public final class Record: Hashable {
    public var taskCategory: TaskCategory
    public var time: Int
    
    public init(taskCategory: TaskCategory, time: Int = 0) {
        self.taskCategory = taskCategory
        self.time = time
    }
}
