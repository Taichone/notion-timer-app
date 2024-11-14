//
//  NotionAPI.swift
//  NotionTimerPackage
//
//  Created by Taichi on 2024/11/14.
//

import Foundation
import Alamofire

struct NotionAPIClient {
    static func getPageList(accessToken: String) async throws -> [Page] {
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
        decoder.dateDecodingStrategy = .iso8601
        
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
            
            return response.asPageList
        } catch {
            debugPrint(error)
            throw NotionError.failedToGetPageList
        }
    }
}

extension NotionAPIClient {
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
            let direction: String = "descending"
            let timestamp: String = "last_edited_time"
        }
    }
    
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
        
        var asPageList: [Page] {
            self.results.compactMap {
                guard let titleContainer = $0.properties.title,
                      let title = titleContainer.title.first else {
                    return nil
                }
                
                if let date = try? Date(fromCustomISO8601: $0.lastEditedTime) {
                    return .init(
                        id: $0.id,
                        lastEditedTime: date,
                        parentPageId: $0.parent?.pageId,
                        title: title.plainText
                    )
                } else {
                    print("DATE: \($0.lastEditedTime)")
                    return nil
                }
            }
        }
    }
}
