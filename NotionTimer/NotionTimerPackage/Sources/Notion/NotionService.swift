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
        // TODO: accessToken だけじゃなく、pageID, databaseID までが取得できてから、status を authorized にする
        authStatus = accessToken == nil ? .unauthorized : .authorized
    }
    
    // MARK:  Page List
    
    public func getPageList() async throws -> [Page] {
        guard let accessToken = accessToken else {
            throw NotionServiceError.accessTokenNotFound
        }
        
        return try await NotionAPIClient.getPageList(accessToken: accessToken)
    }
}
