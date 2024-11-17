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
    case invalidToken
    case invalidDatabase
    case complete
}

public enum NotionServiceError: Error {
    case failedToSaveToKeychain
    case failedToFetchAccessToken
    case failedToCreateDatabase
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
    public var databaseID: String? {
        KeychainManager.retrieveToken(type: .notionDatabaseID)
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
            authStatus = .invalidToken
            throw error
        }
    }
    
    public func fetchAuthStatus() {
        // TODO: 有効チェック
        
        // -[] accessToken 有効チェック
        guard accessToken != nil else {
            authStatus = .invalidToken
            return
        }
        
        // -[] databaseID 有効チェック
        guard databaseID != nil else {
            authStatus = .invalidDatabase
            return
        }

        authStatus = .complete
    }
    
    public func releaseAccessToken() {
        guard KeychainManager.deleteToken(type: .notionAccessToken),
              KeychainManager.deleteToken(type: .notionDatabaseID) else {
            fatalError("Keychain からトークンを削除できない")
        }
        
        authStatus = .invalidToken
    }
    
    public func releaseSelectedDatabase() {
        guard KeychainManager.deleteToken(type: .notionDatabaseID) else {
            fatalError("Keychain からトークンを削除できない")
        }
        
        authStatus = .invalidDatabase
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
    
    public func createDatabase(parentPageID: String, title: String) async throws {
        guard let accessToken = accessToken else {
            throw NotionServiceError.accessTokenNotFound
        }
        
        let databaseID = try await NotionAPIClient.createDatabase(accessToken: accessToken, parentPageID: parentPageID, title: title)
        guard KeychainManager.saveToken(token: databaseID, type: .notionDatabaseID) else {
            throw NotionServiceError.failedToSaveToKeychain
        }
        authStatus = .complete
    }
    
    public func selectDatabase(id: String ) async throws {
        // TODO: 既存データベースの整形
        // - 必要に応じてプロパティを追加
        // - databaseID の保存
        // - authStatus = .complete
    }
    
//    public func appendMultiSelectLabel(id: String, selectLabelTitle: String) async throws {
//        print("TODO: append\(selectLabelTitle)")
//    }
}
