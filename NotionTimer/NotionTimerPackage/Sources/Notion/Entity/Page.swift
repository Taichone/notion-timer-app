//
//  Page.swift
//  NotionTimerPackage
//
//  Created by Taichi on 2024/11/14.
//

import Foundation

public struct Page: Sendable {
    public let id: String
    public let lastEditedTime: Date
    public let parentPageId: String?
    public let title: String
}
