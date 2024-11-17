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
                .serializingDecodable(SearchPagesResponseBody.self, decoder: JSONDecoder.snakeCase).value
            
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
                .serializingDecodable(SearchDatabasesResponseBody.self, decoder: JSONDecoder.snakeCase).value
            
            return response.asDatabaseList
        
        } catch {
            debugPrint(error)
            throw NotionServiceError.failedToGetDatabaseList
        }
    }
    
    static func createDatabase(accessToken: String, parentPageID: String, title: String) async throws -> String {
        let endPoint = "https://api.notion.com/v1/databases"
        let headers: HTTPHeaders = [
            "Authorization": "Bearer \(accessToken)",
            "Content-Type": "application/json",
            "Notion-Version": "2022-06-28"
        ]
        
        let requestBody = Self.CreateDatabaseRequestBody(
            parent: .init(pageId: parentPageID),
            title: [.init(text: .init(content: title))]
        )
        
        do {
            let response = try await AF.request(
                endPoint,
                method: .post,
                parameters: requestBody,
                encoder: JSONParameterEncoder(encoder: JSONEncoder.snakeCase),
                headers: headers
            )
                .validate()
                .serializingDecodable(CreateDatabaseResponseBody.self, decoder: JSONDecoder.snakeCase).value
            
            return response.id
        } catch {
            debugPrint(error)
            throw NotionServiceError.failedToCreateDatabase
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
    
    // MARK: Get Access Token
    
    private struct GetAccessTokenRequestBody: Encodable {
        let code: String
    }
    
    private struct GetAccessTokenResponseBody: Decodable {
        let accessToken: String
    }
    
    // MARK: Search Databases or Pages
    
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
    
    private struct SearchPagesResponseBody: Decodable {
        let results: [Result]
        
        struct Result: Decodable {
            let id: String
            let properties: Properties
            
            struct Properties: Decodable {
                let title: PageTitle?
                
                struct PageTitle: Decodable {
                    let title: [PageTitleContent]
                    
                    struct PageTitleContent: Decodable {
                        let plainText: String
                    }
                }
            }
        }
        
        var asPageList: [Page] {
            self.results.compactMap {
                guard let title = $0.properties.title?.title.first else {
                    return nil
                }
                
                return .init(
                    id: $0.id,
                    title: title.plainText
                )
            }
        }
    }
    
    private struct SearchDatabasesResponseBody: Decodable {
        let results: [Result]
        
        struct Result: Decodable {
            let id: String
            let title: [DatabaseTitleContent]
            
            struct DatabaseTitleContent: Decodable {
                let plainText: String
            }
        }
        
        var asDatabaseList: [Database] {
            self.results.compactMap {
                guard let title = $0.title.first else {
                    return nil
                }
                
                return .init(
                    id: $0.id,
                    title: title.plainText
                )
            }
        }
    }
    
    // MARK: Create Database
    
    private struct CreateDatabaseRequestBody: Encodable {
        let parent: Parent
        let title: [Title]
        let properties: Properties = .init()
        
        struct Parent: Encodable {
            let type: String = "page_id"
            let pageId: String
        }
        
        struct Title: Encodable {
            let type: String = "text"
            let text: Text
            
            struct Text: Encodable {
                let content: String
                let link: String? = nil
            }
        }
        
        struct Properties: Encodable {
            let Title: Title = .init()
            let Date: Date = .init()
            let Time: Time = .init()
            let Tag: Tag = .init()
            let Description: Description = .init()
            
            struct Time: Encodable {
                let number: Number = .init()
                
                struct Number: Encodable {}
            }
            
            struct Description: Encodable {
                let richText: RichText = .init()
                
                struct RichText: Encodable {}
            }
            
            struct Title: Encodable {
                let title: TitleContent = .init()
                
                struct TitleContent: Encodable {}
            }
            
            struct Date: Encodable {
                let date: DateContent = .init()
                
                struct DateContent: Encodable {}
            }
            
            struct Tag: Encodable {
                let type: String = "multi_select"
                let multiSelect: MultiSelectContent = .init()
                
                struct MultiSelectContent: Encodable {}
            }
        }
    }
    
    private struct CreateDatabaseResponseBody: Decodable {
        let id: String
    }
}
