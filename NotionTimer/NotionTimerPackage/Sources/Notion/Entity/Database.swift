//
//  Database.swift
//  NotionTimerPackage
//
//  Created by Taichi on 2024/11/16.
//

import Foundation

public struct Database: Sendable, Identifiable, Hashable {
    public let id: String
    public let title: String
    
    public init(id: String, title: String) {
        self.id = id
        self.title = title
    }
}
