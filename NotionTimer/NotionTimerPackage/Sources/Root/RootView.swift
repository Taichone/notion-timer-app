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
    @State private var notionAuthService = NotionAuthService()
    
    public init() {}
    
    public var body: some View {
        NavigationStack {
            ZStack {
                CommonGradient()
                
                switch notionAuthService.status {
                case .loading:
                    LoadingView(
                        label: nil,
                        textColor: .white
                    ) {
                        GlassmorphismRoundedRectangle()
                    }
                case .authorized:
                    HomeView()
                        .preferredColorScheme(.dark)
                case .unauthorized:
                    AuthView()
                }
            }
        }
        .onAppear {
            Task {
                notionAuthService.retrieveAccessTokenFromKeychain()
            }
        }
        .animation(.default, value: notionAuthService.status)
        .onOpenURL(perform: { url in
            if let deeplink = url.getDeeplink() {
                switch deeplink {
                case .notionTemporaryToken(let token):
                    Task {
                        do {
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
