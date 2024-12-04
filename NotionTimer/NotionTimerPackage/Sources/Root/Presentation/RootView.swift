//
//  RootView.swift
//  NotionTimerPackage
//
//  Created by Taichi on 2024/10/20.
//

import SwiftUI
import Notion
import Presentation

public struct RootView: View {
    @State private var notionService = NotionService()
    
    public init() {}
    
    public var body: some View {
        NavigationStack {
            switch notionService.authStatus {
            case .loading:
                CommonLoadingView()
            case .invalidToken:
                LoginView()
            case .invalidDatabase:
                DatabaseSelectionView()
            case .complete:
                HomeView()
            }
        }
        .onAppear {
            notionService.fetchAuthStatus()
        }
        .onOpenURL(perform: { url in
            if let deeplink = url.getDeeplink() {
                switch deeplink {
                case .notionTemporaryToken(let token):
                    Task {
                        do {
                            try await notionService.fetchAccessToken(temporaryToken: token)
                        } catch {
                            // TODO: アラートを表示（アクセストークンの取得に失敗）
                            debugPrint(error)
                        }
                    }
                }
            }
        })
        .animation(.default, value: notionService.authStatus)
        .environment(notionService)
    }
}

#Preview {
    RootView()
}
