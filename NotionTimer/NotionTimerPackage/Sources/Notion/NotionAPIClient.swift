//
//  NotionAPI.swift
//  NotionTimerPackage
//
//  Created by Taichi on 2024/11/14.
//

import Foundation
import Alamofire

struct NotionAPIClient {
    /// accessToken で許可されている Page 一覧を取得
    static func getPageList(accessToken: String) async throws -> [Page] {
        let endPoint = "https://api.notion.com/v1/search"
        let headers: HTTPHeaders = [
            "Authorization": "Bearer \(accessToken)",
            "Content-Type": "application/json",
            "Notion-Version": "2022-06-28",
            "API-Version": "v1"
        ]
        
        let requestBody = Self.SearchRequestBody(filter: .init(value: .page))
        
        do {
            let response = try await AF.request(
                endPoint,
                method: .post,
                parameters: requestBody,
                encoder: JSONParameterEncoder(encoder: JSONEncoder.snakeCase),
                headers: headers
            )
                .validate()
                .serializingDecodable(SearchResponseBody.self, decoder: JSONDecoder.snakeCase).value
            
            return response.asPageList
        } catch {
            debugPrint(error)
            throw NotionServiceError.failedToGetPageList
        }
    }
    
    /// accessToken で許可されている Database 一覧を取得
    static func getDatabaseList(accessToken: String) async throws -> [Database] {
        let endPoint = "https://api.notion.com/v1/search"
        let headers: HTTPHeaders = [
            "Authorization": "Bearer \(accessToken)",
            "Content-Type": "application/json",
            "Notion-Version": "2022-06-28",
            "API-Version": "v1"
        ]
        
        let requestBody = Self.SearchRequestBody(filter: .init(value: .database))
        
        do {
            let response = try await AF.request(
                endPoint,
                method: .post,
                parameters: requestBody,
                encoder: JSONParameterEncoder(encoder: JSONEncoder.snakeCase),
                headers: headers
            )
                .validate()
                .serializingDecodable(SearchResponseBody.self, decoder: JSONDecoder.snakeCase).value
            
            return response.asDatabaseList
        
        } catch {
            debugPrint(error)
            throw NotionServiceError.failedToGetDatabaseList
        }
    }
    
    /// temporaryToken から accessToken を取得
    public static func getAccessToken(temporaryToken: String) async throws -> String {
        let endPoint = "https://ft52ipjcsrdyyzviuos2pg6loi0ejzdv.lambda-url.ap-northeast-1.on.aws/"
        let headers: HTTPHeaders = [
            "Content-Type": "application/json",
        ]
        let requestBody = Self.GetAccessTokenRequestBody(code: temporaryToken)
        
        do {
            let response = try await AF.request(
                endPoint,
                method: .post,
                parameters: requestBody,
                encoder: JSONParameterEncoder(encoder: JSONEncoder.snakeCase),
                headers: headers
            )
                .validate()
                .serializingDecodable(GetAccessTokenResponseBody.self, decoder: JSONDecoder.snakeCase).value
            
            return response.accessToken
        } catch {
            debugPrint(error)
            throw NotionServiceError.failedToFetchAccessToken
        }
    }
}

extension NotionAPIClient {
    private struct GetAccessTokenRequestBody: Encodable {
        let code: String
    }
    
    private struct GetAccessTokenResponseBody: Decodable {
        let accessToken: String
    }
    
    private struct SearchRequestBody: Encodable {
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
    
    private struct SearchResponseBody: Decodable {
        let results: [Result]
        
        struct Result: Decodable {
            let id: String
            let lastEditedTime: String
            let parent: Parent?
            let properties: Properties
            let title: [DatabaseTitle]
            
            struct DatabaseTitle: Decodable {
                let plainText: String
            }
            
            struct Parent: Decodable {
                let pageId: String?
            }
            
            struct Properties: Decodable {
                let title: PageTitle?
                
                struct PageTitle: Decodable {
                    let title: [Title]
                    
                    struct Title: Decodable {
                        let plainText: String
                    }
                }
            }
        }
        
        var asPageList: [Page] {
            self.results.compactMap {
                guard let pageTitle = $0.properties.title,
                      let title = pageTitle.title.first else {
                    return nil
                }
                
                if let date = try? Date(fromCustomISO8601: $0.lastEditedTime) {
                    return .init(
                        id: $0.id,
                        lastEditedTime: date,
                        parentPageID: $0.parent?.pageId,
                        title: title.plainText
                    )
                } else {
                    return nil
                }
            }
        }
        
        var asDatabaseList: [Database] {
            self.results.compactMap {
                guard let title = $0.title.first else {
                    return nil
                }
                
                if let date = try? Date(fromCustomISO8601: $0.lastEditedTime) {
                    return .init(
                        id: $0.id,
                        title: title.plainText,
                        lastEditedTime: date
                    )
                } else {
                    return nil
                }
            }
        }
    }
}
