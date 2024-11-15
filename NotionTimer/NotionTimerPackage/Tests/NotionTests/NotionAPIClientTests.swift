import Testing
@testable import Notion

import Foundation

@MainActor
struct NotionAPIClientTests {
    @Test func getDatabases_JSONの形式が見たいだけのテスト() async  {
        let token = "secret_XXX"
        
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
            let (data, response) = try await URLSession.shared.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
                return
            }
            
            // JSON デバッグ用: 整形して出力
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
