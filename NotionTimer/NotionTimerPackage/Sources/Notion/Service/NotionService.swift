//
//  NotionService.swift
//  NotionTimerPackage
//
//  Created by Taichi on 2024/11/03.
//

import Foundation
import Observation
import Keychain

public enum NotionAuthStatus {
    case loading
    case invalidToken
    case invalidDatabase
    case complete
}

public enum NotionServiceError: Error {
    case failedToSaveToKeychain
    case failedToRetrieveTokenFromKeychain
    case failedToFetchAccessToken
    case accessTokenNotFound
    case invalidClient
    case invalidDatabase
    case failedToGetPageList(error: Error)
    case failedToGetRecordList(error: Error)
    case failedToGetDatabaseList(error: Error)
    case failedToCreateDatabase(error: Error)
}

// TODO: NotionAuthService を作り認証周りを抜き出すことを検討
@MainActor @Observable public final class NotionService {
    private let keychainClient: KeychainClient
    private let notionClient: NotionAPIClient
    
    private var accessToken: String? {
        keychainClient.retrieveToken(.notionAccessToken)
    }
    private var databaseID: String? {
        keychainClient.retrieveToken(.notionDatabaseID)
    }
    
    public var authStatus: NotionAuthStatus = .loading
    
    public init(
        keychainClient: KeychainClient,
        notionClient: NotionAPIClient
    ) {
        self.keychainClient = keychainClient
        self.notionClient = notionClient
    }
    
    public func fetchAccessToken(temporaryToken: String) async throws {
        authStatus = .loading
        
        do {
            let accessToken = try await NotionAuthClient.getAccessToken(temporaryToken: temporaryToken)
            
            guard keychainClient.saveToken(accessToken, .notionAccessToken) else {
                throw NotionServiceError.failedToSaveToKeychain
            }
            
            fetchAuthStatus()
        } catch {
            authStatus = .invalidToken
            throw error
        }
    }
    
    public func fetchAuthStatus() {
        guard accessToken != nil else {
            authStatus = .invalidToken
            return
        }
        
        guard databaseID != nil else {
            authStatus = .invalidDatabase
            return
        }
        
        // TODO: token, databaseID の有効チェック
        authStatus = .complete
    }
    
    public func releaseAccessToken() {
        guard keychainClient.deleteToken(.notionAccessToken),
              keychainClient.deleteToken(.notionDatabaseID) else {
            fatalError("Keychain からトークンを削除できない")
        }
        
        authStatus = .invalidToken
    }
    
    public func releaseSelectedDatabase() {
        guard keychainClient.deleteToken(.notionDatabaseID) else {
            fatalError("Keychain からトークンを削除できない")
        }
        
        authStatus = .invalidDatabase
    }
}

extension NotionService {
    private func token() throws -> String {
        guard let token = accessToken else {
            throw NotionServiceError.failedToRetrieveTokenFromKeychain
        }
        return token
    }
    
    public func getPageList() async throws -> [NotionPage] {
        guard let token = accessToken else {
            throw NotionServiceError.invalidClient
        }
        
        do {
            return try await notionClient.getPageList(token)
        } catch {
            throw NotionServiceError.failedToGetPageList(error: error)
        }
    }
        
    public func getCompatibleDatabaseList() async throws -> [NotionDatabase] {
        do {
            return try await notionClient.getCompatibleDatabaseList(token())
        } catch {
            throw NotionServiceError.failedToGetDatabaseList(error: error)
        }
    }
    
    public func createDatabase(parentPageID: String, title: String) async throws {
        
        do {
            let databaseID = try await notionClient.createDatabaseAndGetDatabaseID(
                token(),
                parentPageID,
                title
            )
            
            try registerDatabase(id: databaseID)
        } catch {
            throw NotionServiceError.failedToCreateDatabase(error: error)
        }
    }
    
    public func registerDatabase(id: String) throws {
        guard keychainClient.saveToken(id, .notionDatabaseID) else {
            throw NotionServiceError.failedToSaveToKeychain
        }
        authStatus = .complete
    }
    
    public func record(time: Int, tags: [NotionTag], description: String) async throws {
        guard let databaseID = databaseID else {
            throw NotionServiceError.invalidDatabase
        }
        
        try await notionClient.record(
            token(),
            Date(),
            time,
            tags,
            description,
            databaseID
        )
    }
    
    public func getDatabaseTags() async throws -> [NotionTag] {
        guard let databaseID = databaseID else {
            throw NotionServiceError.invalidDatabase
        }
        
        return try await notionClient.getDatabaseTags(
            token(),
            databaseID
        )
    }
    
    public func getAllRecords() async throws -> [Record] {
        guard let databaseID = databaseID else {
            throw NotionServiceError.invalidDatabase
        }
        
        return try await notionClient.getAllRecords(
            token(),
            databaseID
        )
    }
}
