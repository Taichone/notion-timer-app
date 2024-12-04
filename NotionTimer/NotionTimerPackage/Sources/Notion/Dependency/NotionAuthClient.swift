import Foundation
import Alamofire

struct NotionAuthClient {
    private struct GetAccessTokenRequestBody: Encodable {
        let code: String
    }
    
    private struct GetAccessTokenResponseBody: Decodable {
        let accessToken: String
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
