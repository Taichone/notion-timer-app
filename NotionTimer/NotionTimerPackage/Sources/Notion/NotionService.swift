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

public enum AccessTokenError: Error {
    case failedToSaveToKeychain
    case failedToFetchAccessToken
    case urlSessionError(Error)
}

@MainActor
@Observable public final class NotionService {
    // TODO: accessToken だけじゃなく、pageID, databaseID までが取得できてから、status を authorized にする
    public var status: NotionAuthStatus = .loading
    public var accessToken: String?
    
    public init() {}
    
    // MARK: AccesToken
    
    public func fetchAccessToken(temporaryToken: String) async throws {
        do {
            let accessToken = try await NotionAPIClient.getAccessToken(temporaryToken: temporaryToken)
            
            if KeychainManager.saveToken(token: accessToken, type: .notionAccessToken) {
                status = .authorized
            } else {
                throw AccessTokenError.failedToSaveToKeychain
            }
        } catch {
            status = .unauthorized
            throw error
        }
    }
    
    public func retrieveAccessTokenFromKeychain() {
        status = .loading
        
        if let token = KeychainManager.retrieveToken(type: .notionAccessToken) {
            accessToken = token
            status = .authorized
        } else {
            status = .unauthorized
        }
    }
    
    // MARK:  Page List
    
    public func getPageList() async throws -> [Page] {
        guard let accessToken = accessToken else {
            throw NotionError.accessTokenNotFound
        }
        
        let pages = try await NotionAPIClient.getPageList(accessToken: accessToken)
        pages.forEach { debugPrint($0.title) }
        return pages
    }
    
    public func changeStatusToLoading() {
        status = .loading
    }
    
    public func changeStatusToUnauthorized() {
        status = .unauthorized
    }
}
