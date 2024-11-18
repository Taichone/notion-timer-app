//
//  NotionService.swift
//  NotionTimerPackage
//
//  Created by Taichi on 2024/11/03.
//

import Foundation
import LocalRepository
import NotionSwift

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
    private var accessToken: String? {
        KeychainManager.retrieveToken(type: .notionAccessToken)
    }
    private var databaseID: String? {
        KeychainManager.retrieveToken(type: .notionDatabaseID)
    }
    private var notionClient: NotionClient?
    public var authStatus: NotionAuthStatus = .loading
    
    public init() {}
    
    // MARK: AccesToken
    
    public func fetchAccessToken(temporaryToken: String) async throws {
        authStatus = .loading
        
        do {
            let accessToken = try await NotionAPIClient.getAccessToken(temporaryToken: temporaryToken)
            
            guard KeychainManager.saveToken(token: accessToken, type: .notionAccessToken) else {
                throw NotionServiceError.failedToSaveToKeychain
            }
            
            notionClient = NotionClient(accessKeyProvider: StringAccessKeyProvider(accessKey: accessToken))
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
    
    public func getPageList() async throws -> [PageEntity] {
        guard let accessToken = accessToken else {
            throw NotionServiceError.accessTokenNotFound
        }
        
        return try await NotionAPIClient.getPageList(accessToken: accessToken)
    }
    
    // MARK: Database
        
    public func getDatabaseList() async throws -> [DatabaseEntity] {
        var resultDatabases: Result<[Database], NotionClientError>
        
        // TODO: Concurrency ラッピング
        notionClient?.search(request: .init(filter: .database)) { result in
            resultDatabases = result.map { objects in
                objects.results.compactMap({ object -> Database? in
                    if case .database(let db) = object {
                        return db
                    }
                    return nil
                })
            }
        }
        
        // [DatabaseEntity] に変換して返す
        let notionDatabases = try resultDatabases.get()
        let databases: [DatabaseEntity] = notionDatabases.compactMap {
            guard let title = $0.title.first,
                  case .text(let richTextType) = title.type else {
                return nil
            }
            return .init(id: $0.id.rawValue, title: richTextType.content)
        }
        return databases
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
}
