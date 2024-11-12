//
//  NotionAuthService.swift
//  NotionTimerPackage
//
//  Created by Taichi on 2024/11/03.
//

import Foundation
import LocalRepository

enum NotionAuthStatus {
    case authorized
    case unauthorized
}

enum AccessTokenError: Error {
    case failedToSaveToKeychain
    case failedToFetchAccessToken
    case urlSessionError(Error)
}

@MainActor
@Observable final class NotionAuthService {
    var status: NotionAuthStatus = .unauthorized
    
    /// Temporary Token から Access Token を取得する関数
    func fetchAccessToken(temporaryToken: String) async throws {
        // TODO: Alamofire 検討
        guard let url = URL(
            string: "https://ft52ipjcsrdyyzviuos2pg6loi0ejzdv.lambda-url.ap-northeast-1.on.aws/"
        ) else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let parameters: [String: String] = ["code": temporaryToken]
        request.httpBody = try? JSONEncoder().encode(parameters)
        
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            
            if let httpResponse = response as? HTTPURLResponse {
                if httpResponse.statusCode != 200 {
                    throw AccessTokenError.failedToFetchAccessToken
                }
            }
            
            if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
               let accessToken = json["access_token"] as? String {
                if KeychainManager.saveToken(token: accessToken, type: .notionAccessToken) {
                    status = .authorized
                } else {
                    throw AccessTokenError.failedToSaveToKeychain
                }
            } else {
                throw AccessTokenError.failedToFetchAccessToken
            }
        } catch {
            throw AccessTokenError.urlSessionError(error)
        }
    }
}
