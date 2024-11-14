//
//  NotionService.swift
//  NotionTimerPackage
//
//  Created by Taichi on 2024/11/03.
//

import LocalRepository

enum NotionError: Error {
    case accessTokenNotFound
    case failedToGetPageList
}

public actor NotionRepository {
    // FIXME: public にはしない（一時的に public にしている）
    public static var accessToken: String? {
        KeychainManager.retrieveToken(type: .notionAccessToken)
    }
    
    public func getPageList() async throws -> [Page] {
        guard let accessToken = Self.accessToken else {
            throw NotionError.accessTokenNotFound
        }
        
        return try await NotionAPIClient.getPageList(accessToken: accessToken)
    }
    
    public init() {}
}
