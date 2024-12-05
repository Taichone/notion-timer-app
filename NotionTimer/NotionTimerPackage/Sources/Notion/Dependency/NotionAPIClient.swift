//
//  NotionAPIClient.swift
//  NotionTimerPackage
//
//  Created by Taichi on 2024/12/04.
//

import Foundation
@preconcurrency import NotionSwift

public protocol DependencyClient: Sendable {
    static var liveValue: Self { get }
    static var testValue: Self { get }
}

public struct NotionAPIClient: DependencyClient {
    public var getPageList: @Sendable (String) async throws -> [NotionPage]
    public var getCompatibleDatabaseList: @Sendable (String) async throws -> [NotionDatabase]
    public var createDatabaseAndGetDatabaseID: @Sendable (String, String, String) async throws -> String
    public var record: @Sendable (String, Date, Int, [NotionTag], String, String) async throws -> Void
    public var getDatabaseTags: @Sendable (String, String) async throws -> [NotionTag]
    public var getAllRecords: @Sendable (String, String) async throws -> [Record]
    
    public static let liveValue = Self(
        getPageList: { try await getPageList(token: $0) },
        getCompatibleDatabaseList: { try await getCompatibleDatabaseList(token: $0) },
        createDatabaseAndGetDatabaseID: { try await createDatabaseAndGetDatabaseID(token: $0, parentPageID: $1, title: $2) },
        record: { try await record(token: $0, date: $1, time: $2, tags: $3, description: $4, databaseID: $5) },
        getDatabaseTags: { try await getDatabaseTags(token: $0, databaseID: $1) },
        getAllRecords: { try await getAllRecords(token: $0, databaseID: $1) }
    )
    
    public static let testValue = Self(
        getPageList: { _ in [] },
        getCompatibleDatabaseList: { _ in [] },
        createDatabaseAndGetDatabaseID: { _, _, _ in "" },
        record: { _, _, _, _, _, _ in },
        getDatabaseTags: { _, _ in [] },
        getAllRecords: { _, _ in [] }
    )
}

extension NotionAPIClient {
    private static func client(token: String) -> NotionClient {
        NotionClient(accessKeyProvider: StringAccessKeyProvider(accessKey: token))
    }
    
    public static func getAllRecords(
        token: String,
        databaseID: String
    ) async throws -> [Record] {
        return try await withCheckedThrowingContinuation { continuation in
            client(token: token).databaseQuery(databaseId: .init(databaseID)) {
                do {
                    var records = [Record]()
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
    
    public static func record(
        token: String,
        date: Date,
        time: Int,
        tags: [NotionTag],
        description: String,
        databaseID: String
    ) async throws {
        let client = client(token: token)
        
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
    
    public static func getDatabaseTags(
        token: String,
        databaseID: String
    ) async throws -> [NotionTag] {
        return try await withCheckedThrowingContinuation { continuation in
            client(token: token).database(databaseId: .init(databaseID)) { result in
                do {
                    let resultDatabase = try result.get()
                    guard let tagProperty = resultDatabase.properties["Tag"],
                          case .multiSelect(let selectOptions) = tagProperty.type
                    else {
                        throw NotionServiceError.invalidDatabase
                    }
                    
                    let tags: [NotionTag] = selectOptions.compactMap { selectOption in
                        guard let color = NotionTag.Color(rawValue: selectOption.color) else {
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
    
    public static func createDatabaseAndGetDatabaseID(
        token: String,
        parentPageID: String,
        title: String
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
            client(token: token).databaseCreate(request: request) { result in
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
    
    public static func getCompatibleDatabaseList(token: String) async throws -> [NotionDatabase] {
        return try await withCheckedThrowingContinuation { continuation in
            client(token: token).search(request: .init(filter: .database)) { result in
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
    
    public static func getPageList(token: String) async throws -> [NotionPage] {
        return try await withCheckedThrowingContinuation { continuation in
            client(token: token).search(request: .init(filter: .page)) { result in
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
    var asDatabaseEntity: NotionDatabase? {
        guard let title = self.title.first,
              case .text(let richTextType) = title.type else {
            return nil
        }
        return .init(id: self.id.rawValue, title: richTextType.content)
    }
}

extension Page {
    var asPageEntity: NotionPage? {
        guard let title = self.getTitle()?.first,
              case .text(let richTextType) = title.type else {
            return nil
        }
        return .init(id: self.id.rawValue, title: richTextType.content)
    }
    
    var asRecordEntity: Record? {
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
        let tags: [NotionTag] = multiSelectValue.map {
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
