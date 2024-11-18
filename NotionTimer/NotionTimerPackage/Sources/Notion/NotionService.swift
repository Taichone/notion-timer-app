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
        var resultPages: Result<[Page], NotionClientError>
        
        // TODO: Concurrency ラッピング
        notionClient?.search(request: .init(filter: .page)) { result in
            resultPages = result.map { objects in
                objects.results.compactMap({ object -> Page? in
                    if case .page(let page) = object {
                        return page
                    }
                    return nil
                })
            }
        }
        
        let pages = try resultPages.get()
        return pages.compactMap { $0.asPageEntity }
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
        
        let databases = try resultDatabases.get()
        return databases.compactMap { $0.asDatabaseEntity }
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

extension Database {
    var asDatabaseEntity: DatabaseEntity? {
        guard let title = self.title.first,
              case .text(let richTextType) = title.type else {
            return nil
        }
        return .init(id: self.id.rawValue, title: richTextType.content)
    }
}

extension Page {
    var asPageEntity: PageEntity? {
        guard let title = self.getTitle()?.first,
              case .text(let richTextType) = title.type else {
            return nil
        }
        return .init(id: self.id.rawValue, title: richTextType.content)
    }
}
