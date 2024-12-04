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
    case failedToFetchAccessToken
    case accessTokenNotFound
    case invalidClient
    case invalidDatabase
    case failedToGetPageList(error: Error)
    case failedToGetRecordList(error: Error)
    case failedToGetDatabaseList(error: Error)
    case failedToCreateDatabase(error: Error)
}

protocol NotionClientProtocol: Sendable {
    func getPageList() async throws -> [NotionPage]
    func getCompatibleDatabaseList() async throws -> [NotionDatabase]
    func createDatabaseAndGetDatabaseID(parentPageID: String, title: String) async throws -> String
    func record(date: Date, time: Int, tags: [NotionTag], description: String, databaseID: String) async throws
    func getDatabaseTags(databaseID: String) async throws -> [NotionTag]
    func getAllRecords(databaseID: String) async throws -> [Record]
}

// TODO: NotionAuthService を作り認証周りを抜き出すことを検討
@MainActor @Observable public final class NotionService {
    private var accessToken: String? {
        KeychainManager.retrieveToken(type: .notionAccessToken)
    }
    private var databaseID: String? {
        KeychainManager.retrieveToken(type: .notionDatabaseID)
    }
    private var notionClient: NotionClientProtocol?
    public var authStatus: NotionAuthStatus = .loading
    
    public init() {}
    
    public func fetchAccessToken(temporaryToken: String) async throws {
        authStatus = .loading
        
        do {
            let accessToken = try await NotionAuthClient.getAccessToken(temporaryToken: temporaryToken)
            
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
        guard let accessToken = accessToken else {
            authStatus = .invalidToken
            notionClient = nil
            return
        }
        
        notionClient = NotionSwiftClient(accessToken: accessToken)
        
        guard databaseID != nil else {
            authStatus = .invalidDatabase
            return
        }
        
        // TODO: token, databaseID の有効チェック
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
}

extension NotionService {
    public func getPageList() async throws -> [NotionPage] {
        guard let notionClient = notionClient else {
            throw NotionServiceError.invalidClient
        }
        
        do {
            return try await notionClient.getPageList()
        } catch {
            throw NotionServiceError.failedToGetPageList(error: error)
        }
    }
        
    public func getCompatibleDatabaseList() async throws -> [NotionDatabase] {
        guard let notionClient = notionClient else {
            throw NotionServiceError.invalidClient
        }
        
        do {
            return try await notionClient.getCompatibleDatabaseList()
        } catch {
            throw NotionServiceError.failedToGetDatabaseList(error: error)
        }
    }
    
    public func createDatabase(parentPageID: String, title: String) async throws {
        guard let notionClient = notionClient else {
            throw NotionServiceError.invalidClient
        }
        
        do {
            let databaseID = try await notionClient.createDatabaseAndGetDatabaseID(
                parentPageID: parentPageID,
                title: title
            )
            
            try registerDatabase(id: databaseID)
        } catch {
            throw NotionServiceError.failedToCreateDatabase(error: error)
        }
    }
    
    public func registerDatabase(id: String) throws {
        guard KeychainManager.saveToken(token: id, type: .notionDatabaseID) else {
            throw NotionServiceError.failedToSaveToKeychain
        }
        authStatus = .complete
    }
    
    public func record(time: Int, tags: [NotionTag], description: String) async throws {
        guard let notionClient = notionClient else {
            throw NotionServiceError.invalidClient
        }
        guard let databaseID = databaseID else {
            throw NotionServiceError.invalidDatabase
        }
        try await notionClient.record(
            date: Date(),
            time: time,
            tags: tags,
            description: description,
            databaseID: databaseID
        )
    }
    
    public func getDatabaseTags() async throws -> [NotionTag] {
        guard let notionClient = notionClient else {
            throw NotionServiceError.invalidClient
        }
        guard let databaseID = databaseID else {
            throw NotionServiceError.invalidDatabase
        }
        
        return try await notionClient.getDatabaseTags(databaseID: databaseID)
    }
    
    public func getAllRecords() async throws -> [Record] {
        guard let notionClient = notionClient else {
            throw NotionServiceError.invalidClient
        }
        guard let databaseID = databaseID else {
            throw NotionServiceError.invalidDatabase
        }
        
        return try await notionClient.getAllRecords(databaseID: databaseID)
    }
}
