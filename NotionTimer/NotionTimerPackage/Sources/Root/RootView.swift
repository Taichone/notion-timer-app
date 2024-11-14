//
//  RootView.swift
//  NotionTimerPackage
//
//  Created by Taichi on 2024/10/20.
//

import SwiftUI
import Common

public struct RootView: View {
    @State private var notionAuthService = NotionAuthService()
    
    public init() {}
    
    public var body: some View {
        NavigationStack {
            ZStack {
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color("darkBlue", bundle: CommonColor.bundle),
                        .black
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottom
                ).ignoresSafeArea()
                
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
                try await Task.sleep(nanoseconds: 1000000000)
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
                            // TODO: ローディング中 Indicator を表示する（status に fetchingAccessToken といった case を追加）
                            try await Task.sleep(nanoseconds: 1000000000)
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
