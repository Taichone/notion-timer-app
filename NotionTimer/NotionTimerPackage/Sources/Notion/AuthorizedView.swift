//
//  AuthorizedView.swift
//  NotionTimerPackage
//
//  Created by Taichi on 2024/11/01.
//

import SwiftUI

public struct AuthorizedView: View {
    private let code: String
    
    // TODO: Notion API 認証後の動線
    public init(code: String = "Invalid Code") {
        self.code = code
    }
    
    public var body: some View {
        VStack {
            Text("Authorized")
            Text("Code: \(code)")
        }
    }
}
