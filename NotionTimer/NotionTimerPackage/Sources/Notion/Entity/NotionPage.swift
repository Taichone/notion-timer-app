//
//  NotionPage.swift
//  NotionTimerPackage
//
//  Created by Taichi on 2024/11/18.
//

import Foundation

public struct NotionPage: Sendable, Identifiable, Hashable {
    public let id: String
    public let title: String
    
    public init(id: String, title: String) {
        self.id = id
        self.title = title
    }
}
