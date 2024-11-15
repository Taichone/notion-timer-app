//
//  NotionAuthService.swift
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
        do {
            let accessToken = try await NotionAPIClient.getAccessToken(temporaryToken: temporaryToken)
            
            if !KeychainManager.saveToken(token: accessToken, type: .notionAccessToken) {
                throw NotionServiceError.failedToSaveToKeychain
            }
        } catch {
            authStatus = .unauthorized
            throw error
        }
    }
    
    // TODO: accessToken だけじゃなく、pageID, databaseID までが取得できてから、status を authorized にする
    public func fetchAuthStatus() {
        authStatus = .loading
        
        if accessToken == nil {
            authStatus = .unauthorized
        } else {
            authStatus = .authorized
        }
    }
    
    // MARK:  Page List
    
    public func getPageList() async throws -> [Page] {
        guard let accessToken = accessToken else {
            throw NotionServiceError.accessTokenNotFound
        }
        
        let pages = try await NotionAPIClient.getPageList(accessToken: accessToken)
        pages.forEach { debugPrint($0.title) }
        return pages
    }
    
    public func changeStatusToLoading() {
        authStatus = .loading
    }
    
    public func changeStatusToUnauthorized() {
        authStatus = .unauthorized
    }
}
