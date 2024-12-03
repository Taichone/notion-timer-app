//
//  RecordEntity.swift
//  NotionTimerPackage
//
//  Created by Taichi on 2024/12/02.
//

import Foundation

public struct RecordEntity: Identifiable, Hashable, Sendable {
    public let id: String
    public let date: Date
    public let description: String
    public let tags: [TagEntity]
    public let time: Int
}
