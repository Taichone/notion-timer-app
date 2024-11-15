//
//  Database.swift
//  NotionTimerPackage
//
//  Created by Taichi on 2024/11/16.
//

import Foundation

public struct Database: Sendable, Identifiable {
    public let id: String
    public let title: String
    public let lastEditedTime: Date
}
