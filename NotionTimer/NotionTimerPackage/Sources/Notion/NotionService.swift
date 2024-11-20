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
    case accessTokenNotFound
    case invalidClient
    case failedToGetPageList(error: Error)
    case failedToGetDatabaseList(error: Error)
    case failedToCreateDatabase(error: Error)
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
        
        notionClient = NotionClient(accessKeyProvider: StringAccessKeyProvider(accessKey: accessToken))
        
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
    public func getPageList() async throws -> [PageEntity] {
        guard let notionClient = notionClient else {
            throw NotionServiceError.invalidClient
        }
        
        do {
            return try await getPageList(client: notionClient)
        } catch {
            throw NotionServiceError.failedToGetPageList(error: error)
        }
    }
        
    public func getCompatibleDatabaseList() async throws -> [DatabaseEntity] {
        guard let notionClient = notionClient else {
            throw NotionServiceError.invalidClient
        }
        
        do {
            return try await getCompatibleDatabaseList(client: notionClient)
        } catch {
            throw NotionServiceError.failedToGetDatabaseList(error: error)
        }
    }
    
    public func createDatabase(parentPageID: String, title: String) async throws {
        guard let notionClient = notionClient else {
            throw NotionServiceError.invalidClient
        }
        
        do {
            let databaseID = try await createDatabaseAndGetDatabaseID(
                parentPageID: parentPageID,
                title: title,
                client: notionClient
            )
            
            // Keychain にデータベースIDを保存し、認証状態を更新
            guard KeychainManager.saveToken(token: databaseID, type: .notionDatabaseID) else {
                throw NotionServiceError.failedToSaveToKeychain
            }
            authStatus = .complete
        } catch {
            throw NotionServiceError.failedToCreateDatabase(error: error)
        }
    }
}

// MARK: - NotionSwift

extension NotionService {
    private func createDatabaseAndGetDatabaseID(
        parentPageID: String,
        title: String,
        client: NotionClient
    ) async throws -> String {
        let request = DatabaseCreateRequest(
            parent: .pageId(.init(parentPageID)),
            icon: .none,
            cover: .none,
            title: [
                .init(string: title)
            ],
            properties: [
                "Date": .date,
                "Title": .title,
                "Tag": .multiSelect([]),
                "Time": .number(.numberWithCommas),
                "Description": .richText,
            ],
            isInline: true
        )

        return try await withCheckedThrowingContinuation { continuation in
            client.databaseCreate(request: request) { result in
                switch result {
                case .success(let db):
                    continuation.resume(returning: db.id.rawValue)
                case .failure(let error):
                    continuation.resume(throwing: error)
                    debugPrint(error.localizedDescription)
                }
            }
        }
    }
    
    private func propertiesNeedAdded(db: Database) async throws -> [String: DatabasePropertyType]  {
        return .init()
    }
    
    private func getCompatibleDatabaseList(client: NotionClient) async throws -> [DatabaseEntity] {
        return try await withCheckedThrowingContinuation { continuation in
            client.search(request: .init(filter: .database)) { result in
                let resultDatabases = result.map { objects in
                    objects.results.compactMap({ object -> Database? in
                        if case .database(let db) = object {
                            let properties = db.properties
                            
                            // 記録に用いるプロパティをすべて持つ DB に絞る
                            if let dateProperty = properties["Date"],
                               case .date = dateProperty.type,
                               let tagProperty = properties["Tag"],
                               case .multiSelect = tagProperty.type,
                               let timeProperty = properties["Time"],
                               case .number = timeProperty.type,
                               let descriptionProperty = properties["Description"],
                               case .richText = descriptionProperty.type {
                                return db
                            }
                        }
                        return nil
                    })
                }
                
                do {
                    let databases = try resultDatabases.get().compactMap { $0.asDatabaseEntity }
                    continuation.resume(returning: databases)
                } catch {
                    continuation.resume(throwing: error)
                }
            }
        }
    }
    
    private func getPageList(client: NotionClient) async throws -> [PageEntity] {
        return try await withCheckedThrowingContinuation { continuation in
            client.search(request: .init(filter: .page)) { result in
                let resultPages = result.map { objects in
                    objects.results.compactMap({ object -> Page? in
                        if case .page(let page) = object {
                            // TODO: DB 内の Page は除外したい
                            return page
                        }
                        return nil
                    })
                }
                
                do {
                    let pages = try resultPages.get().compactMap { $0.asPageEntity }
                    continuation.resume(returning: pages)
                } catch {
                    continuation.resume(throwing: error)
                }
            }
        }
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
