//
//  RootView.swift
//  NotionTimerPackage
//
//  Created by Taichi on 2024/10/20.
//

import SwiftUI
import Common
import Notion

@MainActor
@Observable final class RootRouter {
    var items: [Item] = []
    
    enum Item: Hashable {
        case pageSelection
        case databaseCreation
    }
}

public struct RootView: View {
    @State private var authService = NotionAuthService()
    @State private var router = RootRouter()
    
    public init() {}
    
    public var body: some View {
        NavigationStack(path: $router.items) {
            ZStack {
                CommonGradient()
                
                switch authService.status {
                case .loading:
                    CommonLoadingView()
                case .authorized:
                    HomeView()
                case .unauthorized:
                    AuthView() // ログインさせるだけ
                }
            }
            .navigationDestination(for: RootRouter.Item.self) { item in
                switch item {
                case .pageSelection:
                    PageSelectionView()
                        .navigationTitle(String(moduleLocalized: "select-page"))
                case .databaseCreation:
                    DatabaseCreationView()
                        .navigationTitle(String(moduleLocalized: "create-database"))
                }
            }
        }
        .onAppear {
            authService.retrieveAccessTokenFromKeychain()
        }
        .onOpenURL(perform: { url in
            if let deeplink = url.getDeeplink() {
                switch deeplink {
                case .notionTemporaryToken(let token):
                    Task {
                        do {
                            try await authService.fetchAccessToken(temporaryToken: token)
                            router.items.append(.pageSelection)
                        } catch {
                            // TODO: アラートを表示（アクセストークンの取得に失敗）
                            authService.changeStatusToUnauthorized() // AuthView へ
                        }
                    }
                }
            }
        })
        .animation(.default, value: authService.status)
        .preferredColorScheme(.dark)
        .environment(authService)
        .environment(router)
    }
}

#Preview {
    RootView()
}
