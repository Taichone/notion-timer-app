//
//  NotionService.swift
//  NotionTimerPackage
//
//  Created by Taichi on 2024/11/03.
//

import Foundation
import Keychain
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
    case invalidDatabase
    case failedToGetPageList(error: Error)
    case failedToGetRecordList(error: Error)
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
    
    public func record(time: Int, tags: [TagEntity], description: String) async throws {
        guard let notionClient = notionClient else {
            throw NotionServiceError.invalidClient
        }
        guard let databaseID = databaseID else {
            throw NotionServiceError.invalidDatabase
        }
        try await record(
            date: Date(),
            time: time,
            tags: tags,
            description: description,
            databaseID: databaseID,
            client: notionClient
        )
    }
    
    public func getDatabaseTags() async throws -> [TagEntity] {
        guard let notionClient = notionClient else {
            throw NotionServiceError.invalidClient
        }
        guard let databaseID = databaseID else {
            throw NotionServiceError.invalidDatabase
        }
        
        return try await getDatabaseTags(databaseID: databaseID, client: notionClient)
    }
    
    public func getAllRecords() async throws -> [RecordEntity] {
        guard let notionClient = notionClient else {
            throw NotionServiceError.invalidClient
        }
        guard let databaseID = databaseID else {
            throw NotionServiceError.invalidDatabase
        }
        
        return try await getAllRecords(databaseID: databaseID, client: notionClient)
    }
}

// MARK: - NotionSwift

extension NotionService {
    private func getAllRecords(
        databaseID: String,
        client: NotionClient
    ) async throws -> [RecordEntity] {
        return try await withCheckedThrowingContinuation { continuation in
            client.databaseQuery(databaseId: .init(databaseID)) {
                do {
                    var records = [RecordEntity]()
                    let pages = try $0.get()
                    pages.results.forEach { page in
                        if let record = page.asRecordEntity {
                            records.append(record)
                        }
                    }
                    continuation.resume(returning: records)
                } catch {
                    continuation.resume(
                        throwing: NotionServiceError.failedToGetRecordList(error: error)
                    )
                }
            }
        }
    }
    
    private func record(
        date: Date,
        time: Int,
        tags: [TagEntity],
        description: String,
        databaseID: String,
        client: NotionClient
    ) async throws {
        let multiSelectList: [PagePropertyType.MultiSelectPropertyValue] = tags.compactMap {
            .init(id: .init($0.id), name: nil, color: nil)
        }
        
        let request = PageCreateRequest(
            parent: .database(.init(databaseID)),
            properties: [
                "title": .init(
                    type: .title([
                        .init(string: "")
                    ])
                ),
                "Tag": .init(
                    type: .multiSelect(multiSelectList)
                ),
                "Time": .init(
                    type: .number(.init(time))
                ),
                "Description": .init(
                    type: .richText([
                        .init(string: description)
                    ])
                ),
                "Date": .init(
                    type: .date(.init(start: .dateAndTime(date), end: nil))
                )
            ]
        )
        
        return try await withCheckedThrowingContinuation { continuation in
            client.pageCreate(request: request) { result in
                switch result {
                case .success:
                    continuation.resume(with: .success(()))
                case .failure(let error):
                    continuation.resume(throwing: error)
                    debugPrint(error.localizedDescription)
                }
            }
        }
    }
    
    private func getDatabaseTags(
        databaseID: String,
        client: NotionClient
    ) async throws -> [TagEntity] {
        return try await withCheckedThrowingContinuation { continuation in
            client.database(databaseId: .init(databaseID)) { result in
                do {
                    let resultDatabase = try result.get()
                    guard let tagProperty = resultDatabase.properties["Tag"],
                          case .multiSelect(let selectOptions) = tagProperty.type
                    else {
                        throw NotionServiceError.invalidDatabase
                    }
                    
                    let tags: [TagEntity] = selectOptions.compactMap { selectOption in
                        guard let color = TagEntity.Color(rawValue: selectOption.color) else {
                            fatalError("ERROR: 無効な color 名のタグがある")
                        }
                        return .init(id: selectOption.id.rawValue, name: selectOption.name, color: color)
                    }
                    
                    continuation.resume(returning: tags)
                } catch {
                    continuation.resume(throwing: error)
                }
            }
        }
    }
    
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
    
    var asRecordEntity: RecordEntity? {
        guard case .richText(let richTexts) = self.properties["Description"]?.type,
              case .text(let textValue) = richTexts.first?.type,
              case .date(let dateRange) = self.properties["Date"]?.type,
              case .dateAndTime(let date) = dateRange?.start,
              case .multiSelect(let multiSelectValue) = self.properties["Tag"]?.type,
              case .number(let decimalTime) = self.properties["Time"]?.type,
              let decimalTime = decimalTime else {
            return nil
        }
        
        let description = textValue.content
        let time = NSDecimalNumber(decimal: decimalTime).intValue
        let tags: [TagEntity] = multiSelectValue.map {
            .init(
                id: $0.id?.rawValue ?? UUID().uuidString, // ForEach で表示するために補填
                name: $0.name ?? "",
                color: .init(rawValue: $0.color ?? "default") ?? .default
            )
        }
        
        return .init(
            id: self.id.rawValue,
            date: date,
            description: description,
            tags: tags,
            time: time
        )
    }
}
