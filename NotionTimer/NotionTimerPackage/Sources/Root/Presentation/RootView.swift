//
//  RootView.swift
//  NotionTimerPackage
//
//  Created by Taichi on 2024/10/20.
//

import SwiftUI
import Common
import Notion

public struct RootView: View {
    @State private var notionService = NotionService()
    
    public init() {}
    
    public var body: some View {
        NavigationStack {
            ZStack {
                CommonGradient()
                
                switch notionService.authStatus {
                case .loading:
                    CommonLoadingView()
                case .authorized:
                    HomeView()
                case .unauthorized:
                    LoginView()
                }
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
        .preferredColorScheme(.dark)
        .environment(notionService)
    }
}

#Preview {
    RootView()
}
