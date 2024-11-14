//
//  NotionService.swift
//  NotionTimerPackage
//
//  Created by Taichi on 2024/11/03.
//

import Foundation
import LocalRepository

public struct NotionService {
    // FIXME: public にはしない（一時的に public にしている）
    public static var accessToken: String? {
        KeychainManager.retrieveToken(type: .notionAccessToken)
    }
}
