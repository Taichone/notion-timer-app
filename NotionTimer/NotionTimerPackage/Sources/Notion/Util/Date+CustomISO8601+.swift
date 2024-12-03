//
//  ISO8601+.swift
//  NotionTimerPackage
//
//  Created by Taichi on 2024/11/14.
//

import Foundation

extension Date {
    init(fromCustomISO8601 string: String) throws {
        self = try .init(
            string,
            strategy: .iso8601.year().month().day().timeZone(separator: .omitted).time(includingFractionalSeconds: true).timeSeparator(.colon)
        )
    }
}
