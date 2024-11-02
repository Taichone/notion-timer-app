//
//  SwiftUIView.swift
//  NotionTimerPackage
//
//  Created by Taichi on 2024/11/02.
//

import SwiftUI

public struct NotionAuthView: View {
    @State private var message = "Notionの連携が完了しました"
    let temporaryToken: String
    
    public var body: some View {
        Text(message)
            .task {
                await fetchAccessToken(temporaryToken: temporaryToken)
            }
    }
    
    private func fetchAccessToken(temporaryToken: String) async {
        // AWS Lambda URL
        guard let url = URL(string: "https://ft52ipjcsrdyyzviuos2pg6loi0ejzdv.lambda-url.ap-northeast-1.on.aws/") else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let parameters: [String: String] = ["code": temporaryToken]
        request.httpBody = try? JSONEncoder().encode(parameters)
        
        do {
            let (data, _) = try await URLSession.shared.data(for: request)
            if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
               let accessToken = json["access_token"] as? String {
                // KeychainManager を使用してアクセストークンを保存
                let success = KeychainManager.saveToken(token: accessToken, type: .notionAccessToken)
                await MainActor.run {
                    self.message = success ? "アクセストークンの保存が完了しました" : "アクセストークンの保存に失敗しました"
                }
            } else {
                await MainActor.run { self.message = "アクセストークンの取得に失敗しました" }
            }
        } catch {
            await MainActor.run { self.message = "エラーが発生しました: \(error.localizedDescription)" }
        }
    }
}

#Preview {
    NotionAuthView(temporaryToken: "invalid-token")
}
