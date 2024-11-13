//
//  RootView.swift
//  NotionTimerPackage
//
//  Created by Taichi on 2024/10/20.
//

import SwiftUI

public struct RootView: View {
    private static let notionLoginPageURL = URL(string: "https://api.notion.com/v1/oauth/authorize?client_id=131d872b-594c-8062-9bf9-0037ad7ce49b&response_type=code&owner=user&redirect_uri=https%3A%2F%2Ftaichone.github.io%2Fnotion-timer-web%2F")!
    
    @State private var notionAuthService = NotionAuthService()
    
    public init() {}
    
    public var body: some View {
        NavigationStack {
            switch notionAuthService.status {
            case .authorized:
                HomeView()
                    .preferredColorScheme(.dark)
            case .unauthorized:
                Link("Authorize Notion", destination: Self.notionLoginPageURL)
            }
        }
        .onAppear {
            notionAuthService.retrieveAccessTokenFromKeychain()
        }
        .animation(.default, value: notionAuthService.status)
        .onOpenURL(perform: { url in
            if let deeplink = url.getDeeplink() {
                switch deeplink {
                case .notionTemporaryToken(let token):
                    Task {
                        do {
                            // TODO: ローディング中 Indicator を表示する（status に fetchingAccessToken といった case を追加）
                            try await notionAuthService.fetchAccessToken(temporaryToken: token)
                        } catch {
                            debugPrint(error) // TODO: ハンドリング
                        }
                    }
                }
            }
        })
    }
}

#Preview {
    RootView()
}
