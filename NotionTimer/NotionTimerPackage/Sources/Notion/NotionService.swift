//
//  NotionService.swift
//  NotionTimerPackage
//
//  Created by Taichi on 2024/11/03.
//

import Foundation
import LocalRepository

public enum NotionAuthStatus {
    case loading
    case authorized
    case unauthorized
}

public enum NotionServiceError: Error {
    case failedToSaveToKeychain
    case failedToFetchAccessToken
    case accessTokenNotFound
    case failedToGetPageList
    case failedToGetDatabaseList
}

@MainActor
@Observable public final class NotionService {
    public var authStatus: NotionAuthStatus = .loading
    public var accessToken: String? {
        KeychainManager.retrieveToken(type: .notionAccessToken)
    }
    
    public init() {}
    
    // MARK: AccesToken
    
    public func fetchAccessToken(temporaryToken: String) async throws {
        authStatus = .loading
        
        do {
            let accessToken = try await NotionAPIClient.getAccessToken(temporaryToken: temporaryToken)
            
            guard KeychainManager.saveToken(token: accessToken, type: .notionAccessToken) else {
                throw NotionServiceError.failedToSaveToKeychain
            }
            
            fetchAuthStatus()
        } catch {
            authStatus = .unauthorized
            throw error
        }
    }
    
    public func fetchAuthStatus() {
        // TODO: 検討：ログイン状態にするが、後の通信で
        // - accessToken が無効なら unauthorized に
        // - databaseID が無効なら authorized のままで、database を選択させる？
        if self.accessToken != nil {
            authStatus = .authorized
        } else {
            authStatus = .unauthorized
        }
    }
    
    // MARK:  Page
    
    public func getPageList() async throws -> [Page] {
        guard let accessToken = accessToken else {
            throw NotionServiceError.accessTokenNotFound
        }
        
        return try await NotionAPIClient.getPageList(accessToken: accessToken)
    }
    
    // MARK: Database
    
    public func getDatabaseList() async throws -> [Database] {
        guard let accessToken = accessToken else {
            throw NotionServiceError.accessTokenNotFound
        }
        
        return try await NotionAPIClient.getDatabaseList(accessToken: accessToken)
    }
}
