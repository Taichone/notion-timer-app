//
//  Page.swift
//  NotionTimerPackage
//
//  Created by Taichi on 2024/11/14.
//

import Foundation

public struct Page: Sendable, Identifiable {
    public let id: String
    public let lastEditedTime: Date
    public let parentPageID: String?
    public let title: String
}
