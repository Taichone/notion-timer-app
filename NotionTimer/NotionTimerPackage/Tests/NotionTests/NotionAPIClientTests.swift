import Testing
@testable import Notion

import Foundation

@MainActor
struct NotionAPIClientTests {
    @Test func getDatabases_JSONの形式が見たいだけのテスト() async  {
        let token = ""
        
        let endPoint = "https://api.notion.com/v1/search"
        let url = URL(string: endPoint)!

        let requestBody = SearchRequestBody(filter: .init(value: .database))
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("2022-06-28", forHTTPHeaderField: "Notion-Version")
        request.setValue("v1", forHTTPHeaderField: "API-Version")

        do {
            request.httpBody = try JSONEncoder.snakeCase.encode(requestBody)
            let (data, _) = try await URLSession.shared.data(for: request)
            
            if let jsonObject = try? JSONSerialization.jsonObject(with: data, options: []),
               let prettyData = try? JSONSerialization.data(withJSONObject: jsonObject, options: [.prettyPrinted]),
               let prettyString = String(data: prettyData, encoding: .utf8) {
                print("Response JSON (Pretty Printed):\n\(prettyString)")
            } else {
                print("Failed to format JSON response.")
            }
        } catch {
            print(error)
        }
    }
    
    @Test func createDatabase_JSONの形式が見たいだけのテスト() async  {
        let token = ""
        let title = "サンプルタイトル"
        let parentPageID = "6f77dfe2-7d02-4bab-b23e-2bbb7c87feb7"
        
        let endPoint = URL(string: "https://api.notion.com/v1/databases")!
        var request = URLRequest(url: endPoint)
        request.httpMethod = "POST"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("2022-06-28", forHTTPHeaderField: "Notion-Version")
        
        let requestBody = CreateDatabaseRequestBody(
            parent: .init(pageId: parentPageID),
            title: [.init(text: .init(content: title))]
        )
        do {
            let jsonData = try JSONEncoder.snakeCase.encode(requestBody)
            request.httpBody = jsonData
            if let jsonString = String(data: jsonData, encoding: .utf8) {
                print("Generated JSON for Request:")
                print(jsonString)
            }
            
            let (data, _) = try await URLSession.shared.data(for: request)
            
            if let jsonObject = try? JSONSerialization.jsonObject(with: data, options: []),
               let prettyData = try? JSONSerialization.data(withJSONObject: jsonObject, options: [.prettyPrinted]),
               let prettyString = String(data: prettyData, encoding: .utf8) {
                print("Response JSON (Pretty Printed):\n\(prettyString)")
            } else {
                print("Failed to format JSON response.")
            }
        } catch {
            print(error)
        }
    }
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
