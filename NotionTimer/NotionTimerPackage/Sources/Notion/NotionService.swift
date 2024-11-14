//
//  NotionService.swift
//  NotionTimerPackage
//
//  Created by Taichi on 2024/11/03.
//

import Foundation
import LocalRepository
import Alamofire

public struct NotionService {
    // FIXME: public にはしない（一時的に public にしている）
    public static var accessToken: String? {
        KeychainManager.retrieveToken(type: .notionAccessToken)
    }
    
    public init() {}
}

extension NotionService {
    struct SearchRequestBody: Encodable {
        let filter: Filter
        let sort: Sort = Sort()
        
        struct Filter: Encodable {
            let value: Value
            let property: String = "object"
            
            enum Value: String, Encodable {
                case page
                case database
            }
        }
        
        struct Sort: Encodable {
            let direction: String = "ascending"
            let timestamp: String = "last_edited_time"
        }
    }
}


// MARK: - Top-Level Response

struct SearchResponseBody: Decodable {
    let results: [Result]
    
    struct Result: Decodable {
        let id: String
        let lastEditedTime: String
        let parent: Parent?
        let properties: Properties
        
        struct Parent: Decodable {
            let pageId: String?
        }
        
        struct Properties: Decodable {
            let title: TitleContainer?
            
            struct TitleContainer: Decodable {
                let title: [Title]
                
                struct Title: Decodable {
                    let plainText: String
                }
            }
        }
    }
}

extension NotionService {
    public func getPageList() async throws {
        guard let accessToken = Self.accessToken else { return }
        
        let endPoint = "https://api.notion.com/v1/search"
        let headers: HTTPHeaders = [
            "Authorization": "Bearer \(accessToken)",
            "Content-Type": "application/json",
            "Notion-Version": "2022-06-28",
            "API-Version": "v1"
        ]
        
        let requestBody = Self.SearchRequestBody(
            filter: .init(value: .page)
        )
        
        let encoder = JSONEncoder()
        encoder.keyEncodingStrategy = .convertToSnakeCase
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        
        do {
            let response = try await AF.request(
                endPoint,
                method: .post,
                parameters: requestBody,
                encoder: JSONParameterEncoder(encoder: encoder),
                headers: headers
            )
                .validate()
                .serializingDecodable(SearchResponseBody.self, decoder: decoder).value
            
#if DEBUG
            for result in response.results {
                print(result.id)
                print(result.lastEditedTime)
                print(result.parent?.pageId ?? "nil")
                print("==title==")
                if let tc = result.properties.title {
                    for t in tc.title {
                        print(t.plainText)
                    }
                }
                print("======")
            }
            
            // 我々が想像する Page なら title が nil にならない
            let pages = response.results.filter { $0.properties.title != nil }
            
#endif
        } catch {
            debugPrint(error)
        }
        
        print(accessToken)
    }
}
