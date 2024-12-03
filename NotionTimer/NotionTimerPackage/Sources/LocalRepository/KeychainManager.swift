//
//  KeychainManager.swift
//  NotionTimerPackage
//
//  Created by Taichi on 2024/11/02.
//

import Security
import Foundation

public enum TokenType: String {
    case notionAccessToken
    case notionDatabaseID
}

public struct KeychainManager {
    private static let service = "com.taichone.NotionTimer"

    public static func saveToken(token: String?, type: TokenType) -> Bool {
        var success = true
        
        if let token = token, let tokenData = token.data(using: .utf8) {
            success = success && save(data: tokenData, account: type.rawValue)
        }
        
        return success
    }

    private static func save(data: Data, account: String) -> Bool {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account,
            kSecValueData as String: data
        ]
        
        SecItemDelete(query as CFDictionary) // 既存のアイテムを削除
        let status = SecItemAdd(query as CFDictionary, nil)
        return status == errSecSuccess
    }

    public static func retrieveToken(type: TokenType) -> String? {
        return retrieveToken(for: type.rawValue)
    }

    private static func retrieveToken(for account: String) -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account,
            kSecMatchLimit as String: kSecMatchLimitOne,
            kSecReturnData as String: kCFBooleanTrue as Any
        ]
        
        var dataTypeRef: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &dataTypeRef)
        
        if status == errSecSuccess {
            if let data = dataTypeRef as? Data {
                return String(data: data, encoding: .utf8)
            }
        }
        return nil
    }

    public static func deleteToken(type: TokenType) -> Bool {
        return delete(for: type.rawValue)
    }
    
    private static func delete(for account: String) -> Bool {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account
        ]
        
        let status = SecItemDelete(query as CFDictionary)
        return status == errSecSuccess
    }
}
