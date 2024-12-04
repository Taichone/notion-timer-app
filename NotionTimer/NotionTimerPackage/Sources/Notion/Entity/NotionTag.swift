//
//  NotionTag.swift
//  NotionTimerPackage
//
//  Created by Taichi on 2024/11/21.
//

public struct NotionTag: Identifiable, Hashable, Sendable {
    public let id: String
    public let name: String
    public let color: Color
    
    public init(id: String, name: String, color: Color) {
        self.id = id
        self.name = name
        self.color = color
    }
    
    public enum Color: String, Sendable {
        case blue
        case brown
        case `default`
        case gray
        case green
        case orange
        case pink
        case purple
        case red
        case yellow
    }
}
